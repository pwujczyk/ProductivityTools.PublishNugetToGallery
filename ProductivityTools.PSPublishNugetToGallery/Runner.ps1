clear
cd $PSScriptRoot
Import-Module .\ProductivityTools.PSPublishNugetToGallery.psm1 -Force 
Publish-NugetToGallery -Verbose -Path "D:\GitHub\ProductivityTools.Purchase.Contract"