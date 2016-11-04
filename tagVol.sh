#!/bin/bash
volCheck() {
    check="true"
    count=1
    while [ "$check" = "true" ]; do
        vol=$(echo $blockDevices | awk -F ' ' -v item=$count '{print $item}')
        if [ -n "$vol" ]; then #if vol exists, then call tag function
            echo "vol $vol exists"
            tag $vol
            ((count++))
        else
            check="false"
        fi
    done
}   
tag() {
    aws ec2 create-tags --region $REGION --resources $1 --tags Key=Location,Value=$LOCATION Key=Environment,Value=$ENVIRONMENT Key=Service,Value=$Service Key=Role,Value=$ROLE Key=Subservice,Value=VOL Key=Name,Value=$LONGNAME
    echo "tagging this vol: $1"
}

INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTDATA=$(aws ec2 describe-instances --region $REGION --filters "Name=instance-id,Values=$INSTANCEID")

TAGS=$(echo "$INSTDATA" | jq ".Reservations[0].Instances[0].Tags")
LOCATION=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Location").Value')
ENVIRONMENT=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Environment").Value')
SERVICE=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Service").Value')
ROLE=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Role").Value')
LONGNAME=$(echo $LOCATION$ENVIRONMENT$ROLE$SERVICE"VOL" | awk '{print toupper($0)}')

blockDevices=$(echo "$INSTDATA" | jq -r '.Reservations[0].Instances[0].BlockDeviceMappings[].Ebs.VolumeId')

volCheck