#!/usr/bin/env bash
exec 2>/var/log/VMInit.log 2>&1

if [ "$EUID" -ne 0 ]
then
    echo 'The script needs to be run as root.'
    # if not root exit
    exit 0
fi

if [ ! -f /etc/VMInit.py ]; then

    if  cp ./VMInit.sh /etc/init.d/VMInit ; then
        retval1=$?
    else
	echo "File VMInit.sh does not exist or could not be copied. Exiting."
	exit 1
    fi
    if  cp ./VMInit.py /etc/VMInit.py ; then
        retval2=$?
    else
	rm /etc/init.d/VMInit
        echo "File VMInit.py does not exist or could not be copied. Exiting."
        exit 1
    fi
    if  touch /etc/vmlist ; then
        retval3=$?
    else
	rm /etc/init.d/VMInit
	rm /etc/VMInit.py
        echo "File vmlist could now be created. Exiting."
        exit 1
    fi
    
    echo "Would you like to enable the init script? (yes or no)"
    read answer
    if [ $answer == "yes" ]; then
        update-rc.d VMInit defaults
    else
        echo "Very well. If you wish to do it later, simply run the command 'sudo update-rc.d VMInit defaults.'"
    fi
    #maybe there is better way for this
    success=$(($retval1 + $retval2 + $retval3))

    if [[ $success -eq 0 ]]; then
        #some details for the user, it's always nice to know where scripts are 
        echo "The required files have been copied successfully."
        echo "The init script at /etc/init.d/VMInit has been enabled with update-rc.d VMInit defaults"
        echo "The python executable resides at /etc/VMInit.py"
        echo "Your VMs list resides at /etc/vmlist" 
    else
        echo "Copying files failed"
    fi

else
    
    echo "VMInit already exists in your system!"
fi

exit 0
