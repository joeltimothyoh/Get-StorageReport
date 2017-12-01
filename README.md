# Get-Storage-Report
Monitors and generates an email report regarding the storage of local drives on the system.

The email will include a warning when any of the monitored local drive's free space falls below the set quota.

## Usage
Fill in email settings, and set both the drives to monitor and the free space threshold within the .ps1 script. Then manually run, or set the script to run on a schedule.

.\Get-Storage-Report.ps1

## Compatibility
This script currently only works with Windows.