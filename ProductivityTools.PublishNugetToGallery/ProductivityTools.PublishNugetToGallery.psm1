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


function GetPropertyGroup()
{
	[Cmdletbinding()]
	param(
		[xml]$proj
	)
	
	
	$array=$proj.Project.PropertyGroup -is [array]
	if($array)
	{
		Write-Verbose "In csproj we have couple of the property group nodes. Taking the first one!"
		$propertyGroup=$proj.Project.PropertyGroup[0]
	}
	else
	{
		$propertyGroup=$proj.Project.PropertyGroup
	}
	return $propertyGroup;
	
}

function IncreaseVersionPatch{
	$csprojs=Get-ChildItem *.csproj -Recurse
	foreach($csproj in $csprojs)
	{
		[xml]$proj=Get-Content $csproj

		$propertyGroup=GetPropertyGroup $proj
		
		$sVersion=$propertyGroup.Version
		Write-Verbose "Current version for project $csProj is $sVersion"
		if ($sVersion -ne $nuget -and $sVersion -ne "")
		{
			$sValue=$sVersion.Substring($sVersion.LastIndexOf('.')+1)
			$iValue=$sValue -as [int]
			$iValue++
			$mainVersion=$sVersion.Substring(0,$sVersion.LastIndexOf('.')+1)
			$updatedVersion=$mainVersion+$iValue.ToString();
			$propertyGroup.Version=$updatedVersion
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
		$propertyGroup=GetPropertyGroup $proj
		$sVersion=$propertyGroup.Version
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
	[Cmdletbinding()]
	param()
	
	$nugetApiKey=Get-MasterConfiguration "NugetApiKey" -Verbose:$VerbosePreference
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
	if ($IncreaseVersionPatch)
	{
		IncreaseVersionPatch 
	}
	CreateNugets
	PushNugets -Verbose:$VerbosePreference
}

Export-ModuleMember Publish-NugetToGallery