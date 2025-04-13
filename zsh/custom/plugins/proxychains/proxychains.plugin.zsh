if [ -e $(which proxychains4) ]; then
    alias px='proxychains4'
elif [ -e $(which proxychains) ]; then
    alias px='proxychains'
else
    alias px='echo "proxychains not installed:"'
fi
