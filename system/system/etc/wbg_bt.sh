#!/bin/bash

CMD=`getprop persist.sys.wbg.bt`
TESTITEM=`getprop persist.sys.wbg.bt.testitem`
PRO_CHANNEL=`getprop persist.sys.wbg.bt.channel`
PRO_PAYLOAD=`getprop persist.sys.wbg.bt.payload`
PRO_POWER=`getprop persist.sys.wbg.bt.power`
PRO_SLOT=`getprop persist.sys.wbg.bt.slot`
RX_DATA=`getprop persist.sys.wbg.bt.package`
LE_PACKAGE=`getprop persist.sys.wbg.bt.lepackage`

LOG="/data/data/com.fihtdc.wbgtesttool/wbg_bt.log"
BTRXLOG="/data/data/com.fihtdc.wbgtesttool/bt_rx.log"
LERXLOG="/data/data/com.fihtdc.wbgtesttool/le_rx.log"

RX_ADDRESS="EE FF C0 88 00 00"
TX_ADDRESS="06 05 04 03 02 01"

function BT_Config(){
	# set channel
	CHANNEL=$PRO_CHANNEL
	expr "$1=\"$CHANNEL\""
	# set pay_load
	if [ $PRO_PAYLOAD == "All0" ]; then
		PAY_LOAD="00"
		expr "$2=\"$PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "All1" ]; then
		PAY_LOAD="01"
		expr "$2=\"$PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "ZOZO" ]; then
		PAY_LOAD="02"
		expr "$2=\"$PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "FOFO" ]; then
		PAY_LOAD="03"
		expr "$2=\"$PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "Ordered" ]; then
		PAY_LOAD="04"
		expr "$2=\"$PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "PRBS9" ]; then
		PAY_LOAD="04"
		expr "$2=\"$PAY_LOAD\""
	fi
	# set Slot
	if [ $PRO_SLOT == "DH1" ]; then
		SLOT="04"
		PAYLOAD_LENGTH_1="1B"
		PAYLOAD_LENGTH_2="00"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	elif [ $PRO_SLOT == "DH3" ]; then
		SLOT="0B"
		PAYLOAD_LENGTH_1="B7"
		PAYLOAD_LENGTH_2="00"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	elif [ $PRO_SLOT == "DH5" ]; then
		SLOT="0F"
		PAYLOAD_LENGTH_1="53"
		PAYLOAD_LENGTH_2="01"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	elif [ $PRO_SLOT == "2DH1" ]; then
		SLOT="24"
		PAYLOAD_LENGTH_1="36"
		PAYLOAD_LENGTH_2="00"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	elif [ $PRO_SLOT == "2DH3" ]; then
		SLOT="2A"
		PAYLOAD_LENGTH_1="6F"
		PAYLOAD_LENGTH_2="01"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	elif [ $PRO_SLOT == "2DH5" ]; then
		SLOT="2E"
		PAYLOAD_LENGTH_1="A7"
		PAYLOAD_LENGTH_2="02"
		expr "$3=\"$SLOT\""
		expr "$5=\"$PAYLOAD_LENGTH_1\""
		expr "$6=\"$PAYLOAD_LENGTH_2\""
	fi
	# set power
	if [ $PRO_POWER == "Class1" ]; then
		POWER="09"
		expr "$4=\"$POWER\""
	elif [ $PRO_POWER == "Class2" ]; then
		POWER="07"
		expr "$4=\"$POWER\""
	elif [ $PRO_POWER == "Class3" ]; then
		POWER="05"
		expr "$4=\"$POWER\""
	fi
}

function BT_LE_Config(){
	# set channel
	CHANNEL=$PRO_CHANNEL
	expr "$1=\"$CHANNEL\""
	# set pay_load
	if [ $PRO_PAYLOAD == "PRBS9" ]; then
		LE_PAY_LOAD="00"
		expr "$2=\"$LE_PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "ZOZO" ]; then
		LE_PAY_LOAD="02"
		expr "$2=\"$LE_PAY_LOAD\""
	elif [ $PRO_PAYLOAD == "FOFO" ]; then
		LE_PAY_LOAD="01"
		expr "$2=\"$LE_PAY_LOAD\""
	fi
}

function HCI_Rest(){
	btconfig reset
	sleep 0.5
}

