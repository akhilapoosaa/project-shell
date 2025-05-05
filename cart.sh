#!/bin/bash

#cart service setup script

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

#Nodejs setup
dnf module disable nodejs -y  &>> $LOGFILE
VALIDATE $? "disabling current nodejs module" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs:18 module" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs 18" 

#Application User Setup
id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already exists ... $Y SKIPPED $N" 
fi

mkdir -p /app &>> $LOGFILE #-p option is used to create the directory if it does not exist
VALIDATE $? "creating app directory" 

#download and extract catalogue app
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGFILE
VALIDATE $? "downloading cart application zip file" 
#curl command is used to download the zip file from the given URL
# -o option is used to specify the output file name
# /tmp/catalogue.zip is the output file name

cd /app
unzip -o /tmp/cart.zip &>> $LOGFILE # -o option is used to overwrite the existing files 
VALIDATE $? "unzipping cart application zip file" 

#npm is a package manager for JavaScript and is used to install the required packages for the application
npm install &>> $LOGFILE
VALIDATE $? "installing cart application dependencies" 

#systemd service setup
cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service  &>> $LOGFILE
#copying the catalogue service file to the systemd directory
#systemd is a system and service manager for Linux operating systems
VALIDATE $? "copying cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading systemd daemon" 

systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling cart service" 

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart service"  




