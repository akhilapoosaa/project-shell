#!/bin/bash

#catalogue service 

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"      
N="\e[0m" 
MONGODB_HOST=mongodb.abcompanies.store

TIMESTAMP=$(date '+%F-%H-%M-%S') 
LOGFILE="/tmp/$0-$TIMESTAMP.log"  
#stores the log file in the /tmp directory with the name of the script and the timestamp

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]  
    then 
        echo -e "$2 ... $R FAILED $N" 
    else
        echo -e "$2 ... $G SUCCESS $N" 

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: please run the script with root access $N"
    exit 1
else
    echo -e "$G SUCCESS:: script is running with root access $N"
fi 

dnf module disable nodejs -y

VALIDATE $? "disabling current nodejs module" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "enabling nodejs 18 module" &>> $LOGFILE

dnf install nodejs -y 

VALIDATE $? "installing nodejs 18" &>> $LOGFILE

useradd roboshop 

VALIDATE $? "creating roboshop user" &>> $LOGFILE
#useradd command is used to create a new user in the system

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalogue application zip file" &>> $LOGFILE
#curl command is used to download the zip file from the given URL
# -o option is used to specify the output file name
# /tmp/catalogue.zip is the output file name

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue application zip file" &>> $LOGFILE

npm install 
#npm is a package manager for JavaScript and is used to install the required packages for the application

VALIDATE $? "installing catalogue application dependencies" &>> $LOGFILE

cp /Users/ab/Documents/gitvscode/roboshop-shell /etc/systemd/system/catalogue.service
#copying the catalogue service file to the systemd directory
#systemd is a system and service manager for Linux operating systems

VALIDATE $? "copying catalogue service file" &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading systemd daemon" &>> $LOGFILE

systemctl enable catalogue  &>> $LOGFILE

VALIDATE $? "enabling catalogue service" &>> $LOGFILE

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue service" 

cp /Users/ab/Documents/gitvscode/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
#copying the mongo repo file to the yum repository directory

VALIDATE $? "copying mongodb repo file" &>> $LOGFILE

dnf install mongodb-org-shell -y 
#installing the mongodb shell

VALIDATE $? "installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js
#running the mongo command to import the schema file into the mongodb database
#--host option is used to specify the host name of the mongodb server

VALIDATE $? "loading catalogue schema into mongodb" &>> $LOGFILE




