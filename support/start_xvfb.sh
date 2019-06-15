#!/usr/bin/env bash
if [[ "$RAKE_TASK" == "spec" ]]; then
   echo "Starting Xvfb..."
  nohup Xvfb $DISPLAY -screen 0 1024x768x24 &
fi