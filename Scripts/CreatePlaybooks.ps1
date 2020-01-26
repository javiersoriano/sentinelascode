param(
    [Parameter(Mandatory=$true)]$resourceGroup,
    [Parameter(Mandatory=$true)]$PlaybooksFolder
)

Write-Host "Folder is: $($PlaybooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $PlaybooksFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Playbook deployment failed with message: $ErrorMessage" 
    }
}