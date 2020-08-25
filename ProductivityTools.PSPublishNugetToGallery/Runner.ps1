clear
cd $PSScriptRoot
Import-Module .\ProductivityTools.PSPublishNugetToGallery.psm1 -Force 
Get-ChildItem
cd "D:\GitHub\ProductivityTools.Purchase.Contract"

Publish-NugetToGallery -Verbose -Path "D:\GitHub\ProductivityTools.Purchase.Contract" -IncreaseVersionPatch
