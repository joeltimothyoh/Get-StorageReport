<#
# DriveCapacityMonitor.ps1 - 
# This script monitors and generates an email report regarding the capacity of drives on the system. 
# The email will include a warning when any number of monitored drives' free space falls below the 
# set percentage of its total capacity. 
#>

# Drives / Properties to filter from (use DriveType=3 to monitor all logical drives. DeviceID='C:' for C: only)
$monitored_drives = "DeviceID='C:' or DeviceID='D:' or DeviceID='E:' "

# Free Space threshold (e.g. 0.1 for 10% free space)
$free_space_threshold = '0.2'

# Get info of each monitored logical drive
$Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk -Filter $monitored_drives

# Count the number of logical drives low on free space
$full_drives = $Logical_Drives_Info | Where-Object { ($_.FreeSpace/$_.Size) -le $free_space_threshold} | Measure-Object

# Generate a table containing each monitored logical drive with their respective capacities
$drive_capacity_report = $Logical_Drives_Info | 
    Format-Table DeviceID,
                 #VolumeName,
                 @{ Name = "Size (GB)"; Expression = { [math]::Round($_.Size/1GB,2) } },
                 @{ Name = "FreeSpace (GB)"; Expression = { [math]::Round($_.FreeSpace/1GB,2) } },
                 @{ Name = "FreeSpace (%)"; Expression = { "{0:P1}" -f ($_.FreeSpace/$_.Size) }; Alignment="right"; }
    
# Include path to email config file
. "C:/scripts/email/config.ps1"

# Define module name for report
$module_name = "[DriveCapacityCheck]"

# Format title of report
$title = "$email_title_tag $module_name "
if ($full_drives.Count -gt 0) {
    $title += "$($full_drives.Count) Drive(s) are getting full."
} else {
    $title += "No problems found."
}

# Format body of report
$body = @()
$body += "<pre><p style='font-family: Courier New;'>"
$body += "Drive Capacity Check as of: $(Get-Date)"
$body += "Free Space Threshold: $([math]::Round([float]$free_space_threshold * 100))%"
$body += $drive_capacity_report
$body += "</p></pre>"

# Print report to console
$title + "`n"
$body

# Email the report
Send-Mailmessage -to $email_to -subject $title -Body ( $body | Out-String ) -SmtpServer $smtp_server -from $smtp_email -Port $smtp_port -UseSsl -Credential $credential -BodyAsHtml

# Debug
Write-Host "Full drive count: $($full_drives.Count)"

<# Misc
$mail = New-Object System.Net.Mail.MailMessage $email_from, $email_to, $title, $body
$mail.IsBodyHtml=$true
$smtp = New-Object System.Net.Mail.SmtpClient $smtp_server, $smtp_port
$smtp.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$smtp.send($mail)
#>