#!/bin/sh

MODULE=$@
if [ -z "$MODULE" ]
then
    echo "Usage: jump module.api.com"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IPS="$($DIR/getip.sh $MODULE)"
IP_COUNTS=$(echo -n "$IPS" | grep -c '^')

source $DIR/secrets

# create new window
tmux new-window
for i in $(seq 1 1 $(($IP_COUNTS-1))); do
    tmux split-window -h
done
tmux select-layout even-horizontal

# login
tmux setw synchronize-panes
tmux send "$SSHCMD" Enter
sleep 2
PWD=`$PWDCMD`
tmux send $PWD Enter
tmux setw synchronize-panes

# send target ip
TARGET=1
for i in $IPS;do
    tmux send -t $TARGET $i Enter
    TARGET=$(($TARGET+1))
    sleep 1
done

tmux setw synchronize-panes

# cd into applogs
tmux send "$CDLOGCMD/$MODULE" Enter
