Install-PackageProvider nuget -Scope CurrentUser -Force -Confirm:$false
write-host "nuget installed"
 
Install-Module -Name AZ -AllowClobber -Scope CurrentUser -Force -Confirm:$False -SkipPublisherCheck
write-host "az installed"
 
Install-Module -Name d365fo.integrations  -AllowClobber -Scope CurrentUser -Force -Confirm:$false
write-host "d365fo.integrations installed"
 
Add-D365ODataConfig -Name "D365EnableUsers" -Tenant "AzureTenantId" -url "https://yourenvironment.sandbox.operations.dynamics.com" -ClientId "AzureApplicationId" -ClientSecret "AzureApplicationClientSecret"
write-host "Config added"
 
Set-D365ActiveODataConfig -Name D365EnableUsers
write-host "Config as default"

$token = Get-D365ODataToken
write-host "Token generated"

$SystemUsers = Get-D365ODataEntityData -EntityName SystemUsers -ODataQuery '$filter=Enabled eq false' -Token $token
#select the disabled users

$payload = '{"Enabled": "true"}'
#set the field names and the desired values to update

foreach ($user in $SystemUsers)
{
    #iterate through the users and create the [key, payload] array
    $userId = $user.UserID
    if($SystemUsersToUpdateNew)
    {
        $SystemUsersToUpdateNew += [PSCustomObject]@{Key = "UserID='$userId'"; Payload = $payload}
    }
    else {
        $SystemUsersToUpdateNew  = @([PSCustomObject]@{Key = "UserID='$userId'"; Payload = $payload})        
    }
}

Update-D365ODataEntityBatchMode -EntityName "SystemUsers" -Payload $SystemUsersToUpdateNew -Verbose -Token $token
#call the update command 