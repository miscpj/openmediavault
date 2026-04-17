#!/bin/bash

# This script turns on/off the webcam plugged in to the running it.
# Wehn the webcam is acted upon we also turn on/off the IPCam streaming to preserve resources.
#
# It is installed ine /home/pjmd/bin
# it is executed from a remote machine (WLS) using  rsh: rsh 192.168.1.33 /home/pjmd/bin/webcam.sh $1 
# 192.168.1.33 is the omv IP
# 
# dependencies: 
#   vlc
#   ipcam-capture.sh
#
# On client GUI side
# Open VLC
# Menu Media | Open Network Stream
#
# rtsp://192.168.1.33:8554/stream
#

pid=$(ps -ef | grep vlc | grep -v grep | awk '{ print $2 }')

if [ "$1" = "stop" ]; then
   if [ -z "$pid" ]; then
      echo "VLC not running"
   else
      echo "Stopping VLC pid: " $pid
      kill -9 $pid
      /home/pjmd/bin/ipcam-capture.sh start
   fi
else
   if [ -n "$pid" ]; then
      echo "VLC already running"
   else
      echo "Starting VLC "
      nohup vlc v4l2:// :v4l2-dev=/dev/video0 :v4l2-width=640 :v4l2-height=360 --sout="#transcode{vcodec=h264,vb=800,scale=1}:rtp{sdp=rtsp://192.168.1.33:8554/stream}" -I dummy  > ~/tmp/output.log 2>&1 &
      /home/pjmd/bin/ipcam-capture.sh stop
   fi
fi
