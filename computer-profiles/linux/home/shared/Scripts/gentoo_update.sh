#!/bin/bash

#Update gentoo

eix-sync && revdep-rebuild && lafilefixer &&emerge -uDvNp world && prelink -amR
