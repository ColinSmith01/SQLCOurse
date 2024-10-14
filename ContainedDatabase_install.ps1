Import-Module -Name SQLSERVER -Force
Set-Location SQLServer:\SQL\localhost
Invoke-SQLCMD -Inputfile c:\classfiles\demofiles\mod01\containeddatabase_install.sql
