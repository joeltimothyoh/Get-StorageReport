<#
.SYNOPSIS
Generates a report regarding the storage status of local logical drives on the system.

.DESCRIPTION
The report will include a warning when one or more local logical drives' free space falls below the set threshold.

.PARAMETER Drive
Logical drive(s) to get the storage status of.

.PARAMETER Threshold
The threshold for free space in percent below which a warning would be issued.

.EXAMPLE
Powershell "C:\scripts\Get-Storage-Report\Get-Storage-Report.ps1"
Runs the Get-Storage-Report.ps1 script in an instance of PowerShell.

.EXAMPLE
Get-Storage-Report -Drive C:, D: -Threshold 10
Runs the Get-Storage-Report module to get the storage status of C: and D:, with a specified free space threshold of 10%.

.LINK
https://github.com/joeltimothyoh/Get-Storage-Report
#>

####################   Get-Storage-Report Settings   ####################

# Logical drive(s) to get the storage status of (If unspecified, monitors all drives)
$monitored_drives = @(
  # 'C:'
  # 'D:'
)

# Threshold for free space in percent below which a warning is issued
$freespace_threshold_percent = '10.0'

##########################   Email Settings   ###########################

# SMTP Server
$smtp_server = 'smtp.server.com'

# SMTP port (usually 465 or 587)
$smtp_port = '587'

# SMTP email address
$smtp_email = 'sender@address.com'

# SMTP email password
$smtp_password = 'Password'

# Source email address (usually matching SMTP email address)
$email_from = 'sender@address.com'

# Destination email address
$email_to = 'recipient@address.com'

# Email title prefix
$email_title_prefix = '[MachineName]'

#########################################################################

function Get-Storage-Report {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [alias("d")]
        # Throw a more meaningful error message than if ValidatePattern was used
        [ValidateScript( {
            if ($_ -match "^[A-Za-z]:$") {
                $true
            } else {
                Throw "The arguments `"$_`" does not match the `"X:`" pattern. Supply an argument that matches `"X:`" and try the command again."
            }
        } )]
        [string[]]$Drive
        ,
        [Parameter(Mandatory=$False)]
        [alias("t")]
        [ValidateRange(0,100)]
        [float]$Threshold
    )

    # Get info of local logical drives
    if ($Drive.count -gt 0) {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { ($Drive -contains $_.DeviceID) -And (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }
    } else {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }
    }

    # Count the number of logical drives low on free space
    $full_drives = $Logical_Drives_Info | Where-Object { ($_.FreeSpace/$_.Size)*100 -le $Threshold} | Measure-Object

    # Generate a table containing each monitored logical drive with their respective capacities
    $drive_capacity_table = $Logical_Drives_Info | Format-Table `
        DeviceID,                                                                                              # DeviceID for drive letter
        VolumeName,                                                                                            # VolumeName for logical volume name
        @{ Name = "Size (GB)"; Expression = { [math]::Round($_.Size/1GB,2) } },                                # Size for logical volume size
        @{ Name = "FreeSpace (GB)"; Expression = { [math]::Round($_.FreeSpace/1GB,2) } },                      # FreeSpace for logical volume free space
        @{ Name = "FreeSpace (%)"; Expression = { "{0:P1}" -f ($_.FreeSpace/$_.Size) }; Alignment="right" }    # FreeSpace (%) for logical volume free space percent

    # Trim newlines in the formatted table
    $drive_capacity_table = ($drive_capacity_table | Out-String).Trim()

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
        "Free Space Threshold: $Threshold%"
        $drive_capacity_table
    )

    # Print report to stdout
    Write-Output $title
    Write-Output $drive_capacity_report
    Write-Output "-"

    # Format title of email report
    $email_title_prefix = $email_title_prefix.Trim()
    if ($email_title_prefix -ne "") {
        $email_title = "$email_title_prefix $title"
    } else {
        $email_title = $title
    }

    # Format body of email report
    $email_body = @(
        "<html><pre style='font-family: Courier New; font-size: 11px;'>"
        $drive_capacity_report
        "</pre></html>"
    )

    # Secure credential
    $encrypted_password = $smtp_password | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential( $smtp_email, $encrypted_password )

    # Define Send-MailMessage parameters
    $emailprm = @{
        SmtpServer = $smtp_server
        Port = $smtp_port
        UseSsl = $true
        Credential = $credential
        From = $email_from
        To = $email_to
        Subject = $email_title
        Body = ($email_body | Out-String)
        BodyAsHtml = $true
    }

    # Email the report
    try {
        Send-MailMessage @emailprm -ErrorAction Stop
    } catch {
        Write-Output "Failed to send email. Reason: $($_.Exception.Message)"
    }

}

# Trim the array only if it is not empty
if ($monitored_drives.count -gt 0) {
     $monitored_drives = $monitored_drives.Trim()
}

# Call main function
Get-Storage-Report -Drive $monitored_drives -Threshold $freespace_threshold_percent