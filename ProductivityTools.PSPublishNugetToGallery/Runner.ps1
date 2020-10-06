clear
cd $PSScriptRoot
Import-Module .\ProductivityTools.PSPublishNugetToGallery.psm1 -Force 
Get-ChildItem
cd d:\GitHub\ProductivityTools.BankAccounts.Contract\
cd D:\GitHub\ProductivityTools.MasterConfiguration

Publish-NugetToGallery  -Verbose -IncreaseVersionPatch
