#!/bin/bash

#payment service setup script
# This script is used to set up the payment service for the Roboshop application.
# It installs the payment service dependencies, creates a roboshop user, and sets up the application directory.
# It also downloads the payment service code, extracts it, and installs the required Node.js modules.
# It also sets up the systemd service for the payment service and starts the service.

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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python3 and gcc"
#python3-devel is a package that contains the header files and libraries needed to build Python extensions
#python3-devel is required to install the payment service dependencies
#gcc is a compiler that is used to compile the payment service code

#Application User Setup
id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already exists ... $Y SKIPPED $N" 
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"
#-p option is used to create the directory if it does not exist

#download and extract payment app
curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>> $LOGFILE
VALIDATE $? "downloading payment application zip file"

cd /app &>> $LOGFILE
unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "extracting payment application zip file"

cd /app/payment &>> $LOGFILE
pip3 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing payment application dependencies"
#pip3 is a package manager for Python packages
#-r option is used to specify the requirements file
#requirements.txt is a file that contains the list of dependencies required by the payment service
#pip3 install -r requirements.txt will install all the dependencies listed in the requirements.txt file

cp $SCRIPT_DIR/payment.service  /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment service file to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading systemd daemon"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling payment service"

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment service"



