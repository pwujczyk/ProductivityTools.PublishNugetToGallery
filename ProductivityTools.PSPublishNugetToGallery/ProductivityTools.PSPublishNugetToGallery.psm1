function Publish-NugetToGallery {
	
	[Cmdletbinding()]
	param(
		[string]$Path=$(Get-Location)
	)

	Write-Verbose "Hello from Publish-NugetToGallery"
	Write-Verbose $Path
	cd $Path

	dotnet pack

	$nugetApiKey=Get-MasterConfiguration "NugetApiKey" -Verbose
	$nugets=Get-ChildItem *.nupkg -Recurse
	foreach($nuget in $nugets)
	{
		dotnet nuget push $nuget -s https://api.nuget.org/v3/index.json -k $nugetApiKey
	}
}

Export-ModuleMember Publish-NugetToGallery