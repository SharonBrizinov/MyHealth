#!/bin/bash
#
# MyHealth
#   Generates a full report about your Raspberry Pi
#
# By Sharon Brizinov
#
#

FILENAME='/var/log/health.log'


function system_health ()
{
    date
    echo
    echo

    echo -n "Hostname:              "
    hostname
    echo

    echo -n "System Version:        "
    uname -a
    echo
    
    echo -n "Uptime:                "
    uptime | sed 's/.*up \([^,]*\), .*/\1/'
    echo

    echo -n "Last Reboot:           "
    who -b | awk '{print $3,$4,$5}'
    echo

    echo -n "Load Avg (1,5,15 min): "
    uptime | awk  '{ print $10, $11, $12 }'
    echo
    
    echo    "Disk Usage:            "
    echo "=========================="
    df -kh
    echo
    
    echo "Who's logged in:          "
    echo "=========================="
    w
    echo
    echo

    echo "Recent logins (10):       "
    echo "=========================="
    last -n 10
    echo
    echo

    echo "Cron jobs:                "
    echo "=========================="
    crontab -l | grep -v "#"
    echo
    echo
    
    echo "Processes:                "
    echo "=========================="
    ps aux
    echo
    echo


    echo "Logs:                     "
    echo "=========================="
    ls -lat /var/log
    echo
    echo
    
    echo "SSH (Successful) (5):     "
    echo "=========================="
    cat /var/log/auth.log | grep Accepted | tail -n 5
    echo
    echo

    echo "SSH (Failures) (5):       "
    echo "=========================="
    cat /var/log/auth.log | grep Invalid | tail -n 5
    cat /var/log/auth.log | grep preauth | tail -n 5
    echo
    echo



    echo "Network:                  "
    echo "=========================="
    netstat -ntupa
    echo "--------------------------"
    echo
    ifconfig -a
    echo "--------------------------"
    echo
    iptables -nvL
    echo "--------------------------"
    echo
    echo

    echo "Daemons:                  "
    echo "=========================="
    /etc/init.d/ssh status
    /etc/init.d/watchdog status
    echo
    echo

}

# Generates MyHealth report
generate_report () 
{
    echo "Saving...."
    echo "Report full path: $FILENAME"
    system_health > $FILENAME
    echo "Report was generated successfully!"
}
# Prints MyHealth last saved report
print_last_report () 
{
    echo "Printing last report..."
    cat $FILENAME
}

case "$1" in

    print-without-saving)
        system_health
        ;;

    print|status)
        generate_report
        print_last_report
        ;;

    save|generate)
        generate_report
        ;;

    last)
        print_last_report
        ;;

    mail|email)
        if [ "$2" != '' ];then
            generate_report
            echo "Sending report to $2..."
            cat $FILENAME | mail -s "RPi MyHealth Report: $(date +%D--%T)" $2
        else
            echo "Usage: $0 email|mail myemail@email.com"
        fi
        ;;

    *)
        echo "Usage: $0 [print-without-saving | print|status | save|generate | last | mail|email <email@mail.com>]"
        ;;

esac