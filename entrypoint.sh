#!/bin/bash
if [ ! -z "$container_name" ]
then
    echo "Container name detected: $container_name"
    if [ -d "/proc2/" ]
    then
        echo "Second Proc area found."
        if [ -S "/var/run/docker.sock" ]
        then
            echo "Docker socket found."
            container_stat=$(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s -o /dev/null -w '%{http_code}\n' )
            case $container_stat in
            "000")
                echo  "Err while connecting docker socket."
                echo  "Are you mount right docker socket ?"
                err_on_exit="yes"
            ;;

            "404")
                echo "Container $container_name is not found."
                err_on_exit="yes"
            ;;

            "200")
                echo "Container $container_name is found and running."
                if [ $(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s | awk -v RS=',' -F: '{ if ( $1 == "\"Running\"") {print $2}}') == "true" ]
                then
                    container_pid=$(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s | awk -v RS=',' -F: '{ if ( $1 == "\"Pid\"") {print $2}}')
                    rm /var/run/netns/container 2> /dev/null
                    mkdir -p /var/run/netns/
                    ln -s /proc2/$container_pid/ns/net /var/run/netns/container && echo "Link is created" || ( echo "Link is not created. Did you run this container with privileged ? "; exit 1)
                else
                    echo "Your container is not running."
                    echo "Exiting in 10 seconds."
                    sleep 10
                    exit 0
                fi
            ;;
            
            *)
                echo "Unknow response: $container_stat"
                err_on_exit="yes"
            ;;
            esac
        else 
            echo "You are mounted Proc folder but you are not mount docker sock."
            echo "You can make a mount with -v /var/run/docker.sock:/var/run/docker.sock"
            err_on_exit="yes"
        fi
    else
        echo "Second proc folder is not found."
        echo "Please mount second proc with docker with -v /proc/:/proc2"
        err_on_exit="yes"
    fi
fi

if [ -f "/var/run/netns/container" ]
then
    control_container="yes"
    exec_command="ip netns exec container"
else
    exec_command=""
fi

exec_command start.sh $@