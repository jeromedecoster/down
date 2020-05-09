set -e

log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; }
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; }

info install down
cd /usr/local/bin

# abort if already installed
[[ -x down ]] && { error abort down already exists; exit 0; }

# ask sudo accesss if not already available
if [[ -z $(sudo -n uptime 2>/dev/null) ]]; then
    warn warn sudo access required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && { error abort sudo required; exit 1; }
fi

log download down
if [[ -n $(which curl) ]]
then
    sudo curl raw.githubusercontent.com/jeromedecoster/down/master/down \
        --location \
        --remote-name \
        --progress-bar
else
    sudo wget raw.githubusercontent.com/jeromedecoster/down/master/down \
        --quiet \
        --no-clobber \
        --show-progress
fi

sudo chmod +x down

info installed down
exit 0