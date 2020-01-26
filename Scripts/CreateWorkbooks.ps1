param(
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$WorkbooksFolder,
    [Parameter(Mandatory=$true)]$WorkbookSourceId
)

Write-Host "Folder is: $($WorkbooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $WorkbooksFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $armTemplate -WorkbookSourceId $WorkbookSourceId 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Workbook deployment failed with message: $ErrorMessage" 
    }
}