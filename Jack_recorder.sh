#!/bin/bash

# Main function

clear
echo -n "Looking for XR18..."
until arecord -L | grep CARD=X18XR18 > /dev/null    # use grep to filter the output of arecord -L, returns 0 (true) if found
do
        sleep 1
done
echo "[OK]"
echo

DIRECTORY=/media/pi/PiRec/record
FILENAME=$DIRECTORY$(date +"%Y%m%d_%H%M")

# disable blanking of the terminal
# in addition /etc/kbd/config was changed: 
## BLANK_TIME=0
## POWERDOWN_TIME=0
## plus clock enabled
setterm -blank 0

# Start JACK server
sudo jackd -dalsa -dhw:X18XR18 -r44100 -p2048 -n3 &
#waiting for jack server start
sudo jack_wait -w
#start recording
sudo jack_capture -f ogg -dm -c 16 -p system:capture\* -fn $FILENAME.ogg
#sudo jack_capture -f raw -dm -c 12 -p system:capture\* -fn $FILENAME.raw

echo
echo "Recording ended."
echo 
sync

#echo -n "rename RAW files "
#cd $DIRECTORY
#rename "s/\./_/g" *
##for f in *; do mv "$f" "$f.raw"; done
#for f in $(find . -type f); do mv $f ${f}.raw; done

#echo "Start encoding to WAV"
#echo
#echo "|________________|"
#TRACKS=17
#CHANNEL=$TRACKS
#while [ $CHANNEL -ge 0 ]
#do
#  FILENAMEEXT=$FILENAME"_"$CHANNEL
#  sox -r 44100 -e signed-integer -b 32 -c 1 $FILENAMEEXT.raw $FILENAMEEXT.wav
#  CHANNEL=`expr $CHANNEL - 1`
#  echo -n "="
#done

#echo
#echo

#mkdir $FILENAME
#mv *.wav $FILENAME/
#rm *.raw

#echo encoding to WAV done.