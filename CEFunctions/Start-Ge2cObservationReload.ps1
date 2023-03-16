function Start-Ge2cObservationReload {
	param([string] $Time)
	$completeTime = $Time -replace "/", ""
	$myfhrprod = "s3://pep-ge2c-z-z-z-s3-main/prod/rshiebusextract/myfhrprod"
	$unprocessed = "$myfhrprod/unprocessed"
	$completePrefix = "$myfhrprod/complete"

	$observations = "$completePrefix/$Time/observations_$completeTime.rs16"
	$archive = "$completePrefix/$Time/observations_archive_$completeTime.rs16"

	s5cmd cp $observations $unprocessed/observations.rs16 &&
	s5cmd cp $archive $unprocessed/observations_archive.rs16 &&
	s5cmd ls $unprocessed/ &&
	pipenv run ipython -c "import ge2c; prod = ge2c.Lens('myfhrprod'); prod.publish(prod.message('ingest_request'))" &&
	$Time &&
	Get-Date
}
