#!/bin/bash

# Calculate Uptime
let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days %02d hours %02d minutes %02d seconds" "$days" "$hours" "$mins" "$secs"`

# Calculate rough CPU and GPU temperatures
let cpuTempC
let cpuTempF
let gpuTempC
let gpuTempF
if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
  cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && cpuTempF=$((cpuTempC*9/5+32))
fi
if [[ -f "/opt/vc/bin/vcgencmd" ]]; then
  if gpuTempC=$(/opt/vc/bin/vcgencmd measure_temp); then
    gpuTempC=${gpuTempC:5:2}
    gpuTempF=$((gpuTempC*9/5+32))
  else
    gpuTempC=""
  fi
fi

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.
  : .~.'~'.~. :          Uptime : ${UPTIME}
 ~ (   ) (   ) ~         Memory : `cat /proc/meminfo | grep MemFree | awk {' printf "%.0f", $2/1024 '}`MB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'printf "%.0f", $2/1024'}`MB (Total)
( : '~'.~.'~' : ) Load Averages : ${one}, ${five}, ${fifteen} (1, 5, 15 min)
 ~ .~ (   ) ~. ~   IP Addresses : `ip addr show eth0 | grep "inet\b" | awk '{ print $2 }' | cut -d/ -f1` and `wget -q -O - http://icanhazip.com/ | tail`
  (  : '~' :  )     Temperature : CPU: ${cpuTempC}°C/${cpuTempF}°F GPU: ${gpuTempC}°C/${gpuTempF}°F
   '~ .~~~. ~'       Disk Space :   Root : `df -h | grep -E '^/dev/root' | awk '{ print $3 "/" $2 " (" $5 " used)" }'`
       '~'                          Data : `df -h | grep -E '/mnt/data$' | awk '{ print $3 "/" $2 " (" $5 " used)" }'`
                                  Backup : `df -h | grep -E '/mnt/backup$' | awk '{ print $3 "/" $2 " (" $5 " used)" }'`
$(tput sgr0)"
