#!/bin/sh
fp=1474560
size=`ls -al image.img | cut -d" " -f 5`
rest=$(($fp-$size))
dd if=/dev/zero of=rest bs=$rest count=1
cat rest >> image.img
rm rest