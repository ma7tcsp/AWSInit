param ($sk="-t", $dk="")
#install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#download supporting files
#	create folders
mkdir "~\Downloads\postgres"
mkdir "~\Downloads\postgres\dev_resources"
mkdir "~\Downloads\postgres\prod_resources"
mkdir "~\Downloads\desktop"
mkdir "~\Downloads\server"
mkdir "~\Downloads\prep"
#	postgres files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/create_dev_postgres_db.py"  -OutFile "~\Downloads\postgres\create_dev_postgres_db.py"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/dev_resources/Create%20dev_user.sql"  -OutFile "~\Downloads\postgres\dev_resources\Create dev_user.sql"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/dev_resources/Create%20Global_Superstore%20Tables%20Dev.sql"  -OutFile "~\Downloads\postgres\dev_resources\Create Global_Superstore Tables Dev.sql"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/dev_resources/dev_inserts_utf_8.sql"  -OutFile "~\Downloads\postgres\dev_resources\dev_inserts_utf_8.sql"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/create_prod_postgres_db.py"  -OutFile "~\Downloads\postgres\create_prod_postgres_db.py"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/prod_resources/Create%20prod_user.sql"  -OutFile "~\Downloads\postgres\prod_resources\Create prod_user.sql"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/prod_resources/Create%20Global_Superstore%20Tables%20Prod.sql"  -OutFile "~\Downloads\postgres\prod_resources\Create Global_Superstore Tables Prod.sql"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/prod_resources/prod_inserts_utf_8.sql"  -OutFile "~\Downloads\postgres\prod_resources\prod_inserts_utf_8.sql"
#	tableau desktop files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/desktop/td.reg" -OutFile "~\Downloads\desktop\td.reg"
#	tableau server files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/server/reg.json" -OutFile "~\Downloads\server\reg.json"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/server/config.json" -OutFile "~\Downloads\server\config.json"

#install useful programs
choco install notepadplusplus -y
choco install 7zip -y
choco install git -y
choco install atom -y
choco install postman -y
choco install googlechrome -y
#	set chrome as default browser
function Set-ChromeAsDefaultBrowser {
    Add-Type -AssemblyName 'System.Windows.Forms'
    Start-Process $env:windir\system32\control.exe -ArgumentList '/name Microsoft.DefaultPrograms /page pageDefaultProgram\pageAdvancedSettings?pszAppName=google%20chrome'
    Sleep 2
    [System.Windows.Forms.SendKeys]::SendWait("{TAB} {ENTER} {TAB}")
}
Set-ChromeAsDefaultBrowser

#install python and libraries
choco install python -y
refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
python -m pip install --upgrade pip
pip install tableauserverclient
pip install flask
pip install cryptography
pip install psycopg2
pip install tableaudocumentapi

#install postgres and create databases
choco install postgresql14 -y --force --force-dependancies --params '/Password:Password1!' --paramsglobal
refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
$Env:PGPASSWORD='Password1!'; '\conninfo' | psql -Upostgres
cd  ~\Downloads\postgres
python .\create_dev_postgres_db.py
python .\create_prod_postgres_db.py

#install tableau desktop
cd ~\Downloads\desktop
reg import td.reg
Write-Output $dk
$ia = '"ACTIVATE_KEY="' + $dk + '" REGISTER=1"'
Write-Output $ia
choco install tableau-desktop --ia $ia --force -y
cd ~

#install tableau prep
choco install tableau-prep-builder -y

#install tableau server
choco install tableau-server -y
refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
Write-Output $sk
tsm licenses activate -k $sk
cd ~\Downloads\server
tsm register -f reg.json
tsm settings import -f conf.json
tsm pending-changes apply
tsm initialize --request-timeout 1800
tsm start --request-timeout 900
tabcmd initialuser --server http://localhost:8080 --username "tab_admin" --password "Password1!"
