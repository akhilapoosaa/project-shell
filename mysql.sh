#!/bin/bash

#mysql service setup script
# This script is used to set up the mysql service for the roboshop application
# It installs the mysql server, creates a roboshop database, and loads the schema from the schema.sql file
# It also creates a roboshop user and grants privileges to the user on the roboshop database

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"      
N="\e[0m" 

TIMESTAMP=$(date '+%F-%H-%M-%S') 
LOGFILE="/tmp/$0-$TIMESTAMP.log"  
SCRIPT_DIR=$(pwd)
#stores the log file in the /tmp directory with the name of the script and the timestamp

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]  
    then 
        echo -e "$2 ... $R FAILED $N" 
    else
        echo -e "$2 ... $G SUCCESS $N" 
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: please run the script with root access $N"
    exit 1
else
    echo -e "$G SUCCESS:: script is running with root access $N"
fi 

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "disabling mysql module"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "copying mysql repo file"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "installing mysql server"
#mysql-community-server is the package name for mysql server in the default mysql repo

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysql service"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql service"
#systemctl start mysqld command is used to start the mysql service
#systemctl enable mysqld command is used to enable the mysql service to start on boot

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "securing mysql root password"
#mysql_secure_installation command is used to secure the mysql installation
#It will prompt for the root password, which is generated during the installation
#The password is stored in the /var/log/mysqld.log file
#The password can be found by running the following command
#grep 'temporary password' /var/log/mysqld.log
#The password is used to log in to the mysql server for the first time




