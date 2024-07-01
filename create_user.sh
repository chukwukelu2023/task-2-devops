#!/bin/bash

CSV_FILE="$1"

# Check if the file exists

if [[ ! -f "$CSV_FILE" ]]; then 
	echo "File not found!"
	exit 1

fi

# check if file is a csv file
if [[ "$CSV_FILE" != *.csv ]]; then 
	echo "File must have .csv extension"
	exit 1
fi
# check if directories exist if not create it
passwdir='secure'
passwfile='user_passwords.csv'
if [ ! -d /var/$passwdir ]; then
	mkdir /var/$passwdir
	touch /var/$passwdir/$passwfile
	# Set permission of the file
	chmod 600 /var/$passwdir/$passwfile
fi

logPath="/var/log/user_management.log"
# Read the CSV files line by line

while IFS=';' read -r user groups; do
	user=$(echo $user | tr -d ' ')
	groups=$(echo $groups | tr -d ' ')

if id $user &>/dev/null; then
                echo "$(date "+%Y-%m-%d %H:%M:%S") user $user already exist."
 
        else
                password=$(tr -dc 'A-Za-z0-9!?%#&' < /dev/urandom | head -c 12)
 
                useradd -m $user
                echo "$user:$password" | chpasswd
                echo "$user,$password" >> /var/$passwdir/$passwfile
                echo "$(date "+%Y-%m-%d %H:%M:%S") created user with username: $user by user $(whoami)" >> $logPath
                echo "$user:$password"
        fi

# Split the groups by comma and add user to each group
IFS=',' read -ra GROUP_ARRAY <<< "$groups"

for group in "${GROUP_ARRAY[@]}"; do

	echo "$(date "+%Y-%m-%d %H:%M:%S") Added user: $user to group :$group by user $(whoami)" >> $logPath

done

done < "$CSV_FILE"
