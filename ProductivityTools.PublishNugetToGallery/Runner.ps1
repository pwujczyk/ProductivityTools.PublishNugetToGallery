clear
cd $PSScriptRoot
Import-Module .\ProductivityTools.PublishNugetToGallery.psm1 -Force 
Get-ChildItem
cd d:\GitHub\ProductivityTools.BankAccounts.Contract\
cd d:\GitHub\ProductivityTools.SendEmailGmail\

Publish-NugetToGallery  -Verbose -IncreaseVersionPatch
