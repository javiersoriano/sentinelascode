# Variables
<# $config = Get-Content -Raw -Path ..\config.json | ConvertFrom-Json

$TenantId = $config.tenantid
$ClientId = $config.clientid
$ClientSecret = $config.clientsecret
$Resource = $config.resource
$SubscriptionId = $config.subscriptionid
$ResourceGroup = $config.resourcegroup
$Workspace = $config.workspace #>

param(
    [Parameter(Mandatory=$true)]$TenantId, 
    [Parameter(Mandatory=$true)]$ClientId,
    [Parameter(Mandatory=$true)]$ClientSecret,
    [Parameter(Mandatory=$true)]$SubscriptionId, 
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile
)

$artifactName = "RulesFile"
Write-Host "The rules file is here: $RulesFile"
$buildId = [System.Environment]::GetEnvironmentVariable("Release_Artifacts_$($RulesFile)_BuildId");

Write-Host "ArtifactsDirectory: $($env:System_ArtifactsDirectory) - BuildId: $BuildId"

$files = Get-ChildItem -Path $env:System_ArtifactsDirectory -Recurse

Write-Host $files

$path1 = Join-Path $env:System_ArtifactsDirectory $artifactName;
Write-Host "Path1 : $path1"
$path2 = Join-Path $path1 $RulesFile

$Resource = "https://management.azure.com/"

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

#Getting all rules from config file
$rules = Get-Content -Raw -Path $path2 | ConvertFrom-Json

foreach ($rule in $rules.analytics) {
    Write-Host "Processing alert rule: " -NoNewline 
    Write-Host "$($rule.displayName)" -ForegroundColor Green

    $existingRule = Get-AzSentinelAlertRule -WorkspaceName $Workspace -RuleName $rule.displayName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Alert $($rule.displayName) already exists"

        if ($rule.kind -eq "Scheduled") {
            Write-Host "Rule type is Scheduled. Using AzSentinel..."
            
            New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics
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
            
            New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics
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