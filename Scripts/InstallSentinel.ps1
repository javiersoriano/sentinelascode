param (
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$OnboardingFile
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

$artifactName = "OnboardingFile"

#Build the full path for the onboarding file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$onboardingFilePath = Join-Path $artifactPath $OnboardingFile

$workspaces = Get-Content -Raw -Path $onboardingFilePath | ConvertFrom-Json

foreach ($wrkspce in $workspaces.workspace){
    Write-Host "Processing workspace $wrkspce ..."
    $solutions = Get-AzOperationalInsightsIntelligencePack -resourcegroupname $ResourceGroup -WorkspaceName $wrkspce

    if (($solutions | Where-Object Name -eq 'SecurityInsights').Enabled) {
        Write-Error "SecurityInsights solution is already enabled for workspace $wrkspce"
        exit
    }
    else {
        Set-AzSentinel -WorkspaceName $wrkspce -Confirm:$false
    }
}

