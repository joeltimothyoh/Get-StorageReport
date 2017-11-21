# Include path to email config file
. "C:/scripts/email/config.ps1"

# Drives / Properties to filter from (DriveType=3 to monitor all Hard Drives; DeviceID='C' for C: only)
$monitored_drives = "DeviceID='C:' or DeviceID='D:' or DeviceID='E:' "

# Free Space threshold (e.g. 0.1  10% free space)
$free_space_threshold = '0.2'

# Check number of drives low on free space 
$drive_capacity_check = Get-WMIObject Win32_Logicaldisk -Filter $monitored_drives | Where-Object { ($_.FreeSpace/$_.Size) -le $free_space_threshold} | Measure-Object

# Generate a report showing the capacity of monitored drives
$drive_capacity_report = Get-WMIObject Win32_Logicaldisk -Filter $monitored_drives | 
    Format-Table DeviceID,
    #VolumeName,
    @{Name="Size (GB)";Expression = { [math]::Round($_.Size/1GB,2) } },
    @{Name="FreeSpace (GB)";Expression = { [math]::Round($_.Freespace/1GB,2) } },
    @{Label = 'FreeSpace (%)'; Expression = { "{0:P1}" -f ($_.Freespace/$_.Size) }; Alignment="right"; }
    
# Format and send email

if ($drive_capacity_check.Count -gt 0) {
    $title = "$email_title_tag $($drive_capacity_check.Count) Drive(s) are getting full."
} else {
    $title = "$email_title_tag Drive Capacity Check completed."
}
$body = @()
#$body += "<font face='Courier New' size '11'"
$body += "Drive Capacity Report as of: $(Get-Date)"
$body += "Free Space Threshold: $([math]::Round([float]$free_space_threshold * 100))%"
$body += $drive_capacity_report
#$body += "</font>"

# Debug
$drive_capacity_check.Count
#$drive_capacity_report 
$title
$body

Send-Mailmessage -to $email_to -subject $title -Body ( $body | Out-String ) -SmtpServer $smtp_server -from $smtp_email -Port $smtp_port -UseSsl -Credential $credential

# Misc
#$mail = New-Object System.Net.Mail.MailMessage $email_from, $email_to, $title, $body
#$mail.IsBodyHtml=$true
#$smtp = New-Object System.Net.Mail.SmtpClient $smtp_server, $smtp_port
#$smtp.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
#$smtp.send($mail)
