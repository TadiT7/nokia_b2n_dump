#!/system/bin/sh

fqcaudio=`getprop debug.sys.fqcaudio`
setenforce 0 > /dev/null 2>&1
killall -9 tinyhostless > /dev/null 2>&1
killall -9 tinymix > /dev/null 2>&1
case "$fqcaudio" in
	"11")
		tinymix 'AIF1_CAP Mixer SLIM TX7' 1 > /dev/null 2>&1
		tinymix 'SLIM TX7 MUX' 'DEC7' > /dev/null 2>&1
		tinymix 'ADC MUX7' 'DMIC' > /dev/null 2>&1
		tinymix 'DMIC MUX7' 'DMIC1' > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX dev_token' 65536 > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 1 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer SLIM_0_TX' 1 > /dev/null 2>&1
		tinyhostless -D 0 -P 43 -C 5 -p 1024 -n 2 -c 1 -r 48000 -T 16 > /dev/null 2>&1 &
		;;
	"10")
		tinymix 'AIF1_CAP Mixer SLIM TX7' 0 > /dev/null 2>&1
		tinymix 'SLIM TX7 MUX' 'ZERO' > /dev/null 2>&1
		tinymix 'ADC MUX7' 'AMIC' > /dev/null 2>&1
		tinymix 'DMIC MUX7' 'ZERO' > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 0 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer SLIM_0_TX' 0 > /dev/null 2>&1
		killall -9 tinyhostless > /dev/null 2>&1
		;;
	"21")
		tinymix 'AIF1_CAP Mixer SLIM TX7' 1 > /dev/null 2>&1
		tinymix 'SLIM TX7 MUX' 'DEC7' > /dev/null 2>&1
		tinymix 'ADC MUX7' 'DMIC' > /dev/null 2>&1
		tinymix 'DMIC MUX7' 'DMIC3' > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX dev_token' 65536 > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 1 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer SLIM_0_TX' 1 > /dev/null 2>&1
		tinyhostless -D 0 -P 43 -C 5 -p 1024 -n 2 -c 1 -r 48000 -T 16 > /dev/null 2>&1 &
		;;
	"20")
		tinymix 'AIF1_CAP Mixer SLIM TX7' 0 > /dev/null 2>&1
		tinymix 'SLIM TX7 MUX' 'ZERO' > /dev/null 2>&1
		tinymix 'ADC MUX7' 'AMIC' > /dev/null 2>&1
		tinymix 'DMIC MUX7' 'ZERO' > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 0 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer SLIM_0_TX' 0 > /dev/null 2>&1
		killall -9 tinyhostless > /dev/null 2>&1
		;;
	"31")
		tinymix 'USB_AUDIO_RX dev_token' 65536 > /dev/null 2>&1
		tinymix 'USB_AUDIO_TX dev_token' 65537 > /dev/null 2>&1
		tinymix 'USB_AUDIO_TX Channels' 'Two' > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 1 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer USB_AUDIO_TX' 1 > /dev/null 2>&1
		tinyhostless -D 0 -P 43 -C 43 -p 1024 -n 2 -c 1 -r 48000 -T 16 > /dev/null 2>&1 &
		;;
	"30")
		tinymix 'USB_AUDIO_TX Channels' 'One' > /dev/null 2>&1
		tinymix 'USB_DL_HL Switch' 0 > /dev/null 2>&1
		tinymix 'USB_AUDIO_RX Port Mixer USB_AUDIO_TX' 0 > /dev/null 2>&1
		killall -9 tinyhostless > /dev/null 2>&1
		;;
	*)
		;; #Do nothing
esac
