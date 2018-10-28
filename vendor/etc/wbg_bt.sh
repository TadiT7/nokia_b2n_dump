#!/system/bin/sh

# -----------------------------------------------
# WBG property setting
# -----------------------------------------------
WBG_CMD=`getprop vendor.wbg.bt`
WBG_TESTITEM=`getprop vendor.wbg.bt.testitem`
WBG_CHANNEL=`getprop vendor.wbg.bt.channel`
WBG_PAYLOAD=`getprop vendor.wbg.bt.payload`
WBG_POWER=`getprop vendor.wbg.bt.power`
WBG_SLOT=`getprop vendor.wbg.bt.slot`
WBG_GET_RX_DATA=`getprop vendor.wbg.bt.package`
WBG_GET_LE_PACKAGE=`getprop vendor.wbg.bt.lepackage`
WBG_SET_LE_PHY=`getprop vendor.wbg.bt.setlephy`
WBG_GET_LE_PHY=`getprop vendor.wbg.bt.getlephy`
WBG_GET_LE_PHY_MODULATION=`getprop vendor.wbg.bt.lemodulation`

# -----------------------------------------------
# Variable Define
# -----------------------------------------------
TOOL="btconfig"
UART_TTY=""
RX_ADDRESS="EE FF C0 88 00 00"
TX_ADDRESS="06 05 04 03 02 01"
LOG="/data/data/com.fihtdc.wbgtesttool/bluetooth_wbg.log"
TR_RX_LOG="/data/data/com.fihtdc.wbgtesttool/bluetooth_wbg_rx.log"
LE_RX_LOG="/data/data/com.fihtdc.wbgtesttool/bluetooth_wbg_lerx.log"
WDS_PID_LOG="/data/data/com.fihtdc.wbgtesttool/bluetooth_wbg_wdsdaemon_pid.log"
WDSDAEMON_PID="-1"

function log()
{ 
  # Show log in console
  echo \[WBG\] $1

  # Save log to log file
  echo \[WBG\] $1 >> $LOG
}

function check_wdsdaemon_pid()
{
  log "command check_wdsdaemon_pid"

  pgrep wdsdaemon > $WDS_PID_LOG
  sync

  PS_PID=`cat $WDS_PID_LOG`

  log "Got PID $PS_PID"

  if [ "$PS_PID" == "" ]; then
    WDSDAEMON_PID="-1"
  else
    WDSDAEMON_PID=$PS_PID
  fi
}

function hci_reset()
{
  log "command hci_reset"
  $TOOL $UART_TTY reset >> $LOG
  sleep 0.1
}

function module_on()
{
  echo "EXECUTE TIME: " > $LOG
  date >> $LOG
  echo "-----------------------------------------------" >> $LOG

  log "Enable WDS daemon"

  check_wdsdaemon_pid
  if [ $WDSDAEMON_PID -gt 0 ]; then
    log "WDS daemon alwady exist"
  else
    # kill old wdsdaemon first
    # pkill wdsdaemon
    log "run WDS daemon"
    wdsdaemon -su &
  fi
}

function module_off()
{
  echo "ENDING TIME: " >> $LOG
  date >> $LOG
  sync

#  log "kill WDSDAEMON"
#  pkill -V wdsdaemon
#  check_wdsdaemon_pid
#  if [ $WDSDAEMON_PID -gt 0 ]; then
#    log "kill WDSDAEMON $WDSDAEMON_PID"
#  fi

  echo "-----------------------------------------------" >> $LOG
}

function enable_dut_mode()
{
  log "command enable_dut_mode"
  hci_reset
  $TOOL edutm >> $LOG
}

