#!/bin/bash
            
chmod 6755 ./system/bin/tcpdump_FIH
mkdir ./data/media/0/tcpdump/
./system/bin/tcpdump_FIH -p -vv -s 0 -i any -w ./data/media/0/tcpdump/capture.pcap
chown media_rw:media_rw ./data/media/0/tcpdump/
chown media_rw:media_rw ./data/media/0/tcpdump/capture.pcap
mv ./data/media/0/tcpdump/capture.pcap ./data/media/0/tcpdump/capture_$(date "+%Y%m%d%H%M%S").pcap