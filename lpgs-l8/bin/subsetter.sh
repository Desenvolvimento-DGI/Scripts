#!/bin/csh -ef
#  -e flag will cause the script to exit if any command fails
#  -f flag will keep current environment (skip re-sourcing the cshrc)
# 

if ($#argv < 3) then
    echo "Sorry, but you entered too few parameters"
    echo "usage:  $0 arquivo.jpl ANO MES IntervalId SceneId" 
    exit
endif
if ( ! -d  /L0_LANDSAT8/L0Rp/$1_$2/$3/$4 ) then
	mkdir /L0_LANDSAT8/L0Rp/$1_$2/$3/$4
endif
echo /L0_LANDSAT8/L0Ra/$1_$2/$3/$4
echo /L0_LANDSAT8/L0Rp/$1_$2/$3
$HOME/SBS_3_0_0/OTS/ot_subsetter $4 /L0_LANDSAT8/L0Ra/$1_$2/$3/$4 /L0_LANDSAT8/L0Rp/$1_$2/$3/$4 --scene $4 

# $HOME/SBS_3_0_0/OTS/ot_subsetter LO82190702015074CUB00 /L0_LANDSAT8/L0Ra/2015_03/LO82190620802015074CUB00/LO82190702015074CUB00 /L0_LANDSAT8/L0Rp/2015_03/LO82190620802015074CUB00/LO82190700802015074CUB00 --scene LO82190702015074CUB00