function enable_tx_mode()
{
  log "command enable_tx_mode"

  # Get Channel (0 ~ 78)
  CHANNEL="$WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL"

  # Get Type
  case $WBG_SLOT in
    "DH1")  TYPE="0x04" 
            LENGTH1="1B"
            LENGTH2="00"
            ;;
    "DH3")  TYPE="0x0B"
            LENGTH1="B7"
            LENGTH2="00"
            ;;
    "DH5")  TYPE="0x0F"
            LENGTH1="53"
            LENGTH2="01"
            ;;
    "2DH1") TYPE="0x24"
            LENGTH1="36"
            LENGTH2="00"
            ;;
    "2DH3") TYPE="0x2A"
            LENGTH1="6F"
            LENGTH2="01"
            ;;
    "2DH5") TYPE="0x2E"
            LENGTH1="A7"
            LENGTH2="02"
            ;;
    "3DH1") TYPE="0x28"
            LENGTH1="53"
            LENGTH2="00"
            ;;
    "3DH3") TYPE="0x2B"
            LENGTH1="28"
            LENGTH2="02"
            ;;
    "3DH5") TYPE="0x2F"
            LENGTH1="FD"
            LENGTH2="03"
            ;;
    *)
      log "Unknown type $WBG_SLOT"
      exit 1
  esac

  # Get Payload
  case $WBG_PAYLOAD in
    "All0")    PAYLOAD="0x00"  ;;
    "All1")    PAYLOAD="0x01"  ;;
    "ZOZO")    PAYLOAD="0x02"  ;;
    "FOFO")    PAYLOAD="0x03"  ;;
    "Ordered") PAYLOAD="0x04"  ;;
    "PRBS9")   PAYLOAD="0x04"  ;;
    *)
      log "Unknown payload $WBG_PAYLOAD"
      exit 1
  esac

  # Get Power Level
  case $WBG_POWER in
    "Class1")  POWER="0x09"  ;;
    "Class2")  POWER="0x07"  ;;
    "Class3")  POWER="0x05"  ;;
    *)
      log "Unknown power level $WBG_POWER"
      exit 1
  esac

  log "CHANNEL = "$CHANNEL
  log "TYPE = "$TYPE
  log "PAYLOAD = "$PAYLOAD
  log "POWER = "$POWER

  hci_reset

  # Format:
  #        btconfig [tty] rawcmd 3F 04 04 [channel] [channel] [channel] [channel] [channel] [payload] [type]
  #                              00 [power] 01 [tx address] 00 [payload length 1] [payload length 2] 00
  # Example:
  #        btconfig /dev/ttyHS0 rawcmd 3F 04 04 00 00 00 00 00 00 04 00 09 01 06 05 04 03 02 01 00 1B 00 00
  $TOOL $UART_TTY rawcmd 3F 04 04 $CHANNEL $PAYLOAD $TYPE 00 $POWER 01 $TX_ADDRESS 00 $LENGTH1 $LENGTH2 00 >> $LOG
  sleep 0.1
}

function enable_rx_mode()
{
  log "command enable_rx_mode"

  # Get Channel (0 ~ 78)
  CHANNEL="$WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL $WBG_CHANNEL"

  # Get Type
  case $WBG_SLOT in
    "DH1")  TYPE="0x04" 
            LENGTH1="1B"
            LENGTH2="00"
            ;;
    "DH3")  TYPE="0x0B"
            LENGTH1="B7"
            LENGTH2="00"
            ;;
    "DH5")  TYPE="0x0F"
            LENGTH1="53"
            LENGTH2="01"
            ;;
    "2DH1") TYPE="0x24"
            LENGTH1="36"
            LENGTH2="00"
            ;;
    "2DH3") TYPE="0x2A"
            LENGTH1="6F"
            LENGTH2="01"
            ;;
    "2DH5") TYPE="0x2E"
            LENGTH1="A7"
            LENGTH2="02"
            ;;
    *)
      log "Unknown type $WBG_SLOT"
      exit 1
  esac


  log "CHANNEL = $CHANNEL"
  log "TYPE = $TYPE"

  hci_reset

  # Format:
  #         btconfig [tty] rawcmd 3F 04 06 [channel] [channel] [channel] [channel] [channel] 04 [type] 00 09 01
  #                               [rx address] 00 [payload length 1] [payload length 2] 00
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 3F 04 06 00 00 00 00 00 04 04 00 09 01 EE FF C0 88 00 00 00 1B 00 00
  $TOOL $UART_TTY rawcmd 3F 04 06 $CHANNEL 04 $TYPE 00 09 01 $RX_ADDRESS 00 $LENGTH1 $LENGTH2 00 >> $LOG
  sleep 0.1
}

