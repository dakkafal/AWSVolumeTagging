$instanceID = (Invoke-WebRequest -UseBasicParsing "http://169.254.169.254/latest/meta-data/instance-id").Content
$identityDocument = (Invoke-WebRequest http://169.254.169.254/latest/dynamic/instance-identity/document -UseBasicParsing).Content | ConvertFrom-Json
$region = $identityDocument.region
$instance = Get-EC2Instance -Instance $instanceId -Region $region

$instanceData = aws ec2 describe-instances --region $region --instance-ids $instanceID
$instancePSO = $instanceData | out-string | convertfrom-json
$cleanedInstanceId = $instanceId.Replace("i-", "").ToUpper()

$tags = $instance.Instances[0].Tags
$location = $tags | ?{ $_.Key -eq "Location" }
$environment = $tags | ?{ $_.Key -eq "Environment" }
$role = $tags | ?{ $_.Key -eq "Role" }
$service = $tags | ?{ $_.Key -eq "Service" }

$subservice= @{}
$subservice.Key = "Subservice"
$subservice.Value = "VOL"
$wantedTags = @($location, $environment, $role, $service)

$name = @{}
$name.Key = "Name"
$name.Value = $location.Value+$environment.Value+$role.Value+$service.Value+$subservice.Value+$cleanedInstanceId

$blockDevices = $instancePSO.Reservations.Instances.BlockDeviceMappings
$blockDevices | % {
    $vol = $_.Ebs.VolumeId
    write-host $vol
    foreach ($tag in $wantedTags) {
       New-EC2Tag -resource $vol -tag $tag
    }
    New-EC2Tag -resource $vol -tag $subservice
    New-EC2Tag -resource $vol -tag $name
}

#aws ec2 describe-instance --region us-east-1 --instance-ids i-895e9f1a