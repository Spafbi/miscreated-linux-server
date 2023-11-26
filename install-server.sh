#!/bin/env bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run as root"
    exit
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SERVER_DIRECTORY=/home/steam/miscreated
THIS_USER=steam

# Parse the command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -directory=*)
            SERVER_DIRECTORY="${1#*=}"
            ;;
        -user=*)
            THIS_USER="${1#*=}"
            ;;
        *)
            ;;
    esac
    shift
done

THIS_USER_DIR=$(getent passwd ${THIS_USER} | cut -d: -f6)
THIS_USER_GROUP=$(id -gn ${THIS_USER})

mkdir -p "${SERVER_DIRECTORY}" 2>/dev/null
chown ${THIS_USER}: "${SERVER_DIRECTORY}"
sudo -i -u ${THIS_USER} bash << EOF
mkdir -p ${THIS_USER_DIR}/.steam 2>/dev/null
export WINEDLLOVERRIDES="mscoree,mshtml="
xvfb-run wineboot -u
/usr/games/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "${SERVER_DIRECTORY}" +login anonymous +app_update 302200 validate +quit
EOF

if [ ! -f "${SERVER_DIRECTORY}/hosting.cfg" ]; then
  install -m 644 -g ${THIS_USER_GROUP} -o ${THIS_USER} "${SCRIPT_DIR}/hosting.cfg" "${SERVER_DIRECTORY}/hosting.cfg"
  echo -e "\n\n"

  echo -n "Enter a server name - [My Miscreated Server]: "
  read SERVERNAME
  if [[ ${SERVERNAME} == "" ]]; then SERVERNAME="My Miscreated Server"; fi

  echo -n "Enter an RCON password - [secret]: "
  read PASSWORD
  if [[ ${PASSWORD} == "" ]]; then PASSWORD="secret"; fi

  sed -i "/REPLACE_WITH_RCON_PASSWORD/c\http_password=${PASSWORD}" "${SERVER_DIRECTORY}/hosting.cfg"
  sed -i "/REPLACE_WITH_SERVERNAME/c\sv_servername=\"${SERVERNAME}\"" "${SERVER_DIRECTORY}/hosting.cfg"
  sed -i "/sv_maxuptime/c\sv_maxuptime=12" "${SERVER_DIRECTORY}/hosting.cfg"
fi