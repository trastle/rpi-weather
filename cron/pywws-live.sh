#!/bin/bash

# ---------------------------------------------------------------
#
# A script to keep the pywws live data logger running running.
#
# ---------------------------------------------------------------

# Configuration
# -------------
PID_FILE="/tmp/pywws.pid"
DATA_DIR="/home/pi/weather/data"
LOG_DIR="/home/pi/weather/log"
LIVE_LOG="$LOG_DIR/live-weather.log"
LAUNCHER_LOG="$LOG_DIR/live-launcher.log"

# Functions
# ---------

# Log text to the file $LAUNCHER_LOG
function log
{
    local timestamp=`date +%y-%m-%d:%H:%M:%S`
    echo  "$timestamp $@" >> "$LAUNCHER_LOG"
    echo  "$timestamp $@" 
}

# Create the log and data directories if they are missing
function setup
{
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
    fi

    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"
    fi
}

# Check to see if the process with the PID contained in the
# file passed as $1 is currently running. Return 1 if still
# running otherwise return 0.
isRunning()
{
  log "Checking pid file [$1]"
  [ "$1" = "" ]  && return 0
  [ ! -f "$1" ]  && return 0
  local pywwspid=`pgrep -F $1`
  log "Found running process [$pywwspid]"
if [ "$pywwspid" = "" ]; then
      return 0;
  else
      return 1;
  fi
}

# Main
# ----

setup
log "Pywws wrapper script launched by cron..."
isRunning "$PID_FILE"

if [ $? -eq 1 ]; then
    log "Pywws live logger already running..."
else
    log "Restarting pywws live logger..."
    python /home/pi/weather/pywws/code/LiveLog.py -vvv -l "$LIVE_LOG" "$DATA_DIR" &
    echo $! >"$PID_FILE"
fi

log "Pywws wrapper script done."