function Bluetooth_GetRxdata(){

	echo "Bluetooth_GetRxdata" >> $LOG
	btconfig rawcmd 3F 04 02 > $BTRXLOG
	cat $BTRXLOG >> $LOG

	HCI_BIT="0"
	# take out RX hci data

	HCI_RAW_DATA_CH1=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$13 $12 $11 $10 } ' $BTRXLOG))
	HCI_RAW_DATA_CH2=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$45 $44 $43 $42 } ' $BTRXLOG))
	HCI_RAW_DATA_CH3=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$77 $76 $75 $74 } ' $BTRXLOG))
	HCI_RAW_DATA_CH4=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$109 $108 $107 $106 } ' $BTRXLOG))
	HCI_RAW_DATA_CH5=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$141 $140 $139 $138 } ' $BTRXLOG))
	TOTAL_HCI_RAW_DATA=`busybox expr $HCI_RAW_DATA_CH1 + $HCI_RAW_DATA_CH2 + $HCI_RAW_DATA_CH3 + $HCI_RAW_DATA_CH4 + $HCI_RAW_DATA_CH5`

	echo "HCI_RAW_DATA_CH1:"$HCI_RAW_DATA_CH1 >> $LOG
	echo "HCI_RAW_DATA_CH2:"$HCI_RAW_DATA_CH2 >> $LOG
	echo "HCI_RAW_DATA_CH3:"$HCI_RAW_DATA_CH3 >> $LOG
	echo "HCI_RAW_DATA_CH4:"$HCI_RAW_DATA_CH4 >> $LOG
	echo "HCI_RAW_DATA_CH5:"$HCI_RAW_DATA_CH5 >> $LOG
	echo "TOTAL_HCI_RAW_DATA:"$TOTAL_HCI_RAW_DATA >> $LOG

	RESET_RAW_DATA_CH1=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$17 $16 $15 $14 } ' $BTRXLOG))
	RESET_RAW_DATA_CH2=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$49 $48 $47 $46 } ' $BTRXLOG))
	RESET_RAW_DATA_CH3=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$81 $80 $79 $78 } ' $BTRXLOG))
	RESET_RAW_DATA_CH4=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$113 $112 $111 $110 } ' $BTRXLOG))
	RESET_RAW_DATA_CH5=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$145 $144 $143 $142 } ' $BTRXLOG))
	TOTAL_RESET_RAW_DATA=`busybox expr $RESET_RAW_DATA_CH1 + $RESET_RAW_DATA_CH2 + $RESET_RAW_DATA_CH3 + $RESET_RAW_DATA_CH4 + $RESET_RAW_DATA_CH5`

	echo "RESET_RAW_DATA_CH1:"$RESET_RAW_DATA_CH1 >> $LOG
	echo "RESET_RAW_DATA_CH2:"$RESET_RAW_DATA_CH2 >> $LOG
	echo "RESET_RAW_DATA_CH3:"$RESET_RAW_DATA_CH3 >> $LOG
	echo "RESET_RAW_DATA_CH4:"$RESET_RAW_DATA_CH4 >> $LOG
	echo "RESET_RAW_DATA_CH5:"$RESET_RAW_DATA_CH5 >> $LOG
	echo "TOTAL_RESET_RAW_DATA:"$TOTAL_RESET_RAW_DATA >> $LOG

	HCI_BIT=`busybox expr $TOTAL_HCI_RAW_DATA - $TOTAL_RESET_RAW_DATA`

	# Count total bit = TOTAL_HCI_BIT * Max_payload_length * 5 channels
	# Max_payload_length: DH1(27), DH3(183), DH5(339), 2DH1(54), 2DH3(367), 2DH5(679)
	if [ $PRO_SLOT == "DH1" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 27 \* 5`
	elif [ $PRO_SLOT == "DH3" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 183 \* 5`
	elif [ $PRO_SLOT == "DH5" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 339 \* 5`
	elif [ $PRO_SLOT == "2DH1" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 54 \* 5`
	elif [ $PRO_SLOT == "2DH3" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 367 \* 5`
	elif [ $PRO_SLOT == "2DH5" ]; then
		TOTAL_HCI_BIT=`busybox expr $HCI_BIT \* 679 \* 5`
	else
		exit -1
	fi
	echo "TOTAL_HCI_BIT:"$TOTAL_HCI_BIT >> $LOG
	# setprop "total bit value" to persist.sys.wbg.bt.rxreport
	setprop persist.sys.wbg.bt.rxreport $TOTAL_HCI_BIT
	# delete capture .log file
	rm $BTRXLOG
}

function Bluetooth_GetLeRxPacketCount(){
	echo "Bluetooth_GetLeRxPacketCount" >> $LOG
	btconfig rawcmd 08 1F > $LERXLOG
	cat $LERXLOG >> $LOG

	# parse le package size

	TOTAL_PACKET_BIT=$(busybox printf "%d" $(busybox awk 'NR==12{ print "0x"$12 $11 }' $LERXLOG))
	echo "TOTAL_PACKET_BIT:"$TOTAL_HCI_BIT >> $LOG
	# setprop "total bit value" to persist.sys.wbg.bt.rxreport
	setprop persist.sys.wbg.bt.lerxreport $TOTAL_PACKET_BIT
	# delete capture .log file
	rm $LERXLOG
}

function Bluetooth_Module_on(){
	# btconfig tool don't need to enable chip
	wdsdaemon -su&

	rm $LOG
}

function Bluetooth_Module_off(){
# need to carify the Bluetooth power consumption, when using btconfig tool
	HCI_Rest
}

function Bluetooth_Test(){
	if [ "$CMD" == "btstart" ]; then
		btconfig edutm
		sleep 0.1
	elif [ "$CMD" == "btreset" ]; then
		HCI_Rest
	fi
}

function Bluetooth_TxMode(){
	if [ "$CMD" == "btstart" ]; then
		BT_Config CHANNEL PAY_LOAD SLOT POWER PAYLOAD_LENGTH_1 PAYLOAD_LENGTH_2
		# command start
		HCI_Rest
		btconfig rawcmd 3F 04 04 $CHANNEL $CHANNEL $CHANNEL $CHANNEL $CHANNEL $PAY_LOAD $SLOT 00 $POWER 01 $TX_ADDRESS 00 $PAYLOAD_LENGTH_1 $PAYLOAD_LENGTH_2 00
		sleep 0.1
	elif [ "$CMD" == "btreset" ]; then
		HCI_Rest
	fi
}

function Bluetooth_Rxmode(){
	if [ "$RX_DATA" == "false" ]; then
		if [ "$CMD" == "btstart" ]; then
			BT_Config CHANNEL PAY_LOAD SLOT POWER PAYLOAD_LENGTH_1 PAYLOAD_LENGTH_2
			# command start
			HCI_Rest
			btconfig rawcmd 3F 04 06 $CHANNEL $CHANNEL $CHANNEL $CHANNEL $CHANNEL 04 $SLOT 00 09 01 $RX_ADDRESS 00 $PAYLOAD_LENGTH_1 $PAYLOAD_LENGTH_2 00
			sleep 0.1
		elif [ "$CMD" == "btreset" ]; then
			HCI_Rest
		fi
	elif [ "$RX_DATA" == "true" ]; then
		Bluetooth_GetRxdata
	fi
}

function Bluetooth_LeTxMode(){
	if [ "$CMD" == "btstart" ]; then
		BT_LE_Config CHANNEL LE_PAY_LOAD
		# command start
		HCI_Rest
		btconfig rawcmd 08 1E $CHANNEL 25 $LE_PAY_LOAD
		sleep 0.1
	elif [ "$CMD" == "btreset" ]; then
		HCI_Rest
	fi
}

function Bluetooth_LeRxmode(){
	if [ "$LE_PACKAGE" == "false" ]; then
		if [ "$CMD" == "btstart" ]; then
			BT_LE_Config CHANNEL
			# command start
			HCI_Rest
			btconfig rawcmd 08 1D $CHANNEL
			sleep 0.1
		elif [ "$CMD" == "btreset" ]; then
			HCI_Rest
		fi
	elif [ "$LE_PACKAGE" == "true" ]; then
		Bluetooth_GetLeRxPacketCount
	fi
}

function Bluetooth_CW(){
	if [ "$CMD" == "btstart" ]; then
		# set channel
		BT_Config CHANNEL
		# command start
		HCI_Rest
		# reference 80-VH397-23
		btconfig rawcmd 3F 04 09 05 $CHANNEL 07 04 01 00 00 00 00
		sleep 0.1
	elif [ "$CMD" == "btreset" ]; then
		HCI_Rest
	fi
}


case $TESTITEM in
	"enablebt")
			Bluetooth_Module_on
			;;
	"disablebt")
			Bluetooth_Module_off
			;;
	"enabletest")
			Bluetooth_Test
			;;
	"enabletx")
			Bluetooth_TxMode
			;;
	"enablerx")
			Bluetooth_Rxmode
			;;
	"enableletx")
			Bluetooth_LeTxMode
			;;
	"enablelerx")
			Bluetooth_LeRxmode
			;;
	"enablecw")
			Bluetooth_CW
			;;
esac
