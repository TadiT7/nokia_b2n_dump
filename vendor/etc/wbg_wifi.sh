#!/system/bin/sh
#
#WBG WIFI script
#

usage() {
    echo "usage: Please follow WBG user guide to setup your test environment"
}

# init local variables
SUCCESS="0"
INVALID_OPT="1"
ERR_HEADER_VERSION="2"
ERR_OPENFAILED="3"
ERR_XDIGIT="4"
ERR_NOMATCH="0xff"
Rateindex=1;

fWlanStatus() {
    WirelessToolPath="/system/bin/iw"
    Interface="wlan0"

    ret="nonAvailable"
    if [ -x $WirelessToolPath ]; then
        wlanStatus=$(/system/bin/iw dev wlan0 info 2>&1 | sed -n '5 p' | cut -d \  -f 2)
        if [ $wlanStatus = "managed" ]; then
            ret="Available"
        fi
    else
        echo "Wireless tool iw isn't exsit" >> $LOGFILENAME
    fi
    echo $ret
}

WiFi_Module() {
    if [ $1 = "ON" ]; then
        insmod /vendor/lib/modules/qca_cld3/qca_cld3_wlan.ko
		ifconfig wlan0 up
		echo 5 > /sys/module/wlan/parameters/con_mode
        echo "insmod /vendor/lib/modules/qca_cld3/qca_cld3_wlan.ko" 		>> $LOGFILENAME

        sleep 1

        WiFi_status=$(fWlanStatus)

        echo "WiFi_status =" $WiFi_status               >> $LOGFILENAME

        if [ $WiFi_status = "Available" ]; then
            lsmod > "/data/data/com.fihtdc.wbgtesttool/insmodcheck.txt"
            echo lsmod                                  >> $LOGFILENAME
            chmod 777 "/data/data/com.fihtdc.wbgtesttool/insmodcheck.txt"
            echo "WiFi_Module ON successful"            >> $LOGFILENAME
        else
            echo "WiFi_Module ON failed"                >> $LOGFILENAME
        fi

    elif [ $1 = "OFF" ]; then
        rmmod wlan
        lsmod > "/data/data/com.fihtdc.wbgtesttool/rmmodcheck.txt"
        echo lsmod                                      >> $LOGFILENAME
        chmod 777 "/data/data/com.fihtdc.wbgtesttool/rmmodcheck.txt"
        echo "WiFi_Module OFF successful"               >> $LOGFILENAME
    else
        echo "WiFi_Module: Invalid option parameter"    >> $LOGFILENAME
    fi
}


WiFi_Enable() {
    if [ $1 = "ON" ]; then
        insmod /vendor/lib/modules/qca_cld3/qca_cld3_wlan.ko
		ifconfig wlan0 up
		echo 5 > /sys/module/wlan/parameters/con_mode
        echo "insmod /vendor/lib/modules/qca_cld3/qca_cld3_wlan.ko" 		>> $LOGFILENAME

        sleep 1

        WiFi_status=$(fWlanStatus)

        echo "WiFi_status = "$WiFi_status               >> $LOGFILENAME

        if [ $WiFi_status = "Available" ]; then
            lsmod > "/data/data/com.fihtdc.wbgtesttool/insmodcheck.txt"
            chmod 777 "/data/data/com.fihtdc.wbgtesttool/insmodcheck.txt"
            echo "WiFi_Enable successful"               >> $LOGFILENAME
        else
            echo "WiFi_Enable failed"                   >> $LOGFILENAME
        fi

    elif [ $1 = "OFF" ]; then
        rmmod wlan
        sleep 1
        lsmod > "/data/data/com.fihtdc.wbgtesttool/rmmodcheck.txt"
        chmod 777 "/data/data/com.fihtdc.wbgtesttool/rmmodcheck.txt"
        echo "WiFi disable successful"                  >> $LOGFILENAME
    else
        echo "WiFi_Enable: Invalid option parameter"    >> $LOGFILENAME
    fi
}