function get_rx_data()
{
  log "command get_rx_data"

  # Format:
  #         btconfig [tty] rawcmd 3F 04 02
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 3F 04 02
  $TOOL $UART_TTY rawcmd 3F 04 02 > $TR_RX_LOG
  cat $TR_RX_LOG >> $LOG
  sync

  # For Debug
  #TEMP=`busybox awk 'NR==12{ print "0x"$9 $8 $7 $6 } ' $TR_RX_LOG`
  #CHANNEL0_REV=`printf "%d" $(busybox awk 'NR==12{ print "0x"$9 $8 $7 $6 } ' $TR_RX_LOG)`
  #log "TEMP "$TEMP
  #log "CHANNEL 0 Received packet number: "$CHANNEL0_REV

  CHANNEL1_REV=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$13 $12 $11 $10 } ' $TR_RX_LOG))
  CHANNEL2_REV=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$45 $44 $43 $42 } ' $TR_RX_LOG))
  CHANNEL3_REV=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$77 $76 $75 $74 } ' $TR_RX_LOG))
  CHANNEL4_REV=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$109 $108 $107 $106 } ' $TR_RX_LOG))
  CHANNEL5_REV=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$141 $140 $139 $138 } ' $TR_RX_LOG))
  TOTAL_REV=`expr $CHANNEL1_REV + $CHANNEL2_REV + $CHANNEL3_REV + $CHANNEL4_REV + $CHANNEL5_REV`

  log "CHANNEL 1 Received packet number: "$CHANNEL1_REV
  log "CHANNEL 2 Received packet number: "$CHANNEL2_REV
  log "CHANNEL 3 Received packet number: "$CHANNEL3_REV
  log "CHANNEL 4 Received packet number: "$CHANNEL4_REV
  log "CHANNEL 5 Received packet number: "$CHANNEL5_REV
  log "Total Received packet number: "$TOTAL_REV

  CHANNEL1_ERR=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$17 $16 $15 $14 } ' $TR_RX_LOG))
  CHANNEL2_ERR=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$49 $48 $47 $46 } ' $TR_RX_LOG))
  CHANNEL3_ERR=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$81 $80 $79 $78 } ' $TR_RX_LOG))
  CHANNEL4_ERR=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$113 $112 $111 $110 } ' $TR_RX_LOG))
  CHANNEL5_ERR=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$145 $144 $143 $142 } ' $TR_RX_LOG))
  TOTAL_ERR=`expr $CHANNEL1_ERR + $CHANNEL2_ERR + $CHANNEL3_ERR + $CHANNEL4_ERR + $CHANNEL5_ERR`

  log "CHANNEL 1 Received error packet number: "$CHANNEL1_ERR
  log "CHANNEL 2 Received error packet number: "$CHANNEL2_ERR
  log "CHANNEL 3 Received error packet number: "$CHANNEL3_ERR
  log "CHANNEL 4 Received error packet number: "$CHANNEL4_ERR
  log "CHANNEL 5 Received error packet number: "$CHANNEL5_ERR
  log "Total Received error packet number: "$TOTAL_ERR

  RAW_TOTAL=`expr $TOTAL_REV - $TOTAL_ERR`

  # Count total bit = TOTAL_HCI_BIT * Max_payload_length * 5 channels
  # Max_payload_length: DH1(27), DH3(183), DH5(339), 2DH1(54), 2DH3(367), 2DH5(679), 3DH1(83), 3DH3(552), 3DH5(1021)
  case $WBG_SLOT in
    "DH1")  TOTAL=`expr $RAW_TOTAL \* 27 \* 5`   ;;
    "DH3")  TOTAL=`expr $RAW_TOTAL \* 183 \* 5`  ;;
    "DH5")  TOTAL=`expr $RAW_TOTAL \* 339 \* 5`  ;;
    "2DH1") TOTAL=`expr $RAW_TOTAL \* 54 \* 5`   ;;
    "2DH3") TOTAL=`expr $RAW_TOTAL \* 367 \* 5`  ;;
    "2DH5") TOTAL=`expr $RAW_TOTAL \* 679 \* 5`  ;;
    *)
      log "Unknown type $WBG_SLOT"
      exit 1
  esac

  # Return total bit value
  log "Total bit=$TOTAL"

  # Save total bit value to vendor.wbg.bt.rxreport
  setprop vendor.wbg.bt.rxreport $TOTAL
}

