param(
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Folder,
    [Parameter(Mandatory=$true)]$Workspace
)

Write-Host "Folder is: $($Folder)"

$armTemplateFiles = Get-ChildItem -Path $Folder -Filter *.json

Write-Host "Files are: " $ArmTemplateFiles

foreach ($ArmTemplate in $ArmTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $ArmTemplate -WorkspaceName $Workspace
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Deployment failed with message: $ErrorMessage" 
    }
}