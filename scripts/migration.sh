#!/bin/bash

# Variables
INSTALL_DIR="/opt/moodle-docker/migration"
LOG_FILE="$INSTALL_DIR/logs/install.log"
SCRIPT_DIR="$(pwd)"
ENV_FILE="$SCRIPT_DIR/migration/.env"
Ver="V1.0"


# Creating required directories in $INSTALL_DIR
print_cmsg "Creating required directories in $INSTALL_DIR..." | tee -a "$LOG_FILE"
mkdir -p "$INSTALL_DIR/moodle"
mkdir -p "$INSTALL_DIR/moodledata"
mkdir -p "$INSTALL_DIR/db_data"
mkdir -p "$INSTALL_DIR/dumps"
mkdir -p "$INSTALL_DIR/logs/moodle"
mkdir -p "$INSTALL_DIR/logs/apache"
mkdir -p "$INSTALL_DIR/logs/mariadb"

print_cmsg() {
  if [[ "$1" == "-n" ]]; then
    shift
    echo -ne "\e[1m$*\e[0m"
  else
    echo -e "\e[1m$*\e[0m"
  fi
}

if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
    print_cmsg ".env file found and loaded." | tee -a "$LOG_FILE"
else
    print_cmsg ".env file found in $SCRIPT_DIR/migration. Exiting." | tee -a "$LOG_FILE"
    exit 1
fi

# Copy Docker files
print_cmsg "Copying Docker files from $SCRIPT_DIR/migration to $INSTALL_DIR..." | tee -a "$LOG_FILE"
cp "$SCRIPT_DIR/migration/docker-compose.yml" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/migration/Dockerfile" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/migration/.env" "$INSTALL_DIR/"


cp "$SCRIPT_DIR/migration/config.php" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/migration/php.ini" "$INSTALL_DIR/"

# Moodle migration

# Mysql dump
mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" "moodle" > $INSTALL_DIR/dumps/moodle_backup.sql

