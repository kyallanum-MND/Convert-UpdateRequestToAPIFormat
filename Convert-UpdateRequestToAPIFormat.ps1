###################################################################
# The purpose of this script is to convert an Update Request from # 
# JSON to X-WWW-FORM-URLENCODED so that an Update Request can be  #
# Sent to WhiteSource Servers via API                             #
# Author: Kyal Lanum                                              #
# Copyright: WhiteSource Software 2021 (c)                        #
###################################################################

function Get-UpdateRequest {
    param (
        [string]$path
    )
    
    try {
        $updateRequestContent = Get-Content -Path "$path/whitesource/update-request.txt" -ErrorAction Stop
    } 
    catch {
        Write-Host -ForegroundColor DarkRed "Could not find the update request in the project given: $path"
        exit 1
    }

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

switch($args[0]) {
    '' {
        $path = $(Get-Location).Path
    }
    '-path' {
        $path = $args[1]
    }
    default {
        Write-Host "Usage:
        Convert-UpdateRequestToAPIFormat --help`t`t`t`t`t(Print this help message)
        Convert-UpdateRequestToAPIFormat`t`t`t`t`t(Executes on your current directory)
        Convert-UpdateRequestToAPIFormat -path `"<C:\Path\To\Your\Project>`"`t(Executes on the project given. Do not include whitesource directory in path)"
        exit 1
    }
}

[PSObject]$updateRequest = Get-UpdateRequest -path $path

[string]$convertedUpdateRequest = Convert-UpdateRequest -updateRequest $updateRequest

return $convertedUpdateRequest