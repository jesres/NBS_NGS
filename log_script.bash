#Global Definitions
VERSION="v1.0.3"
LOG_LOCATION="/opt/nys_nbs/scid/output/logs"
DATESTAMP="$(date "+%Y-%m-%d")"
LOG="${LOG_LOCATION}/${DATESTAMP}_archer_process_miseq_run.log"
hook_output_dir="/opt/nys_nbs/scid/output"
job_dir="/opt/nys_nbs/scid/5082-2"
job_id="5082-2_coverage_report.txt"
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
  local VERSION
  VERSION="v1.0.3"
  echo "[$DATESTAMP]"$'\t'"[$VERSION]" > /opt/nys_nbs/scid/output/log.txt
}
log_step
