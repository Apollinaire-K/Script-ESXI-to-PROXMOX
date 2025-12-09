#! /bin/bash

# Script Information & Credit
# This script has been made by myself (Apollinaire) with the help of ressources from the Proxmox official forum.

echo "script to import VM from VmWare ESXI to Proxmox by Apollinaire"

# First step will be to ask for the path to find the VM vmx & vmdk file.
# Here we ask the the file name without the exention because with VmWare ESXI both file will have the exact same name and be in the same place, only diffrence will be the extention, either .vmx or .vmdk
echo "Enter the path to the virtual machine file (path + file name without the extention !)
read path_to_vm

# Once we have the path we will just grab the information we need.
RAM=$(grep memSize "$path_to_vm".vmx | awk '{print $3}' | tr -d '"') # here we difine the viriable RAM as the memSize line from the .vmx file, but as we only need the ram information here we use "awk" to only take the 3rd word before using "tr -d" to delete the " from the memory information.
NUM_CPU_TOTAL=$(grep numvcpus "$path_to_vm".vmx | awk '{print $3}' | tr -d '"')
CORES=$(grep cpuid.coresPerSocket "path_to_vm".vmx | sed -n '1p' | awk '{print $3}' | tr -d '"') # Here we will have to had "sed -n '1p'" because the grep give us the result of cpuid.coresPerSocket & the one from "cpuid.coresPerSocket.cookie" so we use it to only get the first line.
SOCKET=$(( NUM_CPU_TOTAL / CORES )) # to get the number of socket we divide the number total of core per number of core for one socket.
VM=$(grep displayName "path_to_vm".vmx | awk '{ $1=" "; $2=" "; sub(/^ +/, " ");print}' | tr -d '"'| tr -d ' ')

