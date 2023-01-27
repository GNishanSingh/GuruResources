# Audit Enabler
This tool help you to get the recommendation of security policies, current state of system related to security policies and enablement of security policies
## Installation
Follow the below instructions for installing Auditenabler:
1. Download Auditenabler.ps1 file in your machine
2. Run PowerShell as administrator in your machine
3. Run the following command to import the utility:
```Powershell
Unblock-file <Location of Auditenabler.ps1>
Import-module <Location of Auditenabler.ps1>
```
4. after running above command it will import the AuditEnabler command in your machine and it's ready to Use
## Usage
For getting details related to current audit setting
```Powershell
get-auditpoliciesstatus | Format-Table
```
For getting security auditing policies setting
```Powershell
Get-RecommendedPolicies
```
For setting your machine auditing setting as per recommendation
```Powershell
Set-RecommendedPolicies
```
