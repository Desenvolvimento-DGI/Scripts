#!/bin/bash

clear

SATELITES='AQUA TERRA NPP NOAA15 NOAA18 NOAA19 FY METOPB GOES13 CBERS4 METEOSAT LANDSAT7' 

for SATUAL in ${SATELITES}
do

	du -Lhs /mnt/{single,cluster}/${SATUAL}
	echo ""
done


