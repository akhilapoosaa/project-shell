#!/bin/bash

AMI=ami-0b4f379183e5706b9 #this keeps on changing
SG_ID=sg-0df99ea72b1922f0a #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web" "dispatch")
ZONE_ID=Z0530618D1B8DOASTNDL # replace your hostedzone ID
DOMAIN_NAME="abcompanies.store"

for i in "${INSTANCES[@]}" # array of instances looping through each instance
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ] # || is used as or 
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $INSTANCE_TYPE --security-group-ids sg-0df99ea72b1922f0a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id Z0530618D1B8DOASTNDL \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done

 # UPSERT is used to create or update the record