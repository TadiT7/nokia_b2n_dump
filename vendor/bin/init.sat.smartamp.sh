#!/system/bin/sh

main_sound_card=`cat /proc/asound/cards|grep "sdm660tashasndc"|sed 's/ /\t/g'|cut -f 2`
/system/bin/tinymix -D ${main_sound_card} 'TERT_MI2S_RX Audio Mixer MultiMedia1' 1 > /dev/null 2>&1
/system/bin/tinyplay /vendor/etc/silence_48k-samplerate.wav -D ${main_sound_card} > /dev/null 2>&1 &
sleep 2 > /dev/null 2>&1
/system/bin/tinymix -D ${main_sound_card} 'TERT_MI2S_RX Audio Mixer MultiMedia1' 0 > /dev/null 2>&1
killall -9 /system/bin/tinyplay > /dev/null 2>&1

