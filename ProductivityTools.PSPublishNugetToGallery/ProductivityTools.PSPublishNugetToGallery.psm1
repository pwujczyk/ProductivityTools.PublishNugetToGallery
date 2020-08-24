function IncreaseVersionPatch{
	$csprojs=Get-ChildItem *.csproj -Recurse
	foreach($csproj in $csprojs)
	{
		[xml]$proj=Get-Content $csproj
		$sVersion=$proj.Project.PropertyGroup.Version
		if ($sVersion -ne "")
		{
			$sValue=$sVersion.Substring($sVersion.LastIndexOf('.')+1)
			$iValue=$sValue -as [int]
			$iValue++
			$mainVersion=$sVersion.Substring(0,$sVersion.LastIndexOf('.')+1)
			$proj.Project.PropertyGroup.Version=$mainVersion+$iValue.ToString();
			$proj.Save($csproj.FullName)
		}
		
	}
}

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
Export-ModuleMember IncreaseVersionPatch