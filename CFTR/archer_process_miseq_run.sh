#!/usr/bin/env bash
#
#######################################
#Script: archer_process_miseq_run.sh
#Author: robert.sicko@health.ny.gov
#Description: script to call bcl2fastq and copy fastqs to Archer Analysis
#             watch folder for Archer CFTR 2nd-tier analysis
#Change Log: v1.0.0 - Validated
#
#            v1.0.1 - run_ready_demultiplex - return true if only demultiplex.started is found.
#                   - run_ready_demultiplex - changed sleep in stat from 5 min to 10 min. 
#                   - run_ready_demultiplex - added more logging to report when stat doesn't match.
#                   - log_step - stopped emailing entire log and only current warning/error.
#                   - find_project_name - added ability to extract project name from 'Experiment Name' in SampleSheet.csv
#
#            v1.0.2 - rename project directory 1 day after archer.done file created, but ignore projects older than 5 days.
#            v1.0.3 - changed the loop in run_ready_demultiplex to a for loop with max runs of 7 to prevent new hourly cron call from processing same run as a sleeping script
#            v1.0.4 - added the check for projects in incorrect directory. lines 289 - 310
#                   - parse the "Archer-YYYY-DDD" format in the 'Experiment Name' field of SampleSheet.csv lines 210 - 216
#            v1.0.5 - the change in 1.0.3 did not work:
#                               - was going to use a lock file, but discovered 'flock' so I modified the cron file as follows:
#                                     sudo vi /var/spool/cron/srvArcherNBS
#                                     then insert "flock -x -n /home/srvArcherNBS/temp/archer_process_miseq_run.lock -c" after "@hourly"
#                               - reverted to 1.0.2 version of the loop in run_ready_demultiplex.
#                   - ignore archived runs to avoid spamming the log file (if [[ -f "${proj}/project-archived-on-agtcnbs_archive" ]]; then)
#######################################
#GLOBAL DEFINITIONS
VERSION="1.0.5"
#SERVICE_ACCOUNT="srvArcherNBS"
STORAGE_MOUNT="/mnt/agtcnbs"
PROJECTS_DIR="/mnt/agtcnbs/CF/Runs"
WRONG_DIR="/mnt/agtcnbs/CF"
WATCHED_FOLDER="/watched/robert.sicko@health.ny.gov/CFTR"
DATESTAMP="$(date "+%Y-%m-%d")"
#TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"
LOG_LOCATION="/mnt/agtcnbs/logs"
LOG="${LOG_LOCATION}/${DATESTAMP}_archer_process_miseq_run.log"
#######################################

#######################################
#FUNCTION log_step
# Adds a line to the log file
# Globals:
# Arguments:
#   step_name - name of the step e.g. Setup
#   step_status - e.g. STARTED, INFO, WARNING, ERROR, FINISHED
#   message
# Usage: log_step STEP STATUS [ MESSAGE ]
#######################################
function log_step () {
  local time_stamp
  time_stamp="$(date)"
  local step_name="$1"
  local step_status="$2"
  local msg="$3"
  echo "[$time_stamp]"$'\t'"$step_name"$'\t'"[$step_status]"$'\t'"$msg"
  if [[ "$step_status" = "ERROR" ]] || [[ "$step_status" = "WARNING" ]]; then
    tail -1 "$LOG" | mailx -s "archer_process_miseq_run warning or error." robert.sicko@health.ny.gov
  fi
}

#######################################
#FUNCTION check_mount
# Checks that the storage drive is mounted. If it isn't, it attempts to mount it and returns false if it can't
# Globals:
# Arguments:
#######################################
function check_mount () {
  local mount_ls
  mount_ls=$(ls -l "$STORAGE_MOUNT")
  if [[ "$mount_ls" == "total 0" ]]; then
    #empty ls. drive must not be mounted
      log_step "check_mount" ERROR "could not mount agtcnbs!"
      false
  else  #everything seems fine
     log_step "check_mount" FINISHED "agtcnbs is mounted"
     true
  fi
}

