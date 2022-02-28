choco install postgresql14 -y --force --force-dependancies --params '/Password:Password1!' --paramsglobal
refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
$Env:PGPASSWORD='Password1!'; '\conninfo' | psql -Upostgres
