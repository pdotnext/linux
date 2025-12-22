#!/bin/bash
# --- Description
# create a file with .png in home and graphics directory
# --- Usage
#. lab_script.sh <username>
user=$1
touch ${user}02.png
mkdir -v graphics
cd graphics
touch ${user}{01,03,04}.png