# Refer BLUETOOTH SPECIFICATION Version 4.1 [Vol 2] 7.8.29 LE Transmitter Test Command
function enable_le_tx_mode()
{
  log "command enable_le_tx_mode"

  # Get Channel (Range: 00 - 39)
  CHANNEL=$WBG_CHANNEL

  if [ $CHANNEL -gt 39 ] || [ $CHANNEL -lt 0 ]; then
    log "Incorrect Channel $CHANNEL"
    exit 1
  fi

  # Get Data Length Range: 0-37), Vendor default is 0x25
  LEN="0x25"

  # Get Payload
  case $WBG_PAYLOAD in
    "PRBS9")   PAYLOAD="0x00" ;;
    "FOFO")    PAYLOAD="0x01" ;;
    "ZOZO")    PAYLOAD="0x02" ;;
    "PRBS15")  PAYLOAD="0x03" ;;
    "All1")    PAYLOAD="0x04" ;;
    "All0")    PAYLOAD="0x05" ;;
    *)
      log "Unknown payload $WBG_PAYLOAD"
      exit 1
  esac

  log "CHANNEL $CHANNEL"
  log "DATA LENGTH $LEN"
  log "PAYLOAD $PAYLOAD"

  hci_reset

  # Format:
  #         btconfig [tty] rawcmd 08 1E [channel] [len] [payload]
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 08 1E 00 25 04
  $TOOL $UART_TTY rawcmd 08 1E $CHANNEL $LEN $PAYLOAD >> $LOG
  sleep 0.1
}

# Refer BLUETOOTH SPECIFICATION Version 5.0 [Vol 0] 7.8.51 LE Enhanced Transmitter Test Command
function enable_le_tx_phy_mode()
{
  log "command enable_le_tx_phy_mode"

  # Get Channel (Range: 00 - 39)
  CHANNEL=$WBG_CHANNEL

  if [ $CHANNEL -gt 39 ] || [ $CHANNEL -lt 0 ]; then
    log "Incorrect Channel $CHANNEL"
    exit 1
  fi

  # Get Data Length Range: 0-37), Vendor default is 0x25
  LEN="0x25"

  # Get Payload
  case $WBG_PAYLOAD in
    "PRBS9")   PAYLOAD="0x00" ;;
    "FOFO")    PAYLOAD="0x01" ;;
    "ZOZO")    PAYLOAD="0x02" ;;
    "PRBS15")  PAYLOAD="0x03" ;;
    "All1")    PAYLOAD="0x04" ;;
    "All0")    PAYLOAD="0x05" ;;
    *)
      log "Unknown payload $WBG_PAYLOAD"
      exit 1
  esac

  # Get PHY
  case $WBG_SET_LE_PHY in
    "RESERVED")        SPHY="0x00" ;;
    "1M")              SPHY="0x01" ;;
    "2M")              SPHY="0x02" ;;
    "CODED_8_DATA")    SPHY="0x03" ;;
    "CODED_2_DATA")    SPHY="0x04" ;;
    *)
      log "Unknown phy $WBG_SET_LE_PHY"
      exit 1
  esac

  log "CHANNEL $CHANNEL"
  log "DATA LENGTH $LEN"
  log "PAYLOAD $PAYLOAD"
  log "PHY $PHY"

  hci_reset

  # Format:
  #         btconfig [tty] rawcmd 08 34 [channel] [len] [payload] [phy]
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 08 34 00 25 00 02
  $TOOL $UART_TTY rawcmd 08 34 $CHANNEL $LEN $PAYLOAD $SPHY >> $LOG
  sleep 0.1
}

