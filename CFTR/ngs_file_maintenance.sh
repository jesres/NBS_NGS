#!/usr/bin/env bash
#
#######################################
#Script: ngs_file_maintenance.sh
#Author: robert.sicko@health.ny.gov
#Description: script to remove raw miseq data (.bcl, .locs and .stats)
#             that is older than 6 months. 
#             also compresses log files (currently just /mnt/agtcnbs/logs)
#             that are older than 5 days
#
#Change Log: v1.0.0 - Implemented
#
#            v1.0.1 - uncommented remove_old_raw_miseq, should have been in use when implemented
#                   - added comp_miseq_logs function to compress the "Logs" folder in every miseq run
#            v1.0.2 - added rsync to agtcnbs_archive for files older than 6 months. 
#            v1.0.3 - remove verbose from log tar
#                   - handle spaces in directory names in xfer_to_archive (while IFS= read -r -d '' project; do)
#            v1.0.4-DONT USE. only root can unmount. rolled back to v1.0.3. 
#                   - added unmount and remount in the xfer_to_archive function
#            v1.0.5 - agtcnbs_archive uses automount now to address the dropping connection. 
#                   - updated the path to archive to work with automount.
#                   - made -mtime +270 on line 162 to test with a few runs since archive hasn't been working for awhile. 
#            v1.0.6 - changed -mtime +180 on line 162. 
#######################################
#######################################
#GLOBAL DEFINITIONS
VERSION="1.0.6"
STORAGE_MOUNT="/mnt/agtcnbs"
ARCHIVE_DIR="/mnt/auto/agtcnbs_archive/CF/Runs"
PROJECTS_DIR="/mnt/agtcnbs/CF/Runs"

DATESTAMP="$(date "+%Y-%m-%d")"
#TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"
LOG_LOCATION="/mnt/agtcnbs/logs"
LOG="${LOG_LOCATION}/${DATESTAMP}_ngs_file_maintenance.log"

#######################################

