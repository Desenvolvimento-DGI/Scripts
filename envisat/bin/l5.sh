#!/bin/bash

ORBITAPONTOATUAL="226_068_0"
FINAL="2_BC_UTM_WGS84"
TOTAL=0

for ANOATUAL in `seq 2004 2007`
do

     for MESATUAL in `seq 1 12`
     do


       NOVOMES=$(( MESATUAL + 100 ))
       NOVOMES="`echo ${NOVOMES} | cut -c 2-3`"

       ANOMESATUAL="${ANOATUAL}_${NOVOMES}"


       cd /L2_LANDSAT5/${ANOMESATUAL}

       pwd


       ARQS="`\ls -1 | grep -i ^LANDSAT5_TM_ | sort`"

       for ARQATUAL in ${ARQS}
           do

		   
				if [ -d "/L2_LANDSAT5/${ANOMESATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}" ]
				then
                  TOTAL=$(( TOTAL + 1 ))
                  cd /L2_LANDSAT5/${ANOMESATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}
                  pwd
				fi
				
       done

    done

done

echo ${TOTAL}