#######################################
#FUNCTION run_ready_demultiplex
# Checks that a run is ready to demultiplex
# Globals:
# Arguments:
#   project - a MiSeq run folder
#######################################
function run_ready_demultiplex () {
  local proj="$1"
  #check if archived
  #project-archived-on-agtcnbs_archive
  if [[ -f "${proj}/project-archived-on-agtcnbs_archive" ]]; then
    #don't spam the log, just exit
    false
  #RTAComplete.txt there?
  elif [[ ! -f "${proj}/RTAComplete.txt" ]]; then
      log_step "run_ready_demultiplex" INFO "${proj} doesn't have RTAComplete.txt"
      false
  #demultiplex.done there? hasn't already been processed.
  elif [[ -f "${proj}/demultiplex.done" ]]; then
      log_step "run_ready_demultiplex" INFO "${proj} already basecalled"
      false
  elif [[ -f "${proj}/demultiplex.started" ]]; then
      log_step "run_ready_demultiplex" WARNING "${proj} already had a demultiplex.started. Attempting again."
      true
  #we've got a project dir, it doesn't have a demultiplex.done file, let's make sure it is finished copying from the miseq
  #size hasn't changed in 5 minutes. indicating copying is done
  else
      log_step "run_ready_demultiplex" INFO "${proj} has an RTAComplete. "
      local old_size=0
      local new_size=0
      while true; do
          new_size=$(du -sb "$proj" | cut -f1)
          if [[ "$old_size" -eq "$new_size" ]]; then
              log_step "run_ready_demultiplex" INFO "${proj} looks finished. Size = ${new_size}"
              break
          elif [[ "$old_size" -eq "0" ]]; then
              log_step "run_ready_demultiplex" INFO "Checking if finished copying. Sleeping for 5 minutes."
              old_size="$new_size"
              sleep 5m
          else  
              log_step "run_ready_demultiplex" INFO "${proj} size changed. Was ${old_size}, now ${new_size}"
              old_size="$new_size"
              sleep 5m
          fi
      done
      log_step "run_ready_demultiplex" FINISHED "${proj} is good to process"
      true
  fi
}


