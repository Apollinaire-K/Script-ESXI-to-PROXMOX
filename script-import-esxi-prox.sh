#!/bin/bash

# Script Information & Credit
# This script has been made by myself (Apollinaire) with the help of ressources from the Proxmox official forum.

echo "script to import VM from VmWare ESXI to Proxmox by Apollinaire"

# First step will be to ask for the path to find the VM vmx & vmdk file.
# Here we ask the the file name without the exention because with VmWare ESXI both file will have the exact same name and be in the same place, only diffrence will be the extention, either .vmx or .vmdk
echo "Enter the path to the virtual machine file (path + file name without the extention !)"
read path_to_vm

# Once we have the path we will just grab the information we need.
RAM=$(grep memSize "$path_to_vm".vmx | awk '{print $3}' | tr -d '"') # here we difine the viriable RAM as the memSize line from the .vmx file, but as we only need the ram information here we use "awk" to only take the 3rd word before using "tr -d" to delete the " from the memory information.
NUM_CPU_TOTAL=$(grep numvcpus "$path_to_vm".vmx | awk '{print $3}' | tr -d '"')
CORES=$(grep cpuid.coresPerSocket "path_to_vm".vmx | sed -n '1p' | awk '{print $3}' | tr -d '"') # Here we will have to had "sed -n '1p'" because the grep give us the result of cpuid.coresPerSocket & the one from "cpuid.coresPerSocket.cookie" so we use it to only get the first line.
SOCKET=$(( NUM_CPU_TOTAL / CORES )) # to get the number of socket we divide the number total of core per number of core for one socket.
VM_NAME=$(grep displayName "path_to_vm".vmx | awk '{ $1=" "; $2=" "; sub(/^ +/, " ");print}' | tr -d '"'| tr -d ' ')

# Here this line of code will make sure that in case of the SOCKET is set at 0 it reset it to at least 1,
[ "$SOCKET" -eq 0 ] && SOCKET =1

# This step is entirerly optional and is just here to verify the the config the vm will have to be sure it actually what you want.
echo "You are about to importe a Virtual Machine with those configuration : - $RAM MB, - $CORES cores on $SOCKET for a total of $NUM_CPU_TOTAL used on the vm named $VM_NAME "
read validation

# In this Part we will create the VM, import the disk and then connect it in Virtio before putting it as the booting disk
  echo "Please enter the VM ID you want to use (Attention it has to be unused !)"
  read vm_ID
  qm create "$vm_ID" --memory "$RAM" --cores "$CORES" --sockets "$SOCKET" --bios ovmf --name "$VM_NAME"
  qm importdisk "$vm_ID" "$path_to_vm".vmdk Nexenta-Storage # Note for anyone who would want to use the code change Nexenta-Storage by the storage you use ! (it actual name in proxmox)
  qm set "$vm_ID" --virtio1 Nexenta-Storage:"$vm_ID"-disk-0.raw
  qm set "$vm_ID" --bootdisk virtio1 --boot order=virtio1

# And the import is over !
echo "Importation is over !"

# Made by Apollinaire 
