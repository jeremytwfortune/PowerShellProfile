function Start-Program {
	[CmdletBinding()]
	param (	)
	dynamicparam {
		$parameterName = "Program"
		$locationData = "$Home\ProgramList.txt"
		if ( -Not ( Test-Path $locationData -ErrorAction SilentlyContinue ) ) {
			throw "File '$locationData' cannot be found"
		}
		$programs = Get-Content $locationData | ConvertFrom-StringData

		$attributeList = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$attributeValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($programs.Keys)
		$attributeList.Add($attributeValidateSet)

		$attributeParameter = New-Object System.Management.Automation.ParameterAttribute
		$attributeParameter.Mandatory = $True
		$attributeParameter.Position = 1
		$attributeList.Add($attributeParameter)

		$parameter = New-Object System.Management.Automation.RuntimeDefinedParameter(
			$parameterName,
			[string],
			$attributeList
		)

		$parameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$parameterDictionary.Add($parameterName, $parameter)
		$parameterDictionary
	}
	end {
		$programName = $PSBoundParameters[$parameterName]
		$programExecution = ($programs.$programName).Trim("""")
		Write-Verbose "Starting ""$programExecution"""
		Invoke-Expression "& ""$programExecution"""
	}
}

Set-Alias -Name sap -Value Start-Program
