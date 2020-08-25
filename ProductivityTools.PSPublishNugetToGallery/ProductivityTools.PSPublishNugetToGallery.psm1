function IncreaseVersionPatch{
	[Cmdletbinding()]
	param(
		[switch]$IncreaseVersionPatch
	)
	
	if ($IncreaseVersionPatch.IsPresent)
	{
		IncreaseVersionPatch
	}
}

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


function NugetVersionAlignedWithCsProj()
{
	[Cmdletbinding()]
	param(
		$nugetBaseName
	)
	
	$csprojs=Get-ChildItem *.csproj -Recurse
	foreach($csproj in $csprojs)
	{
		$csProjBaseName=$csproj.BaseName
		
		[xml]$proj=Get-Content $csproj
		$sVersion=$proj.Project.PropertyGroup.Version
		Write-Verbose "Current version for project $($csProj.BaseName) is $sVersion"
		if ($sVersion -ne "")
		{
			$properVersion=$csProjBaseName + '.' + $sVersion
			if ($nugetBaseName -eq $properVersion)
			{
				Write-Verbose "$nugetBaseName nuget will be pushed to gallery ";
				return $true;
			}
		}
	}	
	return $false;
}

function CreateNugets{
	[Cmdletbinding()]
	param()
	
	dotnet pack
}

function PushNugets{
	$nugetApiKey=Get-MasterConfiguration "NugetApiKey" -Verbose
	$nugets=Get-ChildItem *.nupkg -Recurse
	foreach($nuget in $nugets)
	{
		$nugetBaseName=$nuget.BaseName
		Write-Verbose "Working with nuget $nugetBaseName"
		if(NugetVersionAlignedWithCsProj $nugetBaseName)
		{
			Write-Verbose "Nuget will be pushed $nuget"
			dotnet nuget push $nuget -s https://api.nuget.org/v3/index.json -k $nugetApiKey
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
	IncreaseVersionPatch -IncreaseVersionPatch:$IncreaseVersionPatch
	CreateNugets
	PushNugets
}

Export-ModuleMember Publish-NugetToGallery