#!/bin/bash
# Using 'adb exec-out' to avoid carriage return issues and 'run-as' to access app data
adb exec-out run-as com.example.skill_tube cat app_flutter/talker_logs.txt > lib/log.txt
echo "Logs retrieved to lib/log.txt"
