###################################################################
# The purpose of this script is to convert an Update Request from # 
# JSON to X-WWW-FORM-URLENCODED so that an Update Request can be  #
# Sent to WhiteSource Servers via API                             #
# Author: Kyal Lanum                                              #
# Copyright: WhiteSource Software 2021 (c)                        #
###################################################################

param(
    [string]$path = $(Get-Location).Path
)

if($args[0] -eq "--help") {
    Write-Host "Usage:
    Convert-UpdateRequestToAPIFormat --help`t(Print this help message)
    Convert-UpdateRequestToAPIFormat -path <C:\Path\To\Your\Project>"
}

function Get-UpdateRequest {
    param (
        [string]$path
    )

    $updateRequestContent = Get-Content -Path "$path/whitesource/update-request.txt"

    $updateRequestObj = $($updateRequestContent | ConvertFrom-Json)

    return $updateRequestObj
}

function Convert-UpdateRequest {
    param (
        [PSObject]$updateRequest
    )

    $projects = $updateRequest.projects | ConvertTo-Json
    if(!($projects.StartsWith('['))) {
        $projects = "[`n" + $projects + "`n]"
    }

    $updateRequestConverted = "type=$($updateRequest.type)
&updateType=$($updateRequest.updateType)
&agent=$($updateRequest.agent)
&agentVersion=$($updateRequest.agentVersion)
&pluginVersion=$($updateRequest.pluginVersion)
&token=$($updateRequest.orgToken)
&userKey=$($updateRequest.userKey)
&product=$($updateRequest.product)
&productVersion=$($updateRequest.productVersion)
&timeStamp=$($updateRequest.timeStamp)
&diff=$($projects)"

    return $updateRequestConverted
}

[PSObject]$updateRequest = Get-UpdateRequest -path $path

[string]$convertedUpdateRequest = Convert-UpdateRequest -updateRequest $updateRequest

return $convertedUpdateRequest