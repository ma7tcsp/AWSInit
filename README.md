# AWSInit

Open powershell in admin mode and run this line:

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; cd ~\Downloads; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ma7tcsp/AWSInit/main/setup_test.ps1" -OutFile "run.ps1"

This will download the script and set up powershell with appropriate permissions

then run the script - with params for tableau server and desktop lic keys 
eg:

.\run.ps1 -sk TSPJ-xxxx-xxxx-xxxx-xxxx -dk TC2K-xxxx-xxxx-xxxx-xxxx