fWLANmode() {
    #TCMD_WLAN_MODE_NOHT      0
    #TCMD_WLAN_MODE_HT20      1
    #TCMD_WLAN_MODE_HT40PLUS  2
    #TCMD_WLAN_MODE_CCK       4
    #TCMD_WLAN_MODE_VHT20     5
    #TCMD_WLAN_MODE_VHT40PLUS 6
    #TCMD_WLAN_MODE_VHT80_0   8

    echo "format = vendor.wbg.wifi.format = " $format       >> $LOGFILENAME
    echo "BAND_Width = vendor.wbg.wifi.ht = " $BAND_Width  >> $LOGFILENAME


    case $STANDARD in
        "802.11a")
            echo "0"
        ;;
        "802.11g")
            echo "0"
        ;;
        "802.11n")
        if [ $BAND_Width == "40" ]; then
            echo "2"
        else
            echo "1"
        fi
        ;;
        "802.11b")
            echo "4"
        ;;
        "802.11ac")
        if [ $BAND_Width == "40" ]; then
            echo "6"
        elif [ $BAND_Width == "80" ]; then
            echo "8"
        else
            echo "5"
        fi
        ;;
        *)
            echo "default #TCMD_WLAN_MODE_NOHT      0"  >> $LOGFILENAME
            echo "0" #Default TCMD_WLAN_MODE_NOHT
        ;;
    esac
}
fWLANmodeToStr() {
    echo "WLANmode => "                             >> $LOGFILENAME
	    case $1 in
        "0")
        echo "#TCMD_WLAN_MODE_NOHT      0"          >> $LOGFILENAME
        ;;
        "1")
        echo "#TCMD_WLAN_MODE_HT20      1"          >> $LOGFILENAME
        ;;
        "2")
        echo "#TCMD_WLAN_MODE_HT40PLUS  2"          >> $LOGFILENAME
        ;;
		"4")
        echo "#TCMD_WLAN_MODE_CCK       4"          >> $LOGFILENAME
        ;;
		"6")
        echo "#TCMD_WLAN_MODE_VHT40PLUS 6"          >> $LOGFILENAME
        ;;
		"8")
        echo "#TCMD_WLAN_MODE_VHT80_0   8"          >> $LOGFILENAME
        ;;
        *)
        echo "NOT SUPPORT  $1"                    >> $LOGFILENAME
        ;;
    esac
}

fRateindex() {
    Rateindex=0
    echo RATE = vendor.wbg.wifi.rate =  $RATE >> $LOGFILENAME

    #802.11ag (WBG: 6, 9, 12, 18, 24, 36, 48, 54)
    if [ $STANDARD == "802.11a" ] || [ $STANDARD == "802.11g" ]; then

        echo STANDARD=$STANDARD >> $LOGFILENAME

        if [ "$RATE" == "1" ]; then

            Rateindex=1

        elif [ "$RATE" == "2" ]; then

            Rateindex=2

        elif [ "$RATE" == "5.5" ]; then

            Rateindex=3

        elif [ "$RATE" == "11" ]; then

            Rateindex=6

        elif [ "$RATE" == "6" ]; then

            Rateindex=4

        elif [ "$RATE" == "9" ]; then

            Rateindex=5

        elif [ "$RATE" == "12" ]; then

            Rateindex=7

        elif [ "$RATE" == "18" ]; then

            Rateindex=8

        elif [ "$RATE" == "24" ]; then

            Rateindex=10

        elif [ "$RATE" == "36" ]; then

            Rateindex=12

        elif [ "$RATE" == "48" ]; then

            Rateindex=13

        elif [ "$RATE" == "54" ]; then

            Rateindex=14

        fi

    elif [ $STANDARD == "802.11b" ]; then

        echo STANDARD=$STANDARD >> $LOGFILENAME

        if [ "$RATE" == "1" ]; then

            Rateindex=1

        elif [ "$RATE" == "2" ]; then

            Rateindex=2

        elif [ "$RATE" == "5.5" ]; then

            Rateindex=3

        elif [ "$RATE" == "11" ]; then

            Rateindex=6

        fi

    elif [ $STANDARD == "802.11n" ] || [ $STANDARD == "802.11ac" ]; then

        echo STANDARD=$STANDARD >> $LOGFILENAME

        if [ "$RATE" == "0" ]; then

            Rateindex=15

        elif [ "$RATE" == "1" ]; then

            Rateindex=16

        elif [ "$RATE" == "2" ]; then

            Rateindex=17

        elif [ "$RATE" == "3" ]; then

            Rateindex=18

        elif [ "$RATE" == "4" ]; then

            Rateindex=19

        elif [ "$RATE" == "5" ]; then

            Rateindex=20

        elif [ "$RATE" == "6" ]; then

            Rateindex=21

        elif [ "$RATE" == "7" ]; then

            Rateindex=22

        elif [ "$RATE" == "8" ]; then

            Rateindex=23

        elif [ "$RATE" == "9" ]; then

            Rateindex=24

        elif [ "$RATE" == "10" ]; then

            Rateindex=25

        elif [ "$RATE" == "11" ]; then

            Rateindex=26

        elif [ "$RATE" == "12" ]; then

            Rateindex=27

        elif [ "$RATE" == "13" ]; then

            Rateindex=28

        elif [ "$RATE" == "14" ]; then

            Rateindex=29

        elif [ "$RATE" == "15" ]; then

            Rateindex=30

        fi

    fi


    #otherwise, no supported Rateindex
    if [ "$Rateindex" == "0" ]; then

        echo RATE =$RATE is not supported in $STANDARD >> $LOGFILENAME

    fi

    echo "fRateindex()," Rateindex=$Rateindex >> $LOGFILENAME

    echo $Rateindex
}

