# Creating Bash Scripts for User Management

## Introduction

A Bash script is a file containing a sequence of commands that are executed on a Bash shell. It allows performing a series of actions or automating tasks. In this article, we will examine how to use a Bash script to create users dynamically by reading a CSV file. A CSV (Comma Separated Values) file contains data separated by commas or other delimiters.

In Linux systems, multiple users can access the same machine, necessitating the creation of users with specific permissions. This article demonstrates a Bash script for creating users from a CSV file, assigning them to groups, and generating random passwords.

## Bash Script Overview

We will follow a sequence of steps to create the Bash script. You can clone the full code from [this GitHub repository](https://github.com/chukwukelu2023/task-2-devops.git).

### Reading the CSV File

The first step is to read the CSV file. The Bash script will take the CSV file as an input argument. If no input or a file without the `.csv` extension is provided, the script will throw an error and exit. Below is the code snippet for checking the file:

```bash
CSV_FILE="$1"

# Check if the file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "File not found!"
    exit 1
fi

# Check if the file has a .csv extension
if [[ "$CSV_FILE" != *.csv ]]; then
    echo "File must have a .csv extension"
    exit 1
fi
```

### Creating a Directory and File to Store Users

After reading the file, we need to create a directory and file to store the usernames and passwords of any new users created. To avoid creating a directory that already exists, we first check for its existence before creating a new one:

```bash
PASSWD_DIR="/var/secure"
PASSWD_FILE="user_passwords.csv"

if [ ! -d "$PASSWD_DIR" ]; then
    mkdir -p "$PASSWD_DIR"
    touch "$PASSWD_DIR/$PASSWD_FILE"
    chmod 600 "$PASSWD_DIR/$PASSWD_FILE"
fi
```

### Reading the Usernames and Group Names

After checking the CSV file and creating the file for storing the users, we will iterate through the rows to create users and assign them to groups. While creating the users, a random password is generated for each user. The code snippet below shows how users are created:

```bash
LOG_PATH="/var/secure/user_management.txt"

# Split the user and group by ";"
while IFS=';' read -r user groups; do
    user=$(echo $user | tr -d ' ')
    groups=$(echo $groups | tr -d ' ')

    # Check if the user exists
    if id "$user" &>/dev/null; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") user with username $user already exist." >> $logPath
    else
        # Generate random password
        password=$(tr -dc 'A-Za-z0-9!?%#&' < /dev/urandom | head -c 12)

        # Create user and assign password
        useradd -m "$user"
        echo "$user:$password" | chpasswd

        # Store the created user and password
        echo "$user,$password" >> "$PASSWD_DIR/$PASSWD_FILE"
        echo "$(date "+%Y-%m-%d %H:%M:%S") user with username: $user cretaed by user $(whoami)" >> $logPath
    fi

    # Split the groups by comma and add user to each group
    IFS=',' read -ra GROUP_ARRAY <<< "$groups"
    for group in "${GROUP_ARRAY[@]}"; do
        usermod -aG "$group" "$user"
        echo "$(date "+%Y-%m-%d %H:%M:%S") user with username: $user added to group :$group by user $(whoami)" >> $logPath
    done

done < "$CSV_FILE"
```

### Important Notes

1. **Separators:** The CSV file uses `;` to separate usernames and groups, and `,` to separate multiple groups.
2. **Logging:** All actions taken concerning user creation are logged to a file with timestamps.

### Running the Script

To run the script, follow these steps:
1. Ensure you are running on a Linux system with root privileges or use the `sudo` command.
2. Clone the repository and navigate to the directory.
3. Create a sample CSV file `users.csv` with content:

    ```csv
    mary;developer,sys-admin
    paul;sys-admin
    peter;operations
    ```

4. Execute the script as shown add **sudo** if you are not a root user:

    ```bash
    bash create_users.sh users.csv
    ```

After running the script, new users will be created, and their details will be stored in `/var/secure/user_passwords.csv`. All actions will be logged in `/var/secure/user_management.txt`.

To learn more about bash scripting join us at [HNG Internship](https://hng.tech/internship) or subscribe and become a premium member by joining [HNG Premium](https://hng.tech/premium)