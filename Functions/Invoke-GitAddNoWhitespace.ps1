function Invoke-GitAddNoWhitespace {
	param( [String] $Blob )
	git diff -U0 -w --no-color "$Blob" |
		git apply --cached --ignore-whitespace --unidiff-zero
}