# Refer BLUETOOTH SPECIFICATION Version 4.1 [Vol 2] 7.8.28 LE Receiver Test Command
function enable_le_rx_mode()
{
  log "command enable_le_rx_mode"

  # Get Channel (Range: 00 - 39)
  CHANNEL=$WBG_CHANNEL

  if [ $CHANNEL -gt 39 ] || [ $CHANNEL -lt 0 ]; then
    log "Incorrect Channel $CHANNEL"
    exit 1
  fi

  log "CHANNEL $CHANNEL"

  hci_reset

  # Format:
  #         btconfig [tty] rawcmd 08 1D [channel]
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 08 1D 00
  $TOOL $UART_TTY rawcmd 08 1D $CHANNEL >> $LOG
  sleep 0.1
}

# Refer BLUETOOTH SPECIFICATION Version 5.0 [Vol 0] 7.8.50 LE Receiver Test Command
function enable_le_rx_phy_mode()
{
  log "command enable_le_rx_phy_mode"

  # Get Channel (Range: 00 - 39)
  CHANNEL=$WBG_CHANNEL

  if [ $CHANNEL -gt 39 ] || [ $CHANNEL -lt 0 ]; then
    log "Incorrect Channel $CHANNEL"
    exit 1
  fi

  # Get PHY (0x01=>1M, 0x02=>2M, 0x03=>LE Code)
  GPHY=$WBG_GET_LE_PHY

  # Get Modulation_Mode (0x00=> Standard Modulation, 0x01=>Stable Modulation)
  MODULATION=$WBG_GET_LE_PHY_MODULATION

  log "CHANNEL $CHANNEL"
  log "GPHY $WBG_GET_LE_PHY"
  log "MODULATION $WBG_GET_LE_PHY_MODULATION"


  hci_reset

  # Format:
  #         btconfig [tty] rawcmd 08 33 [channel] [phy] [modulation mode]
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 08 33 00 02 00
  $TOOL $UART_TTY rawcmd 08 33 $CHANNEL $WBG_GET_LE_PHY $WBG_GET_LE_PHY_MODULATION >> $LOG
  sleep 0.1
}

# Refer BLUETOOTH SPECIFICATION Version 4.1 [Vol 2] 7.8.30 LE Test End Command
function get_le_rx_data()
{
  log "command get_le_rx_data"

  # Format:
  #         btconfig [tty] rawcmd 08 1F
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 08 1F
  $TOOL $UART_TTY rawcmd 08 1F > $LE_RX_LOG
  cat $LE_RX_LOG >> $LOG

  # For Debug
  #TEMP=`busybox awk 'NR==12{ print "0x"$9 $8 $7 $6 } ' $LE_RX_LOG`
  #STATUS=`printf "%d" $(busybox awk 'NR==12{ print "0x"$9 $8 $7 $6 } ' $LE_RX_LOG)`
  #log "TEMP "$TEMP
  #log "LE STATUS: "$STATUS

  NUMBER_OF_PACKETS=$(printf "%d" $(busybox awk 'NR==12{ print "0x"$12 $11 } ' $LE_RX_LOG))

  log "Total packet=$NUMBER_OF_PACKETS"

  setprop vendor.wbg.bt.lerxreport $NUMBER_OF_PACKETS
}

