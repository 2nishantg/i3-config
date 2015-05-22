#! /bin/bash
#
# I3 bar with https://github.com/LemonBoy/bar

. $(dirname $0)/i3_bar_config

if [ $(pgrep -cx $(basename $0)) -gt 1 ] ; then
    printf "%s\n" "The status bar is already running." >&2
    exit 1
fi

trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

[ -e "${panel_fifo}" ] && rm "${panel_fifo}"
mkfifo "${panel_fifo}"

# Window title, "WIN"
xdotool getactivewindow getwindowname > "${panel_fifo}" &

# i3 Workspaces, "WSP"
# TODO : Restarting I3 breaks the IPC socket con. :(
#$(dirname $0)/i3_workspaces.py > "${panel_fifo}" &
$(dirname $0)/i3_workspaces.pl > "${panel_fifo}" &

# Volume, "VOL"
#while :; do
#  amixer get Master | grep Left | awk -F'[]%[]' '/%/ {if ($5 == "off") {print "VOL×\n"} else {printf "VOL%d%%%%\n", $2}}' > "${panel_fifo}" &
#  sleep 3s;
#done &

#MPC
#while :; do
#  printf "%s%s\n" "MPC" "$(mpc current -f '[[[[%artist%]%title%]]|[%file%]]' | head -c 75)" > "${panel_fifo}"
#  sleep 10s;
#done &

# IRC, "IRC"
# only for init

# Conky, "SYS"
conky -c $(dirname $0)/i3_bar_conky > "${panel_fifo}" &
echo ${panel_fifo} > alpina
# Loop fifo
$(dirname $0)/i3_bar_parser.sh < "${panel_fifo}" \
  | lemonbar  \
  | while read line; do eval "$line"; done &

wait

