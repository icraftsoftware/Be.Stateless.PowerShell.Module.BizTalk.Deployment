#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

function Get-AssemblyName {
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [PSObject[]]
        $Path,

        [Parameter(Mandatory = $false)]
        [switch]
        $Name,

        [Parameter(Mandatory = $false)]
        [switch]
        $FullName
    )
    process {
        $Path | ForEach-Object -Process { $_ } | ForEach-Object -Process {
            $assemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($_)
            if ($Name) {
                $assemblyName.Name
            } elseif ($FullName) {
                $assemblyName.FullName
            } else {
                $assemblyName
            }
        }
    }
}

function Install-GacAssembly {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallReference
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $arguments = @{  }
    $name = Get-AssemblyName -Path $Path
    $pathFileVersion = Get-Item -Path $Path | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
    if (Test-GacAssembly -AssemblyName $name) {
        $gacFileVersion = Gac\Get-GacAssemblyFile -AssemblyName $name | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
        if ($pathFileVersion -ge $gacFileVersion) {
            Write-Verbose -Message "Installing same or newer version of the assembly file in GAC [$pathFileVersion >= $gacFileVersion]."
            $arguments.LiteralPath = $Path
        } else {
            Write-Verbose -Message "Installing same version of the assembly file in GAC though an older version was given [$pathFileVersion < $gacFileVersion]."
            $arguments.LiteralPath = Gac\Get-GacAssemblyFile -AssemblyName $name | Select-Object -ExpandProperty FullName
        }
    } else {
        Write-Verbose -Message "Installing new assembly file in GAC [$pathFileVersion]."
        $arguments.LiteralPath = $Path
    }
    if (-not [string]::IsNullOrEmpty($InstallReference)) { $arguments.InstallReference = New-GacAssemblyInstallReference -InstallReference $InstallReference }
    Gac\Add-GacAssembly @arguments -Force -Verbose:($VerbosePreference -eq 'Continue')
}

function New-GacAssemblyInstallReference {
    [CmdletBinding()]
    [OutputType([PowerShellGac.InstallReference])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallReference
    )
    Gac\New-GacAssemblyInstallReference -Type Opaque `
        -Identifier $InstallReference `
        -Description 'Installed by BizTalk.Deployment PowerShell Module.'
}

function Test-GacAssembly {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'name')]
        [ValidateNotNullOrEmpty()]
        [System.Reflection.AssemblyName]
        $AssemblyName,

        [Parameter(Mandatory = $true, ParameterSetName = 'path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [string]
        $Path
    )
    if ($PSCmdlet.ParameterSetName -eq 'path') { $AssemblyName = Get-AssemblyName -Path $Path }
    [bool](Gac\Get-GacAssembly -AssemblyName $AssemblyName)
}

function Test-GacAssemblyInstallReference {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'name')]
        [ValidateNotNullOrEmpty()]
        [System.Reflection.AssemblyName]
        $AssemblyName,

        [Parameter(Mandatory = $true, ParameterSetName = 'path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [string]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = 'name')]
        [Parameter(Mandatory = $false, ParameterSetName = 'path')]
        [ValidateNotNull()]
        [PowerShellGac.InstallReference]
        $InstallReference
    )
    if ($PSCmdlet.ParameterSetName -eq 'path') { $AssemblyName = Get-AssemblyName -Path $Path }
    Gac\Get-GacAssemblyInstallReference -AssemblyName $AssemblyName |
        <# let it thru any pending InstallReference if none was given to filter on, or only the one equal to the given one otherwise, see https://stackoverflow.com/a/47577074/1789441 #>
        Where-Object { ($null -eq $InstallReference) -or -not(Compare-Object -ReferenceObject $_ -DifferenceObject $InstallReference -Property $InstallReference.PSObject.Properties.Name) } |
        Test-Any
}

function Uninstall-GacAssembly {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallReference
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $arguments = @{ AssemblyName = Get-AssemblyName -Path $Path }
    if (Test-GacAssembly @arguments) {
        if ([string]::IsNullOrEmpty($InstallReference)) {
            if (Test-GacAssemblyInstallReference @arguments) {
                Write-Verbose -Message 'The assembly cannot be uninstalled from GAC because it has pending InstallReferences and none was given.'
            } else {
                Write-Verbose -Message 'Uninstalling assembly without pending InstallReferences from GAC.'
                Gac\Remove-GacAssembly @arguments -Verbose:($VerbosePreference -eq 'Continue')
            }
        } else {
            $arguments.InstallReference = New-GacAssemblyInstallReference -InstallReference $InstallReference
            if (Test-GacAssemblyInstallReference @arguments) {
                # Twisted logic and ErrorAction due to https://github.com/LTruijens/powershell-gac/issues/2
                Write-Verbose -Message "Uninstalling assembly from GAC or removing pending InstallReference '$InstallReference'."
                Gac\Remove-GacAssembly @arguments -Verbose:($VerbosePreference -eq 'Continue') -ErrorAction SilentlyContinue
                # ensure assembly has been removed from gac and if not try again without silencing any error in a last paranoiac attempt
                if (Test-GacAssemblyInstallReference @arguments) {
                    Write-Warning -Message "Failed to uninstall assembly from GAC or to remove pending InstallReference '$InstallReference'. Trying again..."
                    Gac\Remove-GacAssembly @arguments -Verbose:($VerbosePreference -eq 'Continue')
                }
            } else {
                Write-Verbose -Message 'The assembly cannot be uninstalled from GAC because the given InstallReference is not pending.'
            }
        }
    } else {
        Write-Verbose -Message 'The assembly is not installed in the GAC.'
    }
}