function log_step () {
  local time_stamp
  time_stamp="$(date)"
  local step_name="$1"
  local step_status="$2"
  local msg="$3"
  echo "[$time_stamp]"$'\t'"$step_name"$'\t'"[$step_status]"$'\t'"$msg"
  if [[ $step_status == "ERROR" ]]; then
    mailx -s "ngs_file_maintenance.sh generated an error at $step_name" robert.sicko@health.ny.gov < "$LOG"
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
#FUNCTION remove_old_raw_miseq
# delete raw miseq data greater than 6 months old
# Globals:
# Arguments:
#######################################
function remove_old_raw_miseq (){
  log_step "remove_old_raw_miseq" STARTED "Started removing old raw data"
  #delete files older than 6 months, start with bcl
  find ${PROJECTS_DIR} -type f -name "*.bcl" -mtime +180 -exec rm {} \;
  #and locs
  find ${PROJECTS_DIR} -type f -name "*.locs" -mtime +180 -exec rm {} \;
  #and stats
  find ${PROJECTS_DIR} -type f -name "*.stats" -mtime +180 -exec rm {} \;
  #and jpg
  find ${PROJECTS_DIR} -type f -name "*.jpg" -mtime +180 -exec rm {} \;
  log_step "remove_old_raw_miseq" FINISHED "Finished removing old raw data"
}

#######################################
#FUNCTION remove_old_archer_fastq
# delete fastqs from Archer Analysis if they are greater than 6 months old
# Globals:
# Arguments:
#######################################
function remove_old_archer_fastq (){
  log_step "remove_old_archer_fastq" STARTED "Started removing old raw data"
  #delete files older than 6 months, start with bcl
  find /var/www/analysis/sequence_files -name "*.fastq" -mtime +180 -exec rm {} \;
  log_step "remove_old_archer_fastq" FINISHED "Finished removing old raw data"
}

#######################################
#FUNCTION comp_logs
# compress log files older than 7 days
# Globals:
# Arguments:
#######################################
function comp_logs (){
  LOG_TAG="20??-??-??_archer_process_miseq_run.log"
  log_step "comp_logs" STARTED "Started compressing old logs"
  cd "${LOG_LOCATION}" || exit
  log_list="$(find . -name "${LOG_TAG}" -type f -mtime +7)"
  if [[ -n "$log_list" ]]; then
    echo "${log_list}" | sed "s+.*+'&'+" | xargs gzip
  fi
  log_step "comp_logs" FINISHED "Finished compressing old logs"
}

#######################################
#FUNCTION comp_miseq_logs
# compress the MiSeq Log folder if it's older than 6 months
# Globals:
# Arguments:
#######################################
function comp_miseq_logs (){
  log_step "comp_miseq_logs" STARTED "Started compressing old logs"
  cd "${PROJECTS_DIR}" || exit
  find . -maxdepth 2 -mindepth 2 -type d -name "Logs" -mtime +180 -exec tar zcf {}.tar.gz {} --remove-files \;
  log_step "comp_miseq_logs" FINISHED "Finished compressing old logs"
}

#######################################
#FUNCTION xfer_to_archive
# transfers runs older than 6 months to the agtcnbs_archive drive
# Globals:
# Arguments:
#######################################
function xfer_to_archive (){
  log_step "xfer_to_archive" STARTED "Moving runs older than 6 months to the archive"
  #-print0
  
  while IFS= read -r -d '' project; do
     proj_dir=$(dirname "$project")
     proj_name=$(basename "$proj_dir")
     touch "${proj_dir}/archive.started"
     
     log_step "xfer_to_archive" INFO "Found a run to archive"
     log_step "xfer_to_archive" INFO "project=${project}"
     log_step "xfer_to_archive" INFO "proj_dir=${proj_dir}"
     log_step "xfer_to_archive" INFO "proj_name=${proj_name}"
     
     rsync -a "${proj_dir}" "${ARCHIVE_DIR}"
     if diff -rq "${proj_dir}" "${ARCHIVE_DIR}/${proj_name}" > /dev/null
     then
       #echo "The files are equal"
       touch "${proj_dir}/archive.done"
     else
       touch "${proj_dir}/archive.diff.err"
       #echo "The files are different or inaccessible"
     fi
  done < <(find ${PROJECTS_DIR} -maxdepth 2 -mindepth 2 -type f -name "Logs.tar.gz" -mtime +180 -print0)

#####old version. not robust. causes projects when directory has spaces!
#  xfer_list="$(find ${PROJECTS_DIR} -maxdepth 2 -mindepth 2 -type f -name "Logs.tar.gz" -mtime +180)"
#  if [[ -n "$xfer_list" ]]; then #if our found list is not empty
#    for project in $xfer_list; do 
#      proj_dir=$(dirname "$project")
#      proj_name=$(basename "$proj_dir")
#      touch "${proj_dir}/archive.started"
#      rsync -a "${proj_dir}" "${ARCHIVE_DIR}"
#      if diff -rq "${proj_dir}" "${ARCHIVE_DIR}/${proj_name}" > /dev/null
#      then
#        #echo "The files are equal"
#        touch "${proj_dir}/archive.done"
#      else
#        touch "${proj_dir}/archive.diff.err"
#        #echo "The files are different or inaccessible"
#      fi
#    done
##  fi

    while IFS= read -r -d '' archive; do
     archive_fold=$(dirname "$archive")
     rsync -a --checksum --remove-source-files "${archive_fold}" "${ARCHIVE_DIR}"
     touch "${archive_fold}/project-archived-on-agtcnbs_archive"
  done < <(find ${PROJECTS_DIR} -maxdepth 2 -mindepth 2 -type f -name "archive.done" -print0)
  
#####old version. not robust. causes projects when directory has spaces!
#  archived_list="$(find ${PROJECTS_DIR} -maxdepth 2 -mindepth 2 -type f -name "archive.done")"
#  if [[ -n "$archived_list" ]]; then #if our list of projects successfully archived is not empty
#    for archive in $archived_list; do
#      archive_fold=$(dirname "$archive")
#      rsync -a --checksum --remove-source-files "${archive_fold}" "${ARCHIVE_DIR}"
#      touch "${archive_fold}/project-archived-on-agtcnbs_archive"
#    done
#  fi
  log_step "xfer_to_archive" FINISHED "Finished transfering to archive"
}

function main () {
  if ! check_mount ; then
      LOG_LOCATION="/opt/nys_nbs"
      log_step "main" ERROR "could not access storage"
      touch "$LOG"
      exec >> "$LOG" 2>&1
  else 
    touch "$LOG"
    exec >> "$LOG" 2>&1
    log_step "main" STARTED "Started ngs_file_maintenance.sh $VERSION"
    remove_old_raw_miseq
    comp_logs
    comp_miseq_logs
    remove_old_archer_fastq
    xfer_to_archive
    log_step "main" FINISHED "all done"
  fi
}

main "$@"