#######################################
#FUNCTION run_ready_analyze
# Checks that a run is ready to analyze
# Globals:
# Arguments:
#   project - a MiSeq run folder
#######################################
function run_ready_analyze () {
  local proj="$1"
  #check if archived
  #project-archived-on-agtcnbs_archive
  if [[ -f "${proj}/project-archived-on-agtcnbs_archive" ]]; then
    #don't spam the log, just exit
    false
  #RTAComplete.txt there? it's a finished MiSeq run if so.
  #kick out false if it isn't a MiSeq run
  elif [[ ! -f "${proj}/RTAComplete.txt" ]]; then
      log_step "run_ready_analyze" INFO "${proj} doesn't have RTAComplete.txt"
      false
  #archer.done present? it's already been copied to the watch folder if so
  #kick out false if it has already been copied and rename the folder if it is older than 24 hours
  elif [[ -f "${proj}/archer.done" ]]; then
      log_step "run_ready_analyze" INFO "${proj} already copied to Archer watch folder"
      MAXAGE=$(bc <<< '7*24*60*60') # seconds in 7 days
      MINAGE=$(bc <<< '4*24*60*60') # seconds in 4 days
      # file age in seconds = current_time - file_modification_time.
      FILEAGE=$(($(date +%s) - $(stat -c '%Y' "${proj}/archer.done")))
      if [ "$FILEAGE" -gt "$MINAGE" ] && [ "$FILEAGE" -lt "$MAXAGE" ]; then
        archer_name=""
        find_project_name "$proj"
        if [[ "$archer_name" == "done_already" ]]; then
          log_step "run_ready_analyze" INFO "Didn't rename ${proj}. looks like it already has YYYY-DDD."
        else
          archer_proj_lc=$(echo "$proj" | tr '[:upper:]' '[:lower:]')
          archer_project_name="${archer_proj_lc/#*archer-/}"
          archer_project_name="${archer_project_name/%\/}"
          if [[ "$archer_project_name" =~ ^[0-9][0-9][0-9][0-9] ]] ; then #folder already has archer-YYYY-DDD
            log_step "run_ready_analyze" INFO "Didn't rename ${proj}. looks like it already has YYYY-DDD."
          else
            log_step "run_ready_analyze" INFO "Renamed ${proj} with YYYY-DDD."
            mv -n "$proj" "${proj}-Archer-${archer_name}"
          fi
        fi
      fi
      false
  else  #we've got a complete MiSeq run, that hasn't been copied to Archer, let's get to work
      #fastqs present?
      fastqs=$(find "${project}/BaseCalls" -type f -name "*.fastq.gz")
      if [[ -n "$fastqs" ]]; then
        #we found fastqs
        if [[ -f "${proj}/archer.pending" ]]; then
          log_step "run_ready_analyze" WARNING "Possible issue. $proj has an archer.pending file, but no archer.done file"
        fi
        log_step "run_ready_analyze" FINISHED "${proj} is ready to analyze"
        true
      else
        #we didn't find any fastqs
        #log an error, this shouldn't happen since we are in a project with 
        #an RTAComplete.txt and no archer.done
        log_step "run_ready_analyze" ERROR "Couldn't find any fastqs for ${proj}"
        false
      fi
  fi
}
#######################################
#FUNCTION find_project_name
# helper function to extract the project name from the samplesheet
# Globals: project_name, archer_name
# Arguments:
#   project - a MiSeq run folder
# TODO:
#   make it so this function can extract multiple project names from the same sample sheet
#######################################
function find_project_name (){
  local proj="$1"
  local sample_sheet="${proj}/SampleSheet.csv"
  #look for the "Sample_Project" (header) line, grep everything for 500 lines after that
  #pipe to translate to remove the \r characters (windows vs unix)
  project_name=$(grep -A500 "Sample_Project" "$sample_sheet" | \
  tr -d '\r' | \
  awk 'BEGIN { NR==1; FS="," } { for (i=1; i<=NF; i++) { f[$i] = i } } { print $(f["Sample_Project"]) }' | \
  head -2 | tail -1)
  if [[ "$project_name" =~ ^[0-9][0-9][0-9][0-9] ]] ; then #found YYYY-DDD to use for project name
    archer_name="$project_name"
    project_name="CF_${project_name}_2nd-tier_auto"
    true
  else
    log_step "find_project_name" INFO "Couldn't extract project name from 'Sample_Project' field in SampleSheet.csv in $proj. Attempting to extract from 'Experiment Name' in SampleSheet.csv"
    project_name=$(grep "Experiment Name" "$sample_sheet" | tr -d '\r' | cut -f2 -d ',')
    if [[ "$project_name" =~ ^[0-9][0-9][0-9][0-9] ]] ; then #found YYYY-DDD to use for project name
      archer_name="$project_name"
      project_name="CF_${project_name}_2nd-tier_auto"
      true
    elif [[ "$project_name" == Archer* ]] || [[ "$project_name" == archer* ]] ; then
      proj_lc=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')
      project_name="${proj_lc/#archer-/}"
      if [[ "$project_name" =~ ^[0-9][0-9][0-9][0-9] ]] ; then
        archer_name="$project_name"
        project_name="CF_${project_name}_2nd-tier_auto"
        true
      else
        log_step "find_project_name" INFO "Couldn't extract project name from 'Sample_Project' field or 'Experiment Name' field in SampleSheet.csv in $proj. Attempting to extract from directory name"
        proj_lc=$(echo "$proj" | tr '[:upper:]' '[:lower:]')
        project_name="${proj_lc/#*archer-/}"
        project_name="${project_name/%\/}"
        if [[ "$project_name" =~ ^[0-9][0-9][0-9][0-9] ]] ; then #found YYYY-DDD to use for project name
          archer_name="done_already"
          project_name="CF_${project_name}_2nd-tier_auto"
          true
        else
          log_step "find_project_name" ERROR "Couldn't extract project name from SampleSheet.csv or directory"
          false
        fi
      fi
    fi
  fi
}

#######################################
#FUNCTION link_fastqs
# Soft links demultiplexed fastqs to the Archer watched folder
# Globals:
# Arguments:
#   project - a MiSeq run folder
# TODO:
#   accept multiple projects in the same sample sheet. create multiple folders based on the project in the sample sheet and link there.
#######################################
function link_fastqs () {
  #we know we have at least one fastq since this function was called.
  #so, extract project name
  local proj="$1"
  #attempt to get project name from samplesheet
  #local sample_sheet="${project}/SampleSheet.csv"
  project_name=""
  if find_project_name "$proj" ; then
    mkdir -p "${WATCHED_FOLDER}/${project_name}"
    chmod g+w "${WATCHED_FOLDER}/${project_name}"
    for fastq in $fastqs ; do
      #don't copy blanks
      #don't copy undetermined
      #don't copy RES
      fastq_name="${fastq##*/}"
      # set nocasematch option
      shopt -s nocasematch
      if [[ ${fastq_name} != *"blank"* && ${fastq_name} != *"undetermined"* && ${fastq_name} != *"RES"* ]]; then 
        ln -s "$fastq" "${WATCHED_FOLDER}/${project_name}/${fastq_name}"
        chmod g+w "${WATCHED_FOLDER}/${project_name}/${fastq_name}"
      fi
      # unset nocasematch option
      shopt -u nocasematch
    done
    touch "${WATCHED_FOLDER}/${project_name}.completed"
    true
  else
    log_step "link_fastqs" ERROR "Unable to find project name. Fastqs not linked"
    false
  fi
  
}

