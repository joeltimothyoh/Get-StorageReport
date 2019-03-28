function Get-StorageReport {
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
    Powershell "C:\scripts\Get-StorageReport\Get-StorageReport.ps1"
    Runs the Get-StorageReport.ps1 script in an instance of PowerShell.

    .EXAMPLE
    Get-StorageReport -Drive C:, D: -Threshold 10
    Runs the Get-StorageReport module to get the storage status of C: and D:, with a specified free space threshold of 10%.

    .LINK
    https://github.com/joeltimothyoh/Get-StorageReport
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [alias("d")]
        # Throw a more meaningful error message than if ValidatePattern was used
        [ValidateScript( {
            if ($_ -match "^[A-Za-z]:$") {
                $true
            } else {
                throw "The arguments `"$_`" does not match the `"X:`" pattern. Supply an argument that matches `"X:`" and try the command again."
            }
        } )]
        [string[]]$Drive
        ,
        [Parameter(Mandatory=$False)]
        [alias("t")]
        [ValidateRange(0,100)]
        [float]$Threshold
    )

    try {
        # Get info of local logical drives
        if ($Drive.count -gt 0) {
            $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { ($Drive -contains $_.DeviceID) -And (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }
        } else {
            $Logical_Drives_Info = Get-WmiObject -Class Win32_Logicaldisk | Where-Object { (($_.DriveType -eq 2) -Or ($_.DriveType -eq 3)) }
        }

        # Count the number of logical drives low on free space
        $full_drives = $Logical_Drives_Info | Where-Object { $_.FreeSpace -And $_.Size -And ($_.FreeSpace/$_.Size)*100 -le $Threshold } | Measure-Object

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
        $module_name = "[Get-StorageReport]"

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

    } catch {
        throw
    }

}

# Export the members of the module
Export-ModuleMember -Function Get-StorageReport