#This is channel to frequency mapping functions
fWlanATSetWifiFreq() {
    channel_no=$(getprop vendor.wbg.wifi.channel)
    freq=0

    if [ -z $channel_no ]; then
        channel_no=7
    fi

    #ch1-13 is supported
    if [ "$channel_no" -ge 1 ]; then

        if [ "$channel_no" -le 13 ]; then

            freq=$(( 2407 + (channel_no * 5) ))

        fi

    fi

    #ch34-65 is supported
    if [ "$channel_no" -ge 34 ]; then

        if [ "$channel_no" -le 65 ]; then

            freq=$(( 5170 + ((channel_no - 34) * 5) ))

        fi

    fi

    #ch100-146 is supported
    if [ "$channel_no" -ge 100 ]; then

        if [ "$channel_no" -le 146 ]; then

            freq=$(( 5170 + ((channel_no - 34) * 5) ))

        fi

    fi

    #ch149-165 is supported
    if [ "$channel_no" -ge 149 ]; then

        if [ "$channel_no" -le 165 ]; then

            freq=$(( 5170 + ((channel_no - 34) * 5) ))

        fi

    fi

    #ch14 is supported
    if [ "$channel_no" == 14 ]; then

        freq=2484

    fi

    #not supported channels
    if [ $freq == 0 ]; then
        echo "channel " $channel_no "is not supported..."   >> $LOGFILENAME
        echo "only 1-14, 34-65, 100-146, 149-165 is supported..."   >> $LOGFILENAME
    fi


    echo "fWlanATSetWifiFreq(), channel_no="$channel_no", freq="$freq   >> $LOGFILENAME
    echo $freq
}

fWlanATSetWifiAntenna() {
    # Chain 0 --> 1 (myftm)
    # Chain 1 --> 2
    # Both    --> 3

    Antenna=$(getprop vendor.wbg.wifi.Antenna)
    echo "fWlanATSetWifiAntenna(), Antenna="$Antenna    >> $LOGFILENAME

    case $Antenna in
        "0")
        echo "3"
        ;;
        "1")
        echo "1"
        ;;
        "2")
        echo "2"
        ;;
        *)
        echo "1"  #default
        ;;
    esac
}

fWlanATSetWifiBand() {
    #AT_WIBAND_20M   = 0,  /* 20MHz*/
    #AT_WIBAND_40M   = 1,  /* 40MHz*/
    #AT_WIBAND_80M   = 2,  /* 80MHz*/
    #AT_WIBAND_160M  = 3,  /*160MHz*/

    BAND_Width=`getprop vendor.wbg.wifi.ht`
    echo "fWlanATSetWifiBand(), BAND_Width="$BAND_Width >> $LOGFILENAME

    case $BAND_Width in
        "20")
        echo "0"
        ;;
        "40")
        echo "1"
        ;;
        "80")
        echo "2"
        ;;
        *)
        echo "1"  #default
        ;;
    esac

}

