#!/bin/bash

#user service setup script

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"      
N="\e[0m" 

MONGODB_HOST=mongod.abcompanies.store
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

dnf install ngnix -y &>> $LOGFILE

VALIDATE $? "installing nginx"
#nginx is a web server that can be used to serve static files and also act as a reverse proxy server
#nginx is used to serve the frontend application and also act as a reverse proxy server for the backend application

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx service"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx service"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
#nginx default document root is /usr/share/nginx/html
VALIDATE $? "removing default nginx website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "downloading web application zip file"
#curl command is used to download the web application zip file from the s3 bucket

cd /usr/share/nginx/html
VALIDATE $? "moving ngnx html directory"

unzip -o /tmp/web.zip
VALIDATE $? "unzipping web application"

cp $SCRIPT_DIR/roboshop.conf   /etc/nginx/default.d/roboshop.conf 
VALIDATE $? "copying roboshop.conf file to nginx default directory"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx service"