function enable_cw_mode()
{
  log "command enable_cw_mode"

  # Get channel (Range: 00 - 39)
  CHANNEL=$WBG_CHANNEL

  # Get output power level (Range: 00 - 09). For the test tool, fixed value is 0x07
  POWER_LEVEL="0x07"
 
  # Get Transmit type, For the test tool, fixed value is 0x04
  # 0x04 = Carrier (CW) only
  #   0x05 = 1-PRBS9 (GFSK) pseudo random binary sequence
  #   0x06 = 1-PRBS15 (GFSK) pseudo random binary sequence
  #   0x07 = 1-pattern (GFSK) as specified in the fields shown in the pattern length (offset 7) below
  #   0x08 = 2-PRBS9 (Pi/4-DQPSK)
  #   0x09 = 2-PRBS15 (Pi/4-DQPSK)
  #   0x0A = 2-Pattern (Pi/4-DQPSK)
  #   0x0B = 3-PRBS9 (8DPSK)
  #   0x0C = 3-PRBS15 (8DPSK)
  #   0x0D = 3-Pattern (8DPSK)
  TYPE="0x04"

  # Get packet length (Range: 0x01 - 0x20), For the test tool, fixed value is 0x01
  LEN="0x01"

  # Get Bit pattern (4Byte, 0x01 - 0xFF per byte), For the test tool, fixed value is 0x01
  PATTERN="00 00 00 00"

  hci_reset

  log "Channel = $CHANNEL"
  log "Power level = $POWER_LEVEL"
  log "Transmit type = $TYPE"
  log "Packet length = $LEN"
  log "Bit pattern = $PATTERN"

  # Format:
  #         btconfig [tty] rawcmd 3F 04 09 05 [channel] [power] [type] [pattern]
  # Example:
  #         btconfig /dev/ttyHS0 rawcmd 3F 04 09 05 00 07 04 01 00 00 00 00
  $TOOL $UART_TTY rawcmd 3F 04 09 05 $CHANNEL $POWER_LEVEL $TYPE $LEN $PATTERN >> $LOG

  sleep 0.1
}

function dispatch()
{
  log "dispatch"

  case $WBG_TESTITEM in
    "enabletest")  enable_dut_mode      ;; 
    "enabletx")    enable_tx_mode       ;;
    "enablerx")    if [ $WBG_GET_RX_DATA == "false" ]; then  enable_rx_mode
                   elif [ $WBG_GET_RX_DATA == "true" ]; then get_rx_data
                   fi
                   ;;
    "enableletx")  enable_le_tx_mode    ;;
    "enablelerx")  if [ $WBG_GET_LE_PACKAGE == "false" ]; then  enable_le_rx_mode
                   elif [ $WBG_GET_LE_PACKAGE == "true" ]; then get_le_rx_data
                   fi
                   ;;
    "enablecw")    enable_cw_mode       ;;
    "enabletxphy") enable_le_tx_phy_mode       ;;
    "enablerxphy") if [ $WBG_GET_LE_PACKAGE == "false" ]; then  enable_le_rx_phy_mode
                   elif [ $WBG_GET_LE_PACKAGE == "true" ]; then get_le_rx_data
                   fi
                   ;;
    "")
      exit 1
      ;;
    *)
      log "The item $WBG_TESTITEM is not supoort"
      exit 1
      ;;
  esac
}

function service_stop()
{
  log "service_stop"

  case $WBG_TESTITEM in
    "enablebt")    module_on            ;;
    "disablebt")   module_off           ;;
    "")
      exit 1
      ;;
    *)
      log "The item $WBG_TESTITEM is not supoort"
      exit 1
      ;;
  esac
}

# main point
case $WBG_CMD in
  "btreset")   hci_reset    ;;
  "btstart")   dispatch     ;;
  "btstop")    service_stop ;;
  *)
    log "Unknown command $WBG_CMD"
    ;;
esac
