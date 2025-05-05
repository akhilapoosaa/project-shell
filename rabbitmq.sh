#!/bin/bash

#rabbitmq service setup script
# This script is used to set up the RabbitMQ service for the Roboshop application.
# It installs the RabbitMQ server, enables the RabbitMQ management plugin, and starts the RabbitMQ service.
# It also creates a RabbitMQ user and sets the password for the user.

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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading erlang repo"
#Erlang is a programming language used to build distributed systems.
#RabbitMQ is built on top of Erlang, so we need to install Erlang first.

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installing rabbitmq server"
#RabbitMQ is a message broker that allows applications to communicate with each other by sending messages.
#It is used to decouple the application components and improve the scalability and reliability of the application.
#RabbitMQ is used to send messages between the frontend and backend applications in the Roboshop application.  

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabling rabbitmq service"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating rabbitmq user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting rabbitmq user permissions"
#The set_permissions command is used to set the permissions for the user on the RabbitMQ server.
#The -p option is used to specify the vhost for which the permissions are set.
#In this case, we are setting the permissions for the default vhost (/).

