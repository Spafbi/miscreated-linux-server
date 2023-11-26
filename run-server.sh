#!/bin/env bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run as root"
    exit
fi

MAP=islands
PLAYERS=36
PORT=64090
SERVER_DIRECTORY=/home/steam/miscreated
SV_BIND=""
THIS_USER=steam
WHITELISTED=""

# Parse the command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -directory=*)
            SERVER_DIRECTORY="${1#*=}"
            ;;
        -map=*)
            MAP="${1#*=}"
            ;;
        -players=*)
            PLAYERS="${1#*=}"
            ;;
        -port=*)
            PORT="${1#*=}"
            ;;
        -sv_bind=*)
            SV_BIND="-sv_bind ${1#*=}"
            ;;
        -user=*)
            THIS_USER="${1#*=}"
            ;;
        -whitelisted=*)
            WHITELISTED="-mis_whitelist"
            ;;
        *)
            ;;
    esac
    shift
done

SCREEN_NAME=miscreated
TITLE_NAME="${SERVER_DIRECTORY//[^a-zA-Z0-9]/}"
TEMPFILE=$(mktemp)

cat << EOF > ${TEMPFILE}
#!/bin/env bash
while true; do
  WINEDEBUG=-fixme-all xvfb-run -a /usr/bin/wine ${SERVER_DIRECTORY}/Bin64_dedicated/MiscreatedServer.exe ${SV_BIND} -sv_port ${PORT} +sv_maxplayers ${PLAYERS} +map ${MAP} +http_startserver ${WHITELISTED}
  echo "The server will restart in 10 seconds. Press CTRL-C to quit."
  sleep 10
done
EOF
chown ${THIS_USER}: ${TEMPFILE}
chmod +x ${TEMPFILE}

sudo -u ${THIS_USER} -- bash -c "[ \$(screen -ls|grep ${SCREEN_NAME} -c) -eq 0 ] && screen -dmS ${SCREEN_NAME}"
sudo -u ${THIS_USER} -- bash -c "screen -S ${SCREEN_NAME} -X screen -t ${TITLE_NAME}"
sudo -u ${THIS_USER} -- bash -c "screen -S ${SCREEN_NAME} -p ${TITLE_NAME} -X stuff '${TEMPFILE}\n'"