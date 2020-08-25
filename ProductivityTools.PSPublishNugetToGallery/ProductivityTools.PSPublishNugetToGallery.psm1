function IncreaseVersionPatch{
	$csprojs=Get-ChildItem *.csproj -Recurse
	foreach($csproj in $csprojs)
	{
		[xml]$proj=Get-Content $csproj
		$sVersion=$proj.Project.PropertyGroup.Version
		Write-Verbose "Current version for project $csProj is $sVersion"
		if ($sVersion -ne "")
		{
			$sValue=$sVersion.Substring($sVersion.LastIndexOf('.')+1)
			$iValue=$sValue -as [int]
			$iValue++
			$mainVersion=$sVersion.Substring(0,$sVersion.LastIndexOf('.')+1)
			$updatedVersion=$mainVersion+$iValue.ToString();
			$proj.Project.PropertyGroup.Version=$updatedVersion
			$proj.Save($csproj.FullName)
			Write-Verbose "Version in $($csproj.FullName) updated to $updatedVersion"
		}	
	}
}

function Publish-NugetToGallery {
	
	[Cmdletbinding()]
	param(
		[string]$Path=$(Get-Location),
		[switch]$IncreaseVersionPatch
	)

	Write-Verbose "Hello from Publish-NugetToGallery"
	Write-Verbose "Performing operation in directory $Path"
	cd $Path

	if ($IncreaseVersionPatch.IsPresent)
	{
		IncreaseVersionPatch
	}
	
	dotnet pack

	$nugetApiKey=Get-MasterConfiguration "NugetApiKey" -Verbose
	$nugets=Get-ChildItem *.nupkg -Recurse
	foreach($nuget in $nugets)
	{
		dotnet nuget push $nuget -s https://api.nuget.org/v3/index.json -k $nugetApiKey
	}
}

Export-ModuleMember Publish-NugetToGallery