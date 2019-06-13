function ConvertTo-Mocks {
	param(
		[Parameter(Mandatory)]
		[string] $ConstructorSource
	)

	if ( -Not ( $ConstructorSource -replace "\n", "" -Match '(?m)(\w+)\((.*)\)' ) ) {
		throw "Unable to parse constructor."
	}

	$className = $Matches[1]
	$downcaseClassName = $className[0].ToString().ToLower() + $className.Substring(1)
	$constructorParameters = $Matches[2].Split(",")
	$mockDefinitions = @( "private readonly $className _$downcaseClassName" )
	$mockInitializations = @()
	$mockConstructorArguments = @()
	foreach ( $constructorParameter in $constructorParameters ) {
		$removedDecorators = $constructorParameter.Trim() -replace '\s*\[.*\]\s*', ''
		$interfaceAndName = $removedDecorators.Split( " " )
		$interface = $interfaceAndName[0]
		$name = $interfaceAndName[1]
		$mockDefinitions += "private readonly Mock<$interface> _$name;"
		$mockInitializations += "_$name = new Mock<$interface>();"
		$mockConstructorArguments += "_$name.Object"
	}

	$constructor = "_$downcaseClassName = new $className(`n`t$($mockConstructorArguments -join ",`n`t")`n);"
	$mocks = @{
		MockDefinitions = $mockDefinitions -join "`n"
		MockInitializations = $mockInitializations -join "`n"
		Constructor = $constructor
	}

	Write-Host $mocks.MockDefinitions
	Write-Host ""
	Write-Host $mocks.MockInitializations
	Write-Host ""
	Write-Host $mocks.Constructor

	$mocks
}