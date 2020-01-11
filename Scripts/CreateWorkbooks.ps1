param(
    [Parameter(Mandatory=$true)]$resourceGroup,
    [Parameter(Mandatory=$true)]$workbooksFolder,
    [Parameter(Mandatory=$true)]$workbookSourceId
)

Write-Host "Folder is: $($workbooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $workbooksFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -workbookSourceId $workbookSourceId 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Workbook deployment failed with message: $ErrorMessage" 
    }
}