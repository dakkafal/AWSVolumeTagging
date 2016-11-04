# AWSVolumeTagging
A powershell and shell script to tag ec2 instance volumes. 

NOTE: We assign our tags based on Location, Environment, Service, Role, and a couple others (such as cloudformation stack ID). 
      You will want to change what is extracted from the tags property of 

We specified which tags to mirror from the ec2 instance rather than assigning all tags to the instance, this is because some tags like cloudformation stack id and similar tags were not wanted on the volumes. 

At the company I work for, we automated this by adding into to our cloudformation Metadata via the Troposphere library. 

These scripts will tag all volumes attached to an ec2 instance. 
