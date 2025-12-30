#!/bin/bash

# this script needs the name of the cpp file, than the asm file

set -e

nasm -f elf64 $2.asm -o $2.o -g -F dwarf     
clang++ -c $1.cpp -o $1.o -g 
clang++ $1.o $2.o -o $1 -g -no-pie
