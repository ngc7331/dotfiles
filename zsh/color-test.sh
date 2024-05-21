#!/bin/bash

for color in {0..255}; do
  echo -e -n "\033[38;5;${color}m$(printf '%03d' ${color})\033[0m "
    if [ $(((${color}) % 6)) -eq 3 ] && [ ${color} -ge 16 ]; then
        echo
    fi
    if [ $(((${color}) % 8)) -eq 7 ] && [ ${color} -le 15 ]; then
        echo
    fi
done
echo
