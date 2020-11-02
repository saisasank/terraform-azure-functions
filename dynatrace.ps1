#----------------------------------------------------------
# Install Dynatrace extensions ............----------------
#----------------------------------------------------------

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
	[string]$subscription,

    [Parameter(Mandatory=$True)]
	[string]$resourceGroup,

    [Parameter(Mandatory=$True)]
	[string]$appName,

	[Parameter(Mandatory=$True)]
	[string]$environmentId,

    [Parameter(Mandatory=$True)]
    [string]$apiToken,

    [string]$apiUrl = "",

    [string]$sslMode = "Default"
)

function write-info($Message)
    { Write-Host ("INFO :   [{0:s}] {1}`r" -f (get-date), $Message) -foregroundcolor cyan }
function write-success($Message)
    { Write-Host ("INFO :   [{0:s}] {1}`r" -f (get-date), $Message) -foregroundcolor green}

write-info "Using Azure CLI to retrieve the publishing profiles..."
write-info -Message "================================================================================="
# Get SCM credentials
$data = (az webapp deployment list-publishing-profiles --name $appName --subscription $subscription --resource-group $resourceGroup | ConvertFrom-Json) | Where-Object {$_.publishMethod -eq 'MSDeploy'}
$scmUrl = "https://{0}" -f $data.publishUrl
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $data.userName,$data.userPWD)))
write-success "done`n"

# Install Site Extension via KUDU Rest API
write-info "Install Site Extension via KUDU Rest API..."
write-info -Message "================================================================================="
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $credentials)} -Method 'PUT' -Uri ("{0}/api/siteextensions/Dynatrace" -f $scmUrl)
write-success "done`n"

# Kill Kudu's process, so that the Site Extension gets loaded next time it starts. This returns a 502, but can be ignored.
write-info " Kill Kudu's process, so that the Site Extension gets loaded next time it starts. This returns a 502, but can be ignored...."
write-info -Message "================================================================================="
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $credentials)} -Method 'DELETE' -Uri ("{0}/api/processes/0" -f $scmUrl)
write-success "done`n"

# Now you can make make queries to the Dynatrace Site Extension API.
# If it's the first request to the SCM website, the request may fail due to request-timeout.
write-info "Making queries to the Dynatrace Site Extension API - since it's likely the first request to the SCM website, the request may fail due to request-timeout."
write-info -Message "================================================================================="
$retry = 0
while ($true) {
    try {
        $status = Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $credentials)} -Uri ("{0}/dynatrace/api/status" -f $scmUrl)
    } catch {
        $_
    }

    if (++$retry -ge 3) {
            break
    }
}
write-success "done`n"

#----------------------------------------------------------
# Install the agent through extensions API ----------------
#----------------------------------------------------------
write-info "Install the agent through extensions API..."
write-info -Message "================================================================================="
$settings = @{
    "environmentId" = $environmentId
    "apiUrl"        = $apiUrl
    "apiToken"      = $apiToken
    "sslMode"       = $sslMode
}
Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $credentials)} -Method 'PUT' -ContentType "application/json" -Uri ("{0}/dynatrace/api/settings" -f $scmUrl) -Body ($settings | ConvertTo-Json)
write-success "done`n"

write-info "Waiting until the agent is installed or the installation fails..."
write-info -Message "================================================================================="
# Wait until the agent is installed or the installation fails
while ($true) {
    $status = Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $credentials)} -Uri ("{0}/dynatrace/api/status" -f $scmUrl)
    if (($status.state -eq "Installed") -or ($status.state -eq "Failed")) {
        break
    }

    Start-Sleep -Seconds 10
}
write-success "done`n"

# Restart app-service so changes gets applied
write-info "Restart app-service so changes gets applied..."
write-info -Message "================================================================================="
az functionapp restart --name $appName --resource-group $resourceGroup
write-success "done`n"

write-success "Updates should be complete at this time - yay you!" -Color "green"