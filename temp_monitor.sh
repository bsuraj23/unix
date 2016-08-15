#!/usr/bin/ksh
###############################################################################
# This script will check the ambient temperature and the temperature of
# the three CPUs.
# Temperatures are saved in log files, which could be read by monitoring
# software. (Such as Foglight).
# If the temperatures rise above the set thresholds, an email will be sent
# to the specified recipients.
#
# Monitoring is performed in an infinite loop, with a specified wait between
# iterations and emails sent once per a set number of loop iterations.
###############################################################################
#
# U S A G E
#
# Run in the background
#
# > nohup ./temp_monitor.sh &
#
###############################################################################
# 
# C H A N G E    H I S T O R Y
#
# Date        Reference   Author      Comments
# ----------  ----------  ----------  --------------------------------------
# 2010.03.10                          Initial version
# 2010.03.16                          Modified log file format
#                                     Altered check for running scripts
#
###############################################################################

# --------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------

#File name for log file
#If you change this, you must change the clean up in temp_monitor_check.sh
logprefix=templog

#Error log file name is the name of this shell script with the suffix "err"
errorfile=`echo $(basename $0) | cut -f 1 -d '.'`".err"

#Loop counter
count=0

#Email flag. 0 = sending disabled, 1 = sending enabled
email=0

#Minimum number of loop iterations between emails
loopreset=6

#Number of seconds between loop iterations
sleeptime=300

#Email recipients, comma seperated
emailto=a@a.com,b@b.com

# --------------------------------------------------------------------------
# Code start
# --------------------------------------------------------------------------

# Only allow one instance of this script
# Exclude "grep" so the count isn't skewed by grep-ing for the processes
if ps -ef | grep -v "grep" | grep "temp_monitor.sh" > /dev/null
then

   echo "$(date +%Y%m%d)[$(date +%R)] Script is already running" >> $errorfile
   exit

fi

# Loop for ever
while [ true ]
do

   # Get the current date and use it as the suffix for the log file
   logsuffix=`date +%Y%m%d`

   # Get the current time to use as a timestamp
   timestamp=`date +%R`

   # Gather system temperatures
   ambient=`echo $(/usr/platform/sun4u/sbin/prtdiag -v | grep -i "ambient") | cut -f 2 -d ' '`
   cpu1=`echo $(/usr/platform/sun4u/sbin/prtdiag -v | grep -i "cpu 1") | cut -f 3 -d ' '`
   cpu2=`echo $(/usr/platform/sun4u/sbin/prtdiag -v | grep -i "cpu 2") | cut -f 3 -d ' '`
   cpu3=`echo $(/usr/platform/sun4u/sbin/prtdiag -v | grep -i "cpu 3") | cut -f 3 -d ' '`

   # Write temperatures to log file
   echo "[$timestamp]Ambient:$ambient,CPU1:$cpu1,CPU2:$cpu2,CPU3:$cpu3" >> $logprefix.$logsuffix

   # Send email depending on values of temperatures
   if [[ $ambient -gt 35 || $cpu1 -gt 60 || $cpu2 -gt 55 || $cpu3 -gt 50 ]] then

      # If email sending is allowed then send
      # Disable emailing
      if [[ email -eq 1 ]] then

         email=0
         echo "$(hostname) is running very hot
Ambient: $ambient, CPU1: $cpu1, CPU2: $cpu2, CPU3: $cpu3" | mailx -r "noreply@$(hostname)" -s "$(hostname) temperature warning" $emailto

      fi

   elif [[ $ambient -gt 30 || $cpu1 -gt 55 || $cpu2 -gt 50 || $cpu3 -gt 45 ]] then

      # If email sending is allowed then send
      # Disable emailing
      if [[ email -eq 1 ]] then

         email=0
         echo "$(hostname) is running hot
Ambient: $ambient, CPU1: $cpu1, CPU2: $cpu2, CPU3: $cpu3" | mailx -r "noreply@$(hostname)" -s "$(hostname) temperature warning" $emailto

      fi

   fi

   # Increment the loop counter
   count=`expr $count + 1`

   # Reset the loop counter and enable email sending when loopreset has been reached
   if [[ $count -eq $loopreset ]] then

      count=0
      email=1

   fi

   # Sleep for a set time
   sleep $sleeptime

done