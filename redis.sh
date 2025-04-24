#!/bin/bash

#redis service is used to store the session data of the application
#redis is an in-memory data storage, uand allows users to access the data of database over API.
#redis is a NoSQL database, it is used to store data in key-value format

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"      
N="\e[0m" 

TIMESTAMP=$(date '+%F-%H-%M-%S') 
LOGFILE="/tmp/$0-$TIMESTAMP.log" 
exec &>$LOGFILE #executes the command and redirects the output to the log file

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
VALIDATE $? "installing remi release package"

dnf module enable redis:remi-6.2 -y 
VALIDATE $? "enabling redis module"

dnf install redis -y 
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "updating redis config file to allow remote connections"

systemctl enable redis 
VALIDATE $? "enabling redis service"

systemctl start redis 
VALIDATE $? "starting redis service"


