clear
cd $PSScriptRoot
Import-Module .\ProductivityTools.PublishNugetToGallery.psm1 -Force 
Get-ChildItem
cd d:\GitHub\ProductivityTools.BankAccounts.Contract\
cd  D:\GitHub-3.PublishedToLinkedIn\ProductivityTools.NetworkUtilities

Publish-NugetToGallery  -Verbose -IncreaseVersionPatch
