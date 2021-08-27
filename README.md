# Get-StorageReport

Generates a report regarding the storage status of local logical drives on the system.

## Deprecation notice

This script / module outputs a system's storage information as a custom formatted report as array of strings rather than as objects for consumption further down a pipeline, making it unmodular and very much anthetical to PowerShell's general design and approach in dealing with objects rather than strings.

To get storage information, simply use PowerShell's built-in `Get-PSDrive`:

```powershell
Get-PSDrive -PSProvider FileSystem
```

Also, instead of relying on emails, consider using tools (e.g. Prometheus) for monitoring and alerting at scale.

## Description

The report will include a warning when one or more local logical drives' free space falls below the set threshold.

## Usage

Get-StorageReport can be used as a script or module. Scripts allow for greater portability and isolation, while modules allow for greater accessibility, scalability and upgradability.

The `Get-StorageReport.ps1` script has the additional ability to email reports.

### Script

* Configure the settings within the `Get-StorageReport.ps1` script.
* Run the script to get a report and send it via email.

### Module

* Install the `Get-StorageReport.psm1` module. Refer to Microsoft's documentation on installing PowerShell modules.
* Call the module via `Get-StorageReport` in PowerShell to get a report.

## Scheduling

The `Get-StorageReport.ps1` script can be scheduled to periodically notify on the storage status of logical drives on the system.

* Set up the script to be run.
* In *Task Scheduler*, create a task with the following *Action*:
  * *Action*: `Start a program`
  * *Program/script*: `Powershell`
  * *Add arguments (optional)*: `"C:\path\to\script.ps1"`
* Repeat the steps for each script that is to be scheduled.

Refer to Microsoft's documentation or guides for further help on using *Task Scheduler*.

## Parameters

```powershell
Get-StorageReport [[-Drive] <String[]>] [[-Threshold] <Single>] [<CommonParameters>]

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

Runs the `Get-StorageReport.ps1` script in an instance of PowerShell.

```powershell
Powershell "C:\scripts\Get-StorageReport\Get-StorageReport.ps1"
```

#### Example 2

Runs the `Get-StorageReport` module to get the storage status of `C:` and `D:`, with a specified free space threshold of `10`%.

```powershell
Get-StorageReport -Drive C:, D: -Threshold 10
```

## Security

Unverified scripts are restricted from running on Windows by default. In order to use `Get-StorageReport`, you will need to allow the execution of unverified scripts. To do so, open PowerShell as an *Administrator*. Then run the command:

```powershell
Set-ExecutionPolicy Unrestricted -Force
```

If you wish to revert the policy, run the command:

```powershell
Set-ExecutionPolicy Undefined -Force
```

## Requirements

* Windows with <a href="https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-5.1" target="_blank" title="PowerShell">PowerShell v3 or higher</a>.