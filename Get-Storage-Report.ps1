# Get-Storage-Report.ps1

function Get-Storage-Report {
    <#
    .SYNOPSIS
    This script monitors and generates an email report regarding the storage of drives on the system. 
    The email will include a warning when any number of monitored drives' free space falls below the 
    set percentage of its total capacity. 
    
    .DESCRIPTION
    Long description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>

    # Logical drives to monitor (Separated by commas. e.g. 'C:','D:'. Leave array blank to monitor all drives)
    $monitored_drives = @(
    #    'C:',
    #    'D:',
    #    'E:'
    )

    # Free space threshold before warning is issued (e.g. 0.1 for 10% free space)
    $free_space_threshold = '0.2'

    # Get info of monitored logical drives
    if ($monitored_drives.count -gt 0) {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { $monitored_drives -contains $_.DeviceID }

    } else {
        $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk
    }

    # Count the number of logical drives low on free space
    $full_drives = $Logical_Drives_Info | Where-Object { ($_.FreeSpace/$_.Size) -le $free_space_threshold} | Measure-Object

    # Generate a table containing each monitored logical drive with their respective capacities
    $drive_capacity_table = $Logical_Drives_Info | 
        Format-Table DeviceID,
                    #VolumeName,
                    @{ Name = "Size (GB)"; Expression = { [math]::Round($_.Size/1GB,2) } },
                    @{ Name = "FreeSpace (GB)"; Expression = { [math]::Round($_.FreeSpace/1GB,2) } },
                    @{ Name = "FreeSpace (%)"; Expression = { "{0:P1}" -f ($_.FreeSpace/$_.Size) }; Alignment="right"; }
        
    # Include path to email config file
    . "C:/scripts/email/config.ps1"

    # Define module name for report
    $module_name = "[Get-Storage-Report]"

    # Format title of report
    $title = "$email_title_tag $module_name "
    if ($full_drives.Count -gt 0) {
        $title += "$($full_drives.Count) Drive(s) are getting full."
    } else {
        $title += "No problems found."
    }

    # Format body of report
    $drive_capacity_report = @()
    $drive_capacity_report += "Drive Capacity Check as of: $(Get-Date)"
    $drive_capacity_report += "Free Space Threshold: $([math]::Round([float]$free_space_threshold * 100))%"
    $drive_capacity_report += $drive_capacity_table

    # Print report the stdout
    Write-Output $title
    Write-Output $drive_capacity_report

    # Format body of email
    $body = @()
    $body += "<pre><p style='font-family: Courier New; font-size: 11px;'>"
    $body += $drive_capacity_report
    $body += "</p></pre>"

    # Email the report
    Send-Mailmessage -to $email_to -subject $title -Body ( $body | Out-String ) -SmtpServer $smtp_server -from $smtp_email -Port $smtp_port -UseSsl -Credential $credential -BodyAsHtml

    # Debug
    Write-Host "Full drive count: $($full_drives.Count)"

}

# Call function
Get-Storage-Report