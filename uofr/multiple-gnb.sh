#!/bin/bash
set -x

# adding dummy interfaces

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Define an array to hold interface names and IP addresses
interfaces=(dummy2 dummy3)
ip_addresses=("10.20.1.1/16" "10.30.1.1/16")

# Function to check for errors and exit if any
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred. Exiting."
        exit 1
    fi
}

# Loop through each interface and IP address
for ((i=0; i<${#interfaces[@]}; i++)); do
    interface=${interfaces[i]}
    ip_address=${ip_addresses[i]}

    # Add dummy interface if it doesn't exist
    ip link show $interface >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Adding $interface interface"
        ip link add $interface type dummy
        check_error
    fi

    # Assign IP address
    echo "Assigning IP address $ip_address to $interface interface"
    ip addr add $ip_address dev $interface
    check_error

    # Bring interface up
    echo "Bringing $interface interface up"
    ip link set $interface up
    check_error

    echo "$interface interface setup complete"
done
