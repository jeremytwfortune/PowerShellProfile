function Format-Xml {
	param(
		[Parameter(
			ValueFromPipeline,
			ParameterSetName = "String")]
		[string[]]$InputString,

		[Parameter(
			ValueFromPipeline,
			ParameterSetName = "XML")]
		[xml]$InputXml,

		[Parameter()]
		$Indent = 2,

		[Parameter()]
		$IndentChar = " "
	)

	begin {
		$compiledString = ""
	}

	process {
		$input = $_
		switch ($PSCmdlet.ParameterSetName) {
			"String" {
				$compiledString += $input
				$xml = [xml]$compiledString
			}
			"XML" {
				$xml = $InputXml
			}
		}
	}

	end {
		$stringWriter = New-Object System.IO.StringWriter
		$xmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
		$xmlWriter.Formatting = "indented"
		$xmlWriter.Indentation = $Indent
		$xmlWriter.IndentChar = $IndentChar
		$xml.WriteContentTo($XmlWriter)
		$xmlWriter.Flush()
		$stringWriter.Flush()
		Write-Output $stringWriter.ToString()
	}
}
