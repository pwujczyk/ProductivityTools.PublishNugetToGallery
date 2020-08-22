function Publish-NugetToGallery {
	
	[Cmdletbinding()]
	param(
		[string]$Path=$(Get-Location)
	)

	Write-Verbose "Hello from Publish-NugetToGallery"
	Write-Verbose $Path

	dotnet pack
	
	$nugetApiKey=Get-MasterConfiguration "nugetApiKey"
	$nugets=Get-ChildItem *.nuget -Recurse
	foreach($nuget in $nugets)
	{
		dotnet nuget push -s https://api.nuget.org/v3/index.json -k $nugetApiKey $nuget
	}
}

Export-ModuleMember Publish-NugetToGallery