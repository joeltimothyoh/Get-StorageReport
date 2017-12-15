# Get-Storage-Report
Generates and emails a report regarding the storage of local drives on the system.

The report will warn when any of the monitored local drive's free space falls below the set quota.

## Usage
Fill in email settings, and set both the drives to monitor and the free space threshold within the .ps1 script. Then manually run, or set the script to run on a schedule.

## Example
`.\Get-Storage-Report.ps1`

## Compatibility
Get-Storage-Report currently only works with Windows.