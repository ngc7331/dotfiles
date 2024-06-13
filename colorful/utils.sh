# logging functions
info() {
  echo -e "\e[32m[colorful] $1\e[0m"
}

warn() {
  echo -e "\e[33m[colorful] $1\e[0m"
}

error() {
  echo -e "\e[31m[colorful] $1\e[0m"
}

fatal() {
  echo -e "\e[31m[colorful] $1\e[0m"
  if [ ! -z "$USAGE" ]; then
    echo "$USAGE"
  fi
  exit 1
}
