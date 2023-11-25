#!/bin/env bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run as root"
    exit
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SERVER_DIRECTORY=${1}

if [[ "$SERVER_DIRECTORY" == "" ]]; then
  SERVER_DIRECTORY=/home/steam/miscreated
fi

mkdir -p "${SERVER_DIRECTORY}" 2>/dev/null
chown steam: "${SERVER_DIRECTORY}"
sudo -i -u steam bash << EOF
mkdir -p /home/steam/.steam 2>/dev/null
export WINEDLLOVERRIDES="mscoree,mshtml="
xvfb-run wineboot -u
/usr/games/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "${SERVER_DIRECTORY}" +login anonymous +app_update 302200 validate +quit
EOF

if [ ! -f "${SERVER_DIRECTORY}/hosting.cfg" ]; then
  install -m 644 -g steam -o steam "${SCRIPT_DIR}/hosting.cfg" "${SERVER_DIRECTORY}/hosting.cfg"
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