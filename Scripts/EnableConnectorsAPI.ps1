param(
    [Parameter(Mandatory=$true)]$TenantId, 
    [Parameter(Mandatory=$true)]$ClientId,
    [Parameter(Mandatory=$true)]$ClientSecret,
    [Parameter(Mandatory=$true)]$SubscriptionId, 
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$ConnectorsFile
)

#Normalized Subscription ID
$SubscriptionIdNormalized = $SubscriptionId -replace '-',''


#Name of the Azure DevOps artifact
$artifactName = "ConnectorsFile"

#Build the full path for the analytics rule file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$connectorsFilePath = Join-Path $artifactPath $ConnectorsFile

#Resource URL to authentincate against
$Resource = "https://management.azure.com/"

#Urls to be used for Sentinel API calls
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
$connectors = Get-Content -Raw -Path $connectorsFilePath | ConvertFrom-Json

foreach ($connector in $connectors.connectors) {
    Write-Host "Processing alert rule: " -NoNewline 
    Write-Host "$($connector.kind)" -ForegroundColor Green

    #AzureActivityLog connector
    if ($connector.kind -eq "AzureActivityLog") {
        $uri = "$baseUri/datasources/${SubscriptionIdNormalized}?api-version=2015-11-01-preview"

        try {
            $result = Invoke-webrequest -Uri $uri -Method Get -Headers $Headers
            Write-Output "Successfully queried data connctor $($connector.kind) - already enabled"
        }
        catch { 
            $errorReturn = $_
            if ($_.Exception.Response.StatusCode.value__ = 404) {
                Write-Host "Data connector $($connector.kind) is not enabled"  
                Write-Host "Enabaling dataconnector $($connector.kind) now"

                $connectorProperties = @{
                    linkedResourceId = "/subscriptions/${SubscriptionId}/providers/microsoft.insights/eventtypes/management"
                }        
                
                $connectorBody = @{
                    kind = $connector.kind
                    properties = $connectorProperties
                }
                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($connectorBody | ConvertTo-Json -EnumsAsStrings)
                    Write-Output "Successfully enabled connector: $($connector.kind) with status: $($result.StatusDescription)"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
                catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }   
            }
            else {
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop           
            }
        }
    }

    #AzureSecurityCenter connector
    if ($connector.kind -eq "AzureSecurityCenter") {
        #unknown ID, clarify with Javi
        $curiousId = "1e1b282a-ce14-4feb-8bc1-48249fab9109"
        $uri = "$baseUri/providers/Microsoft.SecurityInsights/dataConnectors/${curiousId}?api-version=2019-01-01-preview"

        try {
            $result = Invoke-webrequest -Uri $uri -Method Get -Headers $Headers
            Write-Output "Successfully queried data connctor $($connector.kind) - already enabled"
        }
        catch { 
            $errorReturn = $_
            if ($_.Exception.Response.StatusCode.value__ = 404) {
                Write-Host "Data connector $($connector.kind) is not enabled"  
                Write-Host "Enabaling dataconnector $($connector.kind) now"

                $connectorBody = @{
                    kind = $connector.kind
                    properties = @{
                        subscriptionId = $SubscriptionId
                        dataTypes = @{
                            alerts = @{
                                state = $connector.properties.dataTypes.alerts.state
                            }
                        }
                    }
                }
                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $Headers -Body ($connectorBody | ConvertTo-Json -Depth 4 -EnumsAsStrings)
                    Write-Output "Successfully enabled connector: $($connector.kind) with status: $($result.StatusDescription)"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
                catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }   
            }
            else {
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop           
            }
        }
    }
}