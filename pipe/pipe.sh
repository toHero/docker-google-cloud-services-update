#!/usr/bin/env bash
#
# Update google cloud platform services (Cloud Tasks, Cloud Scheduler, Datastore...)
#
# Required globals:
#   KEY_FILE
#   PROJECT
#
# Optional globals:
#   DEBUG
#   SERVICES
#   CONFIG_FILES_DIR

source "$(dirname "$0")/common.sh"
enable_debug

# Required parameters
KEY_FILE=${KEY_FILE:?'KEY_FILE variable missing.'}
PROJECT=${PROJECT:?'PROJECT variable missing.'}

# Default parameters
DEBUG=${DEBUG:="false"}
SERVICES=${SERVICES:='cloud-tasks cloud-scheduler datastore'}
CONFIG_FILES_DIR=${CONFIG_FILES_DIR:="build"}

config_file_exists() {
  FILE_PATH="${CONFIG_FILES_DIR}/$1"
  if [ ! -f "$FILE_PATH" ]; then
    fail "$FILE_PATH does not exist."
  fi
}

check_update_status() {
  if [ "${status}" -eq 0 ]; then
    success "Service $1 update successful!"
  else
    fail "Service $1 update failed!"
  fi
}

info "Setting up environment..."

# The flag --quiet allows you to run Google Cloud SDK commands in a non-interactive way
run 'echo "${KEY_FILE}" | base64 -d >> /tmp/key-file.json'
run gcloud auth activate-service-account --key-file /tmp/key-file.json --quiet ${gcloud_debug_args}
run gcloud config set project $PROJECT --quiet ${gcloud_debug_args}

for service in $SERVICES; do
  info "Starting update of ${service}..."
  case $service in
  cloud-tasks)
    # Update Cloud Tasks queues config
    config_file_exists "queue.yaml"
    run gcloud app deploy "${CONFIG_FILES_DIR}/queue.yaml" --project="$PROJECT" --quiet ${gcloud_debug_args}
    check_update_status "${service}"
    ;;
  cloud-scheduler)
    # Update Cloud Scheduler config for App Engine cron tasks
    config_file_exists "cron.yaml"
    run gcloud app deploy "${CONFIG_FILES_DIR}/cron.yaml" --project="$PROJECT" --quiet ${gcloud_debug_args}
    check_update_status "${service}"
    ;;
  datastore)
    info "Deploy datastore indexes."
    config_file_exists "index.yaml"
    run gcloud app deploy "${CONFIG_FILES_DIR}/index.yaml" --project=$PROJECT --quiet ${gcloud_debug_args}
    check_update_status "${service}"
    # Cleanup datastore indexes removed from index.yaml (this file must be deployed first)
    info "Cleanup datastore indexes."
    run gcloud datastore indexes cleanup "${CONFIG_FILES_DIR}/index.yaml" --project=$PROJECT --quiet ${gcloud_debug_args}
    check_update_status "${service} cleanup"
    ;;
  *)
    fail "Unknown service: ${service}."
    ;;
  esac
done
