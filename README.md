# AWSVolumeTagging
A powershell and shell script to tag ec2 instance volumes. 
We specified which tags to mirror from the ec2 instance rather than assigning all tags to the instance, this is because some tags like cloudformation stack id and similar tags were not wanted on the volumes. 
At the company I work for, we automated this by adding into to our cloudformation Metadata.

These scripts will tag all volumes attached to an ec2 instance. 
