# Get-Storage-Report
Generates a report regarding the storage status of local logical drives on the system.

## Description
The report will include a warning when one or more local logical drives' free space falls below the set threshold.

## Usage
Get-Storage-Report can be used as a script or module. Scripts allow for greater portability and isolation, while modules allow for greater accessibility, scalability and upgradability.

The `Get-Storage-Report.ps1` script has the additional ability to email reports.

### Script
* Configure the settings within the `Get-Storage-Report.ps1` script.
* Run the script to get a report and send it via email.

### Module
* Install the `Get-Storage-Report.psm1` module. Refer to Microsoft's documentation on installing PowerShell modules.
* Call the module via `Get-Storage-Report` in PowerShell to get a report.

## Scheduling
The `Get-Storage-Report.ps1` script can be scheduled to periodically notify on the storage status of logical drives on the system.
* Set up the script to be run.
* In *Task Scheduler*, create a task with an *Action* with the following settings:
  * *Action*: `Start a program`
  * *Program/script*: `Powershell`
  * *Add arguments (optional)*: `C:\path\to\script.ps1`
* Repeat the steps for each script that is to be scheduled.

Refer to Microsoft's documentation or guides for further help on using *Task Scheduler*.

## Parameters

```
Get-Storage-Report [[-Drives] <String[]>] [[-Threshold] <Single>] [<CommonParameters>]

PARAMETERS
    -Drive <String[]>
        Logical drive(s) to get the storage status of.

    -Threshold <Single>
        The threshold for free space in percent below which a warning would be issued.

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).
```

### Examples

#### Example 1
Runs the `Get-Storage-Report.ps1` script in an instance of PowerShell.

```
Powershell "C:\scripts\Get-Storage-Report\Get-Storage-Report.ps1"
```

#### Example 2
Runs the `Get-Storage-Report` module to get the storage status of `C:` and `D:`, with a specified free space threshold of `10`%.

```
Get-Storage-Report -Drives C:, D: -Threshold 10
```

## Security
Unverified scripts are restricted from running on Windows by default. In order to use Get-Storage-Report, you will need to allow the execution of unverified scripts. To do so, open PowerShell as an *Administrator*. Then run the command:

```
Set-ExecutionPolicy Unrestricted -Force
```

If you wish to revert the policy, run the command:

```
Set-ExecutionPolicy Undefined -Force
```

## Requirements
* Windows with <a href="https://github.com/PowerShell/PowerShell#get-powershell" target="_blank" title="PowerShell">PowerShell v3</a> or higher.