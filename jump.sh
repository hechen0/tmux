#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE=$@

source $DIR/secrets

if [ -z "$MODULE" ]
then
    tmux new-window
    sleep 1 # wait window to be created
    tmux send "$SSHCMD" Enter
    tmux wait-for sshok
    PWD=`$PWDCMD`
    tmux send $PWD Enter
    tmux send s Enter
    exit 0
fi

IPS="$($DIR/getip.sh $MODULE)"
IP_COUNTS=$(echo -n "$IPS" | grep -c '^')

# create new window
tmux new-window
sleep 1
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
sleep 0.5
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
