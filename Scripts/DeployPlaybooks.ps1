param(
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$PlaybooksFolder
)

Write-Host "Folder is: $($PlaybooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $PlaybooksFolder -Filter *.json

Write-Host "Files are: " $ArmTemplateFiles

foreach ($ArmTemplate in $ArmTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $ArmTemplate 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Playbook deployment failed with message: $ErrorMessage" 
    }
}