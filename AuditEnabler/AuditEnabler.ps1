<#
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Start
  The first month to display.

 .Parameter End
  The last month to display.

 .Parameter FirstDayOfWeek
  The day of the month on which the week begins.

 .Parameter HighlightDay
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .Parameter HighlightDate
  Specific days (named) to highlight. These dates are surrounded by asterisks.

 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "2008-12-25"
#>

function Get-AuditPoliciesStatus() {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return (auditpol /list /category /r | ConvertFrom-Csv | ForEach-Object { & auditpol /get /Category:"$($_."Category/Subcategory")" /r | ConvertFrom-Csv })
    }
    else {
        throw "Please run AuditEnabler Commands as Administrator"
    }
}

function Set-RecommendedPolicies () {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $recompolicies = Invoke-RestMethod -Uri "https://gist.githubusercontent.com/GNishanSingh/137da99154144e6a9b0cd02040344f11/raw/e6719257dcb7b06f7c617517036ff846eb86d855/PolicyRecommendation.csv" | ConvertFrom-Csv 
        Write-Progress -Activity "Recommended Security Audit Policies" -Status "Started" -PercentComplete 0
        $progress = 1
        $recompolicies | ForEach-Object {
            Write-Progress -Activity "Recommended Security Audit Policies" -Status "Enabling $($_.'Sub Category') Policy" -PercentComplete ($progress/$recompolicies.count*100)
            auditpol /set /Subcategory:"$($_.'Sub Category')" /success:$($_.Success) /failure:$($_.Failure) | Out-Null
            $progress = $progress+1
        }
        Write-Progress -Activity "Recommended Security Audit Policies" -Status "Completed" -PercentComplete 100
        return "Recommended Policies Successfully Enabled"
    }
    else {
        throw "Please run AuditEnabler commands as Administrator"
    }

}
function Get-RecommendedPolicies {
    return (Invoke-RestMethod -Uri "https://gist.githubusercontent.com/GNishanSingh/137da99154144e6a9b0cd02040344f11/raw/e6719257dcb7b06f7c617517036ff846eb86d855/PolicyRecommendation.csv" | ConvertFrom-Csv)
}

Export-ModuleMember -Function Get-RecommendedPolicies,Get-AuditPoliciesStatus,Set-RecommendedPolicies