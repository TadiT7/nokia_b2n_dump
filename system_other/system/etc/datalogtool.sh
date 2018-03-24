#!/system/bin/sh
#fileName=$(date +%Y%m%d%H%M)".pcap"
#fileName="test.pcap"
tcpdump_FIH -i any -p -v -s 2048 -w "/data/datalog/tcpdump.pcap"