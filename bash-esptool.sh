#!/bin/bash

notool() {
  echo "No esptool"
  read -p "Install with PIP or with APT? (1/2) " pmgr
  if [[ $pmgr == "1" ]]
  then
    pip --version || pipx --version || nopip
    pip install esptool || pipx install esptool || piperr
  else
    sudo apt install esptool || apterr
  fi
  return 0
}

nopip() {
  echo "No pip"
  echo "Installing.."
  sudo apt install pip pipx || apterr
}

piperr() {
  echo "Error in PIP"
  exit 1
}

apterr() {
  echo "Error in APT"
  exit 1
}

toolerr() {
  echo "Error in esptool"
  exit 1
}

writeF() {
  echo "═══════WRITE═FLASH═══════"
  read -p "Port: " port
  read -p "Merged firmware: " firmware
  read -p "Baud rate: " baud
  esptool.py -p "$port" -b "$baud" -a hard_reset write_flash -fs detect 0x00000 "$firmware" --erase-all || esptool -p "$port" -b "$baud" -a hard_reset write_flash -fs detect 0x00000 "$firmware" --erase-all || toolerr
  echo "Done"
}

eraseF() {
  echo "═══════ERASE═FLASH═══════"
  read -p "Port: " port
  read -p "Baud rate: " baud
  esptool.py -p "$port" -b "$baud" erase_flash || esptool -p "$port" -b "$baud" erase_flash || toolerr
}

readF() {
  echo "════════READ═FLASH════════"
  read -p "Port: " port
  read -p "Exit firmware name: " firmware
  read -p "Baud rate: " baud
  esptool.py -p "$port" -b "$baud" read_flash 0 ALL "$firmware" || esptool -p "$port" -b "$baud" read_flash 0 ALL "$firmware" || toolerr
}

mergeF() {
  echo "══════MERGE═FIRMWARE══════"
  read -p "Chip: " chip
  read -p "Exit file name: " output
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
  esptool.py $command || esptool $command || toolerr
}


esptool.py version || esptool version || notool || toolerr

clear
echo "╔═══════════════════╗"
echo "║     FUNCTIONS     ║"
echo "╠═══════════════════╣"
echo "║ 1. Write Flash    ║"
echo "║ 2. Erase Flash    ║"
echo "║ 3. Read Flash     ║"
echo "║ 4. Merge Firmware ║"
echo "╚═══════════════════╝"
echo ""
read -p "Choose: " func
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
esac
exit 0

