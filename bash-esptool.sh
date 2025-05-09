#!/bin/bash

pacman -V 2> /dev/null 1> /dev/null && psetup="pacman -S"
apt version 2> /dev/null 1> /dev/null && psetup="apt install"
dnf version 2> /dev/null 1> /dev/null && psetup="dnf install"

notool() {
  echo "No esptool"
  read -p "Install with PIPX or with package manager? (1/2) " pmgr
  if [[ $pmgr == "1" ]]
  then
    pipx --version || nopipx
    pipx install esptool || pipxerr
  else
    sudo $psetup esptool || pkgerr
  fi
  return 0
}

nopipx() {
  echo "No pipx"
  read -p "Would you like to install? (y/n) " pinst
  if [[ ${pinst,,} == "y" ]]
  then 
    sudo $psetup pipx || sudo $psetup python-pipx || pkgerr
  else
    exit 1
  fi
}

pipxerr() {
  echo "Error in PIPX"
  exit 1
}

pkgerr() {
  echo "Error in package manager, install manually"
  exit 1
}

toolerr() {
  echo "Error in esptool"
  exit 1
}

writeF() {
  echo "═══════WRITE═FLASH═══════"
  read -p "Port: [def: /dev/ttyUSB0 (ENTER)] " port
  if [[ $port == "" ]]
  then 
    port="/dev/ttyUSB0"
  fi
  read -p "Merged firmware: " firmware
  read -p "Baudrate: [def: 921600 (ENTER)] " baud
  if [[ $baud == "" ]]
  then 
    baud="921600"
  fi
  $tool -p "$port" -b "$baud" -a hard_reset write_flash -fs detect 0x00000 "$firmware" --erase-all || toolerr
}

eraseF() {
  echo "═══════ERASE═FLASH═══════"
  read -p "Port: [def: /dev/ttyUSB0 (ENTER)] " port
  if [[ $port == "" ]]
  then
    port="/dev/ttyUSB0"
  fi
  read -p "Baudrate: [def: 921600 (ENTER)] " baud
  if [[ $baud == "" ]]
  then
    baud="921600"
  fi
  $tool -p "$port" -b "$baud" erase_flash || toolerr
}

readF() {
  echo "════════READ═FLASH════════"
  read -p "Port: [def: /dev/ttyUSB0 (ENTER)] " port
  if [[ $port == "" ]]
  then
    port="/dev/ttyUSB0"
  fi
  read -p "Exit firmware name with path: [def: ./exit-firmware.bin (ENTER)] " firmware
  if [[ $firmware == "" ]]
  then
    firmware="./exit-firmware.bin"
  fi
  read -p "Baudrate: [def: 921600 (ENTER)] " baud
  if [[ $baud == "" ]]
  then
    baud="921600"
  fi
  $tool -p "$port" -b "$baud" read_flash 0 ALL "$firmware" || toolerr
}

mergeF() {
  echo "══════MERGE═FIRMWARE══════"
  read -p "Chip: " chip
  read -p "Exit file name: [def: ./merged-firmware.bin (ENTER)] " output
  if [[ $output == "" ]]
  then
    output="./merged-firmware.bin"
  fi
  command="--chip $chip merge_bin --output $output "
  read -p "How many files? " count
  i=0
  while [[ count -gt i ]]
  do
    i=$[ $i + 1 ]
    read -p $i". File: " file
    read -p $i". Sector: " sector
    command+=$sector" "$file" "
  done
  $tool $command || toolerr
}


esptool.py version 2> /dev/null 1> /dev/null || esptool version 2> /dev/null 1> /dev/null || notool || toolerr
esptool version 2> /dev/null 1> /dev/null && tool="esptool"
esptool.py version 2> /dev/null 1> /dev/null && tool="esptool.py"

echo "  bash-esptool v1.1  "
echo "╔═══════════════════╗"
echo "║     FUNCTIONS     ║"
echo "╠═══════════════════╣"
echo "║ 1. Write Flash    ║"
echo "║ 2. Erase Flash    ║"
echo "║ 3. Read Flash     ║"
echo "║ 4. Merge Firmware ║"
echo "║ 5. Exit           ║"
echo "╚═══════════════════╝"
echo ""
read -p "Choose: " func
echo ""
case $func in
"1" )
  writeF
;;
"2" )
  eraseF
;;
"3" )
  readF
;;
"4" )
  mergeF
;;
"5" )
  exit 0
;;
esac

echo "Done"
echo ""
exit 0

