auditpol /list /category /r | ConvertFrom-Csv | ForEach-Object{& auditpol /get /Category:"$($_."Category/Subcategory")" /r | ConvertFrom-Csv} | Format-Table