WiFi_txmode() {
    if [ $1 == "ON" ]; then
        WLANmode=$(fWLANmode)
        Rateindex=$(fRateindex)
        Freq=$(fWlanATSetWifiFreq)
        TPC="0" #TPC_TX_PWR
        #TPC="2" #TPC_TGT_PWR, TxPowerAuto
        TxPower=$(getprop vendor.wbg.wifi.power)
        Antenna=$(fWlanATSetWifiAntenna)
        TXmode="3" #TCMD_CONT_TX_TX99
        Aggregation="1" #Enable Aggregation

		fWLANmodeToStr $WLANmode

        myftm -J -M $WLANmode -r $Rateindex -f $Freq -c $TPC -p $TxPower -a $Antenna -k $Aggregation -t $TXmode
        echo "myftm -J -M "$WLANmode" -r "$Rateindex" -f "$Freq" -c "$TPC" -p "$TxPower" -a "$Antenna" -k "$Aggregation -t $TXmode >> $LOGFILENAME
    elif [ $1 == "OFF" ]; then
        myftm -J -t 0
        echo "WiFi_txmode OFF ok" >> $LOGFILENAME
    else
        echo "WiFi_txmode: Invalid option parameter" >> $LOGFILENAME
    fi
}

WiFi_cwmode() {
    if [ $1 == "ON" ]; then
        Freq=$(fWlanATSetWifiFreq)
        TPC="4" #TPC_FORCED_GAINIDX
        Antenna=$(fWlanATSetWifiAntenna)
        TXmode="1" #TCMD_CONT_TX_SINE
        Gain_index=$(getprop vendor.wbg.wifi.cw_rg)
        Dac_gain=$(getprop vendor.wbg.wifi.cw_dg)

        echo "WiFi_cwmode(), WLANmode = "$WLANmode", Freq="$Freq", TxPower="$TxPower", Antenna="$Antenna >> $LOGFILENAME

        myftm -J -H 0 -f $Freq -c $TPC -G $Gain_index -D $Dac_gain -a $Antenna -k 10 -t $TXmode
        echo "myftm -J -H 0 -f "$Freq" -c "$TPC" -G "$Gain_index" -D "$Dac_gain" -a "$Antenna" -t "$TXmode" -k 10" >> $LOGFILENAME
    elif [ $1 == "OFF" ]; then
        myftm -J -t 0
        echo "WiFi_cwmode OFF ok"                       >> $LOGFILENAME
    else
        echo "WiFi_cwmode: Invalid option parameter"    >> $LOGFILENAME
    fi
}

WiFi_rxmode() {

    if [ $1 == "ON" ]; then
        WLANmode=$(fWLANmode)
        Rateindex=$(fRateindex)
        Freq=$(fWlanATSetWifiFreq)
        Antenna="1"

        echo "WiFi_rxmode(), WLANmode="$WLANmode", Freq="$Freq >> $LOGFILENAME

        myftm -J -H 0 -M $WLANmode -r $Rateindex -f $Freq -a $Antenna -x 1
        echo "WiFi_rxmode ON ok" >> $LOGFILENAME
        echo "myftm -J -H 0 -M "$WLANmode" -r "$Rateindex" -f "$Freq" -a "$Antenna" -x 1" >> $LOGFILENAME

    elif [ $1 == "OFF" ]; then
        myftm -J -x 0 2>&- | grep "goodPackets" | cut -d \  -f 3 > $RXDFILENAME
        echo "myftm -J -x 0 2>&- | grep "goodPackets" | cut -d \  -f 3" >> $LOGFILENAME
        echo "WiFi_rxmode OFF" >> $LOGFILENAME
    else
        echo "WiFi_rxmode: Invalid option parameter" >> $LOGFILENAME
    fi
}

WiFi_ClearRX() {
    rm $RXDFILENAME
    echo "WiFi_ClearRX, rm" $RXDFILENAME            >> $LOGFILENAME
}

WiFi_GetRxPacketCount() {

    echo Packet Count=$(cat $RXDFILENAME)
    echo $(cat $RXDFILENAME)> $WLFILENAME
    echo "Packet Count=" $(cat $RXDFILENAME)        >> $LOGFILENAME
    chmod 777 $WLFILENAME
    rm $RXDFILENAME
    echo "WiFi_GetRxPacketCount, rm "$RXDFILENAME   >> $LOGFILENAME

}


###
# Main body of script starts here
###

#
# Prologue of this wbg script - wifi part
#

# defin the wifilog.txt for debugging and recording
LOGFILENAME="/data/data/com.fihtdc.wbgtesttool/wifilog.txt"
# defin the file for wifi_rxcount
RXDFILENAME="/data/data/com.fihtdc.wbgtesttool/wifi_rxcount"

