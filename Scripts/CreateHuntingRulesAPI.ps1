param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "HuntingFile"

#Build the full path for the hunting rules file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

#Getting all hunting rules from file
$rules = Get-Content -Raw -Path $rulesFilePath | ConvertFrom-Json

foreach ($rule in $rules.hunting) {
    Write-Host "Processing hunting rule: " -NoNewline 
    Write-Host "$($rule.displayName)" -ForegroundColor Green

    $existingRule = Get-AzSentinelHuntingRule -WorkspaceName $Workspace -RuleName $rule.displayName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Hunting rule $($rule.displayName) already exists. Updating..."

        New-AzSentinelHuntingRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
    else {
        Write-Host "Hunting rule $($rule.displayName) doesn't exist. Creating..."

        New-AzSentinelHuntingRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
}