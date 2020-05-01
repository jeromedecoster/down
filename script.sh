set -e

log() { echo -e "\e[38;5;82;4m${1}\e[0m \e[38;5;226m${@:2}\e[0m"; }
err() { echo -e "\e[38;5;196;4m${1}\e[0m \e[38;5;87m${@:2}\e[0m" >&2; }

cd /usr/local/bin

# abort if already installed
[[ -x down ]] && { log abort down already exists; exit 0; }

# ask sudo accesss if not already available
if [[ -z $(sudo -n uptime 2>/dev/null) ]]; then
    log warn sudo access required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && { err abort sudo required; exit 1; }
fi

log install down
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

log complete down successfully installed
exit 0