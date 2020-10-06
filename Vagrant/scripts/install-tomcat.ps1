#Pupose: Install Tomcat and jdk, this is for iis server only

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing additional Choco packages..."

If (-not (Test-Path "C:\ProgramData\chocolatey")) {
  Write-Host "Installing Chocolatey"
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
  Write-Host "Chocolatey is already installed."
}

Write-Host "Installing Tomcat with requirements..."
choco install -y --limit-output --no-progress jdk8
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Java\").fullname
refreshenv

#Set up variables
$title = "apache-tomcat-7.0.88"
$downloadUrl = "https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.88/bin/apache-tomcat-7.0.88-windows-x64.zip"
$filehash = "0d1151e15599802fcc0e71e62d8a3bba3644d1e3"
$location = "$env:SystemDrive\$title"
$env:CATALINA_HOME = $location
$env:CATALINA_BASE = $location

#Allow SSL traffic with poor security (ish)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Download Tomcat 7.0.88
Invoke-WebRequest -Uri $downloadUrl -OutFile "$env:temp\$title.zip"
Expand-Archive "$env:temp\$title.zip" "$env:SystemDrive\" -force

#Configure default user
set-content -path "$env:SystemDrive\$title\conf\tomcat-users.xml" "<?xml version='1.0' encoding='utf-8'?>`n<tomcat-users><role rolename='manager-gui'/>`n<user username='tomcat' password='s3cret' roles='manager-gui'/>`n</tomcat-users>"

#Fix for current java version
Set-Location "$location\bin"
$serviceBatFix = Get-Content .\service.bat | Where-Object {$_ -notmatch '--JvmOptions9'}
Set-Content .\service.bat $serviceBatFix

#Install service
Start-Process -Wait -FilePath "$env:SystemDrive\$title\bin\service.bat" -ArgumentList "install" -PassThru
Set-Service Tomcat7 -StartupType Automatic
Restart-Service Tomcat7 -Force

#Allow traffic at firewall
New-NetFirewallRule -DisplayName "Apache Tomcat 7 tcp 8080" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080

#Cleanup
Remove-Item $env:temp\$title.zip

