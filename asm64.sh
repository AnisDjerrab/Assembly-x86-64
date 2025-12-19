#!/bin/bash

set -e

nasm -f elf64 $1.asm -g -o $1.o
ld -o $1 $1.o