echo "=============LIST ALL PROPS FOR INPUT===================" >> $LOGFILENAME

# set up default values of properties
# (01) MODE
MODE=`getprop vendor.wbg.wifi.mode`
echo "Mode (vendor.wbg.wifi.mode):"$MODE                   >> $LOGFILENAME
# intend to show this message to terminal screen
echo "Mode:"$MODE

# (02) STANDARD
STANDARD=`getprop vendor.wbg.wifi.standard`
echo "Standard (vendor.wbg.wifi.standard):"$STANDARD       >> $LOGFILENAME
echo "Standard:"$STANDARD

# (03) format
format=`getprop vendor.wbg.wifi.format`
echo "format (vendor.wbg.wifi.format):"$format             >> $LOGFILENAME

# (04) CHANNEL
CHANNEL=`getprop vendor.wbg.wifi.channel`
echo "CHANNEL (vendor.wbg.wifi.channel):"$CHANNEL          >> $LOGFILENAME

# (05) POWER
POWER=`getprop vendor.wbg.wifi.power`
echo "POWER (vendor.wbg.wifi.power):"$POWER                >> $LOGFILENAME

# (06) RATE
RATE=`getprop vendor.wbg.wifi.rate`
echo "RATE (vendor.wbg.wifi.rate):"$RATE                   >> $LOGFILENAME

# (07) BAND_Width
BAND_Width=`getprop vendor.wbg.wifi.ht`
echo "BAND_Width (vendor.wbg.wifi.ht):"$BAND_Width         >> $LOGFILENAME

# (08) HT
if [ "$STANDARD" == "802.11n" ]; then
    HT=`getprop vendor.wbg.wifi.ht`
    echo "HT (vendor.wbg.wifi.ht):"$HT                     >> $LOGFILENAME
fi

# (09) WLFILENAME
WLFILENAME=`getprop vendor.wbg.wifi.wlfile`
echo "WLFILENAME (vendor.wbg.wifi.wlfile):"$WLFILENAME     >> $LOGFILENAME

# (10) FUNCTION
FUNCTION=`getprop vendor.wbg.wifi.function`
echo "FUNCTION (vendor.wbg.wifi.function):"$FUNCTION       >> $LOGFILENAME

# (11) Antenna
Antenna=`getprop vendor.wbg.wifi.Antenna`
echo "Antenna (vendor.wbg.wifi.Antenna):"$Antenna       >> $LOGFILENAME

# (12) Gain_index
Gain_index=$(getprop vendor.wbg.wifi.cw_rg)
echo "Gain_index (vendor.wbg.wifi.cw_rg):"$Gain_index       >> $LOGFILENAME

# (13) Dac_gain
Dac_gain=$(getprop vendor.wbg.wifi.cw_dg)
echo "Dac_gain (vendor.wbg.wifi.cw_dg):"$Dac_gain       >> $LOGFILENAME

echo "*************END OF PROPS FOR THIS SESSION**************" >> $LOGFILENAME

#below is made for WBG tool interfce
if [   "$FUNCTION" = "removemodule" ]; then
    WiFi_Module "OFF"
elif [ "$FUNCTION" = "insertmodule" ]; then
    WiFi_Module "ON"
elif [ "$FUNCTION" = "enablewifi" ]; then
    WiFi_Enable "ON"
elif [ "$FUNCTION" = "disablewifi" ]; then
    WiFi_Enable "OFF"
elif [ "$FUNCTION" = "enabletx" ]; then
    WiFi_txmode "ON"
elif [ "$FUNCTION" = "disabletx" ]; then
    WiFi_txmode "OFF"
elif [ "$FUNCTION" = "enablerx" ]; then
    WiFi_rxmode "ON"
elif [ "$FUNCTION" = "disablerx" ]; then
    WiFi_rxmode "OFF"
elif [ "$FUNCTION" = "resetCounters" ]; then
    WiFi_ClearRX
elif [ "$FUNCTION" = "reportPacket" ]; then
    WiFi_GetRxPacketCount
elif [ "$FUNCTION" = "enablecw" ]; then
    WiFi_cwmode "ON"
elif [ "$FUNCTION" = "disablecw" ]; then
    WiFi_cwmode "OFF"
else
    echo "FUNCTION: Illegal Parameter" >> $LOGFILENAME
fi

echo "*************END OF THIS WBG EXECUTION SESSION**********" >> $LOGFILENAME
