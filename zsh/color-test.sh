#!/bin/bash

for color in {0..15}; do
  echo -e -n "\033[38;5;${color}m$(printf '%03d' ${color})\033[0m "
  if [ $(((${color}) % 8)) -eq 7 ]; then
    echo
  fi
done

for color in {16..255}; do
  echo -e -n "\033[38;5;${color}m$(printf '%03d' ${color})\033[0m "
  if [ $(((${color}) % 6)) -eq 3 ]; then
    echo
  fi
done
