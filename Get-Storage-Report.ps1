<#
.SYNOPSIS
Generates and emails a report regarding the storage of local drives on the system.

.DESCRIPTION
The report will warn when any of the monitored local drive's free space falls below the set quota.

.EXAMPLE
.\Get-Storage-Report.ps1

#>

##########################   Email Settings   ###########################

# SMTP Server
$smtp_server = 'smtp.server.com'

# SMTP port (usually 465 or 587)
$smtp_port = '587'

# SMTP email address
$smtp_email = 'sender@address.com'

# SMTP password
$smtp_password = 'Password'

# Source email address (usually matching SMTP email address)
$email_from = 'sender@address.com'

# Destination email address
$email_to = 'recipient@address.com'

# Email title prefix
$email_title_prefix = '[MachineName]'

####################   Get-Storage-Report Settings   ####################

# Local logical drives to monitor (if unspecified, monitors all local logical drives)
$monitored_drives = @(
    # 'C:'
    # 'D:'
)

# Free space threshold before warning is issued (e.g. 0.1 for 10% free space)
$free_space_threshold = '0.2'

#########################################################################

function Get-Storage-Report {

    # Get info of local logical drives
    if ($monitored_drives.count -gt 0) {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { ($monitored_drives -contains $_.DeviceID) -And (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }

    } else {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }
    }

    # Count the number of logical drives low on free space
    $full_drives = $Logical_Drives_Info | Where-Object { ($_.FreeSpace/$_.Size) -le $free_space_threshold} | Measure-Object

    # Generate a table containing each monitored logical drive with their respective capacities
    $drive_capacity_table = $Logical_Drives_Info | 
        Format-Table DeviceID,                                                                                              # DeviceID for drive letter
                     VolumeName,                                                                                            # VolumeName for logical volume name
                     @{ Name = "Size (GB)"; Expression = { [math]::Round($_.Size/1GB,2) } },                                # Size for logical volume size
                     @{ Name = "FreeSpace (GB)"; Expression = { [math]::Round($_.FreeSpace/1GB,2) } },                      # FreeSpace for logical volume free space
                     @{ Name = "FreeSpace (%)"; Expression = { "{0:P1}" -f ($_.FreeSpace/$_.Size) }; Alignment="right" }    # FreeSpace (%) for logical volume free space percent
        
    # Module name to appear in title
    $module_name = "[Get-Storage-Report]"

    # Format title of report
    $title = "$module_name "
    if ($full_drives.Count -gt 0) {
        $title += "$($full_drives.Count) Drive(s) are getting full."
    } else {
        $title += "No problems found."
    }

    # Format body of report
    $drive_capacity_report = @(
        "Drive Capacity Check as of: $(Get-Date)"
        "Free Space Threshold: $([math]::Round([float]$free_space_threshold * 100))%"
        $drive_capacity_table
    )

    # Print report the stdout
    Write-Output $title
    Write-Output $drive_capacity_report

    # Format title of email report
    $email_title_prefix = $email_title_prefix.Trim()
    if ($email_title_prefix -ne "") {
        $email_title = "$email_title_prefix $title"
    } else {
        $email_title = $title
    }

    # Format body of email report
    $email_body = @(
        "<pre><p style='font-family: Courier New; font-size: 11px;'>"
        $drive_capacity_report
        "</p></pre>"
    )

    # Secure credentials
    $encrypted_password = $smtp_password | ConvertTo-SecureString -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential( $smtp_email, $encrypted_password )
    
    # Email the report
    Send-Mailmessage -to $email_to -subject $email_title -Body ( $email_body | Out-String ) -from $email_from -SmtpServer $smtp_server -Port $smtp_port -Credential $credentials -UseSsl -BodyAsHtml

}

# Call function
Get-Storage-Report