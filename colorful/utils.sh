# logging functions
debug() {
  if [ "${__COLORFUL_LOG_DEBUG}" = "true" ]; then
    echo -e "\e[34m[colorful] $@\e[0m"
  fi
}

info() {
  echo -e "\e[32m[colorful] $@\e[0m"
}

warn() {
  echo -e "\e[33m[colorful] $@\e[0m"
}

error() {
  echo -e "\e[31m[colorful] $@\e[0m"
}

fatal() {
  echo -e "\e[31m[colorful] $@\e[0m"
  if [ ! -z "${__COLORFUL_USAGE}" ]; then
    echo "${__COLORFUL_USAGE}"
  fi
  exit 1
}

# read dotenv
dotenv() {
  if [ -z "$1" ]; then
    return
  fi
  if [ -f "$1" ]; then
    debug "Reading $1"
    source "$1"
  fi
}
