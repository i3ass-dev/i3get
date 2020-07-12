#!/bin/env bash

set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERX() { echo  "[ERROR] $*" >&2 ; exit 77 ;}
ERR() { echo  "[WARNING] $*" >&2 ;}
ERM() { echo  "$*" >&2 ;}
