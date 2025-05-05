#!/bin/bash

#using mongodb repo to install mongodb
#mongodb is a NoSQL database, it is used to store data in JSON format

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" #reset the color or no color

TIMESTAMP=$(date '+%F-%H-%M-%S') #date command is used to get the current date and time and stores it in the variable TIMESTAMP
LOGFILE="/tmp/$0-$TIMESTAMP.log"  #stores the log file in the /tmp directory with the name of the script and the timestamp
SCRIPT_DIR=$(pwd)

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]  #if the exit status of the command is not 0, then the command has failed
    then 
        echo -e "$2 ... $R FAILED $N" #if the command has failed, then print the message as failed in red color
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" #if the command has passed, then print the message as success in green color
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: please run the script with root access $N"
    exit 1
else
    echo -e "$G SUCCESS:: script is running with root access $N"
fi 

cp $SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying MongoDB repo file" 

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing MongoDB"    

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling MongoDB service"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting MongoDB service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE  
#sed command is used to find and replace the IP address in the config file
VALIDATE $? "updating MongoDB config file to allow remote access"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting MongoDB service"