#######################################
#FUNCTION main
# Globals:
# Arguments:
#######################################
function main (){
  #check our storage
  if ! check_mount ; then
      LOG_LOCATION="/opt/nys_nbs"
      log_step "main" ERROR "could not access storage"
      touch "$LOG"
      exec >> "$LOG" 2>&1
  else 
    touch "$LOG"
    exec >> "$LOG" 2>&1

    #list runs 
    log_step "main" STARTED "Started archer_process_miseq_run.sh $VERSION"
    START_TIME=$(date +%s)

    #first check for projects in the wrong project directory
    #\\prdnbsfs.health1.hcom.health.state.ny.us\agtcnbs\CF instead of \\prdnbsfs.health1.hcom.health.state.ny.us\agtcnbs\CF\Runs
    for project in "${WRONG_DIR}"/* ; do
      if [[ -f "${project}/rsync.started" ]]; then
            log_step "rsync" INFO "${project} already started syncing"
      elif [[ -f "${project}/rsync.done" ]]; then
            log_step "rsync" INFO "${proj} already copied"
      elif run_ready_demultiplex "$project" ; then
          log_step "rsync" STARTED "rsyncing $project to correct run folder"
          touch "${project}/rsync.started"  #output a pending file
          base=$(basename "$project")
          rsync -a "${project}/" "${PROJECTS_DIR}/$base"
          touch "${project}/rsync.done"  #output a finished file
          log_step "rsync" FINISHED "copied $project to correct run folder"
          END_TIME=$(date +%s)
          DIFF=$(( END_TIME - START_TIME ))
          #if the copy has taken longer than 40 minutes, exit
          #since the next cron call of this script happens every hour
          if (( DIFF > 2400 )); then 
            log_step "rsync" INFO "took longer than 40 min to copy. ending this instance of the script."
            exit 1
          fi
      fi
    done
    #now go through projects in correct directory
    for project in "${PROJECTS_DIR}"/* ; do
      if run_ready_demultiplex "$project" ; then
          log_step "bcl2fastq" STARTED "demultiplexing $project with command: nohup /usr/local/bin/bcl2fastq --runfolder-dir $project --output-dir ${project}/BaseCalls"
          touch "${project}/demultiplex.started"  #output a pending file
          nohup /usr/local/bin/bcl2fastq --runfolder-dir "$project" --output-dir "${project}/BaseCalls"
          status=$?
          if [[ "$status" -ne 0 ]]  ; then #attempt with no mismatches
            nohup /usr/local/bin/bcl2fastq --runfolder-dir "$project" --output-dir "${project}/BaseCalls" --barcode-mismatches 0
            status=$?
            if [[ "$status" -eq 0 ]] ; then
              log_step "bcl2fastq" WARNING "Barcode collision. Demultiplexed with 0 mismatch option."
              touch "${project}/demultiplex.done" #output a finished file
            else
              log_step "bcl2fastq" ERROR "Unknown error with bcl2fastq. Check logfile"
            fi
          else
            touch "${project}/demultiplex.done" #output a finished file
            log_step "bcl2fastq" FINISHED "$project demultiplexed. fastq files are in ${project}/BaseCalls"
          fi
      fi
      fastqs=""
      if run_ready_analyze "$project" ; then
          touch "${project}/archer.pending" #output a file so we know we started linking fastqs
          log_step "link_fastqs" STARTED "Started linking fastqs for $project to the Archer watch folder"
          if link_fastqs "$project" ; then
            touch "${project}/archer.done"
            log_step "link_fastqs" FINISHED "Finished linking fastqs for $project to the Archer watch folder"
          else
            log_step "link_fastqs" ERROR "Could not link fastqs for $project"
          fi
      fi
    done
    log_step "main" FINISHED "all done"
  fi
}

main "$@"