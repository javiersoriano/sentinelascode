param(
    [Parameter(Mandatory=$true)]$TenantId, 
    [Parameter(Mandatory=$true)]$ClientId,
    [Parameter(Mandatory=$true)]$ClientSecret,
    [Parameter(Mandatory=$true)]$SubscriptionId, 
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "RulesFile"

#Build the full path for the analytics rule file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

#Resource URL to authentincate against
$Resource = "https://management.azure.com/"

#Urls to be used for Sentinel API calls
$IdUrl = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace"

$baseUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace"

$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"

$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

Write-Host "Print Token" -ForegroundColor Green
Write-Output $Token

$Headers = @{}

$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")

$Headers.Add("Content-Type", "application/json")

#Getting all rules from file
$rules = Get-Content -Raw -Path $rulesFilePath | ConvertFrom-Json

foreach ($rule in $rules.analytics) {
    Write-Host "Processing alert rule: " -NoNewline 
    Write-Host "$($rule.displayName)" -ForegroundColor Green

    $existingRule = Get-AzSentinelAlertRule -WorkspaceName $Workspace -RuleName $rule.displayName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Alert $($rule.displayName) already exists"

        if ($rule.kind -eq "Scheduled") {
            Write-Host "Rule type is Scheduled. Using AzSentinel..."
            
            try{
                New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics -PlayBookName $rule.playbookName -Confirm:$false
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }
        }
        elseif ($rule.kind -eq "Fusion") {
            Write-Host "Rule type is Fusion"
            $Guid = $existingRule.name
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
    
            $alertProperties = @{
                enabled = $rule.enabled
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                etag = $existingRule.etag
                properties = $alertProperties
            }
                
            Write-Verbose "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully updated rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }    
        }
        elseif ($rule.kind -eq "MicrosoftSecurityIncidentCreation") {
            Write-Host "Rule type is Microsoft Security"
            $Guid = $existingRule.name
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
        
            $alertProperties = @{
                displayName = $rule.displayName
                description = $rule.description
                enabled = $rule.enabled
                productFilter = $rule.productFilter
                severitiesFilter = $rule.severitiesFilter            
                displayNamesFilter = $rule.displayNamesFilter
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                etag = $existingRule.etag
                properties = $alertProperties
            }
                
            #$body = (ConvertTo-Json $alertBody)
            Write-Host "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully updated rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }    
        }
        elseif ($rule.kind -eq "MLBehaviorAnalytics") {
            Write-Host "Rule type is ML Behavior Analytics"
            $Guid = $existingRule.name
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
        
            $alertProperties = @{
                enabled = $rule.enabled
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                etag = $existingRule.etag
                properties = $alertProperties
            }
                
            #$body = (ConvertTo-Json $alertBody)
            Write-Host "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully updated rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }  
        }

    }
    else {
        Write-Host "Alert $($rule.displayName) doesn't exist. Creating rule..."

        if ($rule.kind -eq "Scheduled") {
            Write-Host "Rule type is Scheduled. Using AzSentinel..."
            try {
                New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics -PlayBookName $rule.playbookName
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Error "Alert rule creation failed with message: $ErrorMessage"
            }
        }
        elseif ($rule.kind -eq "Fusion") {
            Write-Host "Rule type is Fusion"
            $Guid = (New-Guid).Guid
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
    
            $alertProperties = @{
                enabled = $rule.enabled
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                properties = $alertProperties
            }
                
            #$body = (ConvertTo-Json $alertBody)
            Write-Host "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully created rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }    
        }
        elseif ($rule.kind -eq "MicrosoftSecurityIncidentCreation") {
            Write-Host "Rule type is Microsoft Security"
            $Guid = (New-Guid).Guid
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
        
            $alertProperties = @{
                displayName = $rule.displayName
                description = $rule.description
                enabled = $rule.enabled
                productFilter = $rule.productFilter
                severitiesFilter = $rule.severitiesFilter            
                displayNamesFilter = $rule.displayNamesFilter
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                properties = $alertProperties
            }
                
            #$body = (ConvertTo-Json $alertBody)
            Write-Host "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully created rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }    
        }
        elseif ($rule.kind -eq "MLBehaviorAnalytics") {
            Write-Host "Rule type is ML Behavior Analytics"
            $Guid = (New-Guid).Guid
    
            $uri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/$($Guid)?api-version=2019-01-01-preview"
        
            $alertProperties = @{
                enabled = $rule.enabled
                alertRuleTemplateName = $rule.alertRuleTemplateName
            }        
                
            $alertBody = @{
                id = "$IdUrl/providers/Microsoft.SecurityInsights/alertRules/$($Guid)"
                name = "$Guid"
                type = "Microsoft.SecurityInsights/alertRules"
                kind = $rule.kind
                properties = $alertProperties
            }
                
            #$body = (ConvertTo-Json $alertBody)
            Write-Host "The alert request's body is: $($alertBody | Out-String)"
    
            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($alertBody | ConvertTo-Json -EnumsAsStrings)
                Write-Output "Successfully created rule: $($rule.displayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }  
        }    
    }
}