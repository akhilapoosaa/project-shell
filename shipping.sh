#!/bin/bash

#shipping service setup script

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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"
#Maven is a build automation tool used primarily for Java projects. 
#it is used to build the shipping application and also manage the dependencies of the application and run tests.

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $LOGFILE   
VALIDATE $? "downloading shipping application zip file"
# -L option is used to follow redirects if the URL is redirected to another URL

cd /app &>> $LOGFILE
unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping application"
#-o option is used to overwrite the existing files without prompting

mvn clean package &>> $LOGFILE
VALIDATE $? "building shipping application"
#clean command is used to remove the previous build artifacts. 
#package command is used to create the new build artifacts

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moving shipping application jar file"

cp $SCRIPT_DIR/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping service file to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading systemd daemon"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabling shipping service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping service"
#systemctl command is used to control the systemd system and service manager
#daemon-reload command is used to reload the systemd manager configuration
#enable command is used to enable the service to start on boot

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql"
#MySQL is a relational database management system based on SQL (Structured Query Language).
#It is used to store the data for the shipping application and act as a backend database for the application.

mysql -h mysql.abcompanies.store -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "importing shipping application schema"
#mysql command is used to connect to the MySQL server and execute the SQL script to create the database and tables for the shipping application
#-h option is used to specify the host name of the MySQL server
#-u option is used to specify the user name to connect to the MySQL server
#-p option is used to specify the password for the user
#< operator is used to redirect the input from the SQL script file to the mysql command
#schema/shipping.sql is the SQL script file that contains the database schema for the shipping application
#mysql is a command line client for MySQL server
#mysql is used to execute SQL commands and manage the MySQL server

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping service"

