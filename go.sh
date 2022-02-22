#!/bin/sh

./mads grcdrv_reloc.asm -o:grcdrv.xex
./mads grcdrv_cas.asm -o:grcdrv_cas.boot
./xex2cas grcdrv_cas.boot grcdrv.cas /b
rm grcdrv_cas.boot
