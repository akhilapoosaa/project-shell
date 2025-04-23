#!/bin/bash

#catalogue service setup script

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"      
N="\e[0m" 

MONGODB_HOST=mongodb.abcompanies.store
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

#Nodejs setup
dnf module disable nodejs -y
VALIDATE $? "disabling current nodejs module" &>> $LOGFILE

dnf module enable nodejs:18 -y
VALIDATE $? "enabling nodejs:18 module" &>> $LOGFILE

dnf install nodejs -y 
VALIDATE $? "installing nodejs 18" &>> $LOGFILE

#Application User Setup
useradd roboshop 
VALIDATE $? "creating roboshop user" &>> $LOGFILE
#useradd command is used to create a new user in the system

mkdir /app
VALIDATE $? "creating app directory" &>> $LOGFILE

#download and extract catalogue app
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloading catalogue application zip file" &>> $LOGFILE
#curl command is used to download the zip file from the given URL
# -o option is used to specify the output file name
# /tmp/catalogue.zip is the output file name

cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue application zip file" &>> $LOGFILE

#npm is a package manager for JavaScript and is used to install the required packages for the application
npm install 
VALIDATE $? "installing catalogue application dependencies" &>> $LOGFILE

#systemd service setup
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
#copying the catalogue service file to the systemd directory
#systemd is a system and service manager for Linux operating systems
VALIDATE $? "copying catalogue service file" &>> $LOGFILE

systemctl daemon-reload 
VALIDATE $? "reloading systemd daemon" &>> $LOGFILE

systemctl enable catalogue 
VALIDATE $? "enabling catalogue service" &>> $LOGFILE

systemctl start catalogue 
VALIDATE $? "starting catalogue service"  &>> $LOGFILE

#mongoDB client setup
cp $SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
#copying the mongo repo file to the yum repository directory
VALIDATE $? "copying mongodb repo file" 

dnf install mongodb-org-shell -y 
#installing the mongodb shell
VALIDATE $? "installing mongodb client"  &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js  &>> $LOGFILE
#running the mongo command to import the schema file into the mongodb database
#--host option is used to specify the host name of the mongodb server
VALIDATE $? "loading catalogue schema into mongodb"  &>> $LOGFILE




