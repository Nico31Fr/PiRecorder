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
arecord -M -I -D hw:CARD=X18XR18,DEV=0 -c 18 -f S32_LE -r 44100 $FILENAME &
ARECORD_PID=$!
sleep 1
echo -n "recording in progress, press n key to stop "

# Force a filesystem sync every 1 second to keep the buffer small enough to write without missing samples
i=0
while kill -0 $ARECORD_PID > /dev/null
do
  #spinner
  echo -n "$i"
  echo -en "\010"
  if [ "$i" == "o" ];then 
    i="_"
  else
    i="o"
  fi

  sleep 1
  #sync
  #wait for "n" key to stop record
  read -n 1 -t 1 key
  if [ "$key" == "n" ]; then 
    echo $key " key pressed"
    kill -1 $ARECORD_PID
    break
  fi

done
echo "Recording ended."
echo 
sync

echo -n "rename RAW files "
cd $DIRECTORY
rename "s/\./_/g" *
#for f in *; do mv "$f" "$f.raw"; done
for f in $(find . -type f); do mv $f ${f}.raw; done

echo "Start encoding to WAV"
echo
echo "|________________|"
TRACKS=17
CHANNEL=$TRACKS
while [ $CHANNEL -ge 0 ]
do
  FILENAMEEXT=$FILENAME"_"$CHANNEL
  sox -r 44100 -e signed-integer -b 32 -c 1 $FILENAMEEXT.raw $FILENAMEEXT.wav
  CHANNEL=`expr $CHANNEL - 1`
  echo -n "="
done

echo
echo

mkdir $FILENAME
mv *.wav $FILENAME/
#rm *.raw

echo encoding to WAV done.