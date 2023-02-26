function getprocessdetails (
  $proid,
  $ppid){
    try{
   $values = (Get-WinEvent -FilterXPath @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4688] and EventData[(Data[@Name='NewProcessId'] and Data='$('0x'+('{0:X}' -f $proid).ToLower())') and (Data[@Name='ProcessId'] and Data='$('0x'+('{0:X}' -f $ppid).ToLower())')]]</Select>
  </Query>
</QueryList>
"@ -LogName Security -ErrorAction SilentlyContinue).properties.value
return [pscustomobject]@{ProcessName = $values[5];ParentProcessName=$values[13]}
    } catch{
      return [pscustomobject]@{ProcessName = $proid;ParentProcessName=$ppid}
    }
}


Get-WinEvent -FilterXPath @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4698 or EventID=4702)]]</Select>
  </Query>
</QueryList>
"@ -LogName Security | ForEach-Object {
$taskcontent = [xml]($_.properties.value[5])
$processdetails = getprocessdetails -proid $_.properties.value[7] -ppid $_.properties.value[8]
  [pscustomobject]@{
    AccountName = $_.properties.value[1]
    AccountDomain = $_.properties.value[2]
    LogonID = $_.properties.value[3]
    TaskName = $_.properties.value[4]
    TaskAction = $taskcontent.GetElementsByTagName("Command").innertext + " " + $taskcontent.GetElementsByTagName("Arguments").innertext
    TaskProcess = $processdetails.ProcessName
    TaskParentProcess = $processdetails.ParentProcessName
  }
} | Format-Table

Get-WinEvent -FilterXPath @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4657)]]</Select>
  </Query>
</QueryList>
"@ -LogName Security | select -Property * | Where-Object {($_.properties.value[4] -match '\\REGISTRY\\MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\TaskCache\\Tasks') -and ($_.properties.value[5] -eq 'Actions')}