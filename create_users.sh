#!/bin/bash

CSV_FILE="$1"

logPath="/var/log/user_management.log"
# Read the CSV files line by line

# Check if the file exists

if [[ ! -f "$CSV_FILE" ]]; then 
	echo "$(date "+%Y-%m-%d %H:%M:%S") File not found!" >> $logPath
	echo "File not found!"
	exit 1

fi

# check if file is a csv file
if [[ "$CSV_FILE" != *.csv ]]; then 
	echo "$(date "+%Y-%m-%d %H:%M:%S") File must have .csv extension"  >> $logPath
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


# Split the user and group by ";"
while IFS=';' read -r user groups; do
	user=$(echo $user | tr -d ' ')
	groups=$(echo $groups | tr -d ' ')
# Check if the user is existing or not
if id $user &>/dev/null; then
				# Created a log that user exits in /var/secure/user_management.txt
                echo "$(date "+%Y-%m-%d %H:%M:%S") user with username $user already exist." >> $logPath
 
        else
				# Generate random Password
                password=$(tr -dc 'A-Za-z0-9!?%#&' < /dev/urandom | head -c 12)
 
				# Created User and Assign password
                useradd -m $user
                echo "$user:$password" | chpasswd
				# Store the created user and password to /var/secure/user_passwords.csv
                echo "$user,$password" >> /var/$passwdir/$passwfile

				# Logs that a new user is cretaed to /var/secure/user_management.txt
                echo "$(date "+%Y-%m-%d %H:%M:%S") user with username: $user cretaed by user $(whoami)" >> $logPath
        fi

# Split the groups by comma and add user to each group
IFS=',' read -ra GROUP_ARRAY <<< "$groups"

#Loop through the array of groups
for group in "${GROUP_ARRAY[@]}"; do
		# check for the existense of group before adding users to group
		 if [ $(getent group $group) ]; then
		 	echo "$(date "+%Y-%m-%d %H:%M:%S") group: $group already exists." >> $logPath
		 else
		 	groupadd $group
		 	echo "$(date "+%Y-%m-%d %H:%M:%S") group: $group created by user $(whoami)."  >> $logPath
		fi
	adduser $user $group
	echo "$(date "+%Y-%m-%d %H:%M:%S") user with username: $user was added to group :$group by user $(whoami)" >> $logPath

done

done < "$CSV_FILE"
