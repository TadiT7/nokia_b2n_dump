#!/system/bin/sh

if [ "x$(getprop init.svc.adbd)" != "xrunning" ]; then
  exit 0
fi

#enable flag and trace time
x=`getprop debug.atrace.time`
if [ "${x}" == "" ]; then
    echo "atrace-log not enable"
    exit 0
fi

timestamp=`date +'%Y-%m-%d-%H-%M-%S'`

echo tracing-time="$x"
echo "atrace-log enabled, start to capture log"   
[ ! -d $EXTERNAL_STORAGE/atrace-log ] && mkdir $EXTERNAL_STORAGE/atrace-log

y=`getprop debug.atrace.option`
if [ "${y}" == "" ]; then
  # default trace option
  y="-d -f -i -l -s -w"  
fi

# enable all tracing item
#setprop debug.atrace.tags.enableflags 0x3ff 

# enable vibration
echo 150 > /sys/class/timed_output/vibrator/enable
# atrace dump ...
atrace $y -t $x > $EXTERNAL_STORAGE/atrace-log/atrace-${x}_$timestamp.txt && echo " \n output log file is done !!!"
echo 150 > /sys/class/timed_output/vibrator/enable


