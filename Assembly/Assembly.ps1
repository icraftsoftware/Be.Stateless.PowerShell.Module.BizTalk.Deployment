#region Copyright & License

# Copyright © 2012 - 2020 François Chabot
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
    [OutputType([psobject[]])]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateScript( { Test-Path -Path $_ })]
        [psobject[]]
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
        [ValidateScript( { Test-Path -Path $_ })]
        [string]
        $Path
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    Write-Information $Path
    $name = Get-AssemblyName -Path $Path
    if (Test-GacAssembly -AssemblyName $name) {
        $gacFileVersion = Gac\Get-GacAssemblyFile -AssemblyName $name | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
        $pathFileVersion = Get-Item -Path $Path | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
        if ($pathFileVersion -gt $gacFileVersion) {
            Write-Verbose -Message "Installing a more recent version of the assembly file in GAC [$pathFileVersion > $gacFileVersion]."
            Gac\Add-GacAssembly -LiteralPath $Path -Force -Verbose:($VerbosePreference -eq 'Continue')
        } else {
            Write-Verbose -Message 'An equivalent or more recent version of the assembly file is already installed in GAC.'
        }
    } else {
        Gac\Add-GacAssembly -LiteralPath $Path -Force -Verbose:($VerbosePreference -eq 'Continue')
    }
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
        [ValidateScript( { Test-Path -Path $_ })]
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
        [ValidateScript( { Test-Path -Path $_ })]
        [string]
        $Path
    )
    if ($PSCmdlet.ParameterSetName -eq 'path') { $AssemblyName = Get-AssemblyName -Path $Path }
    [bool](Gac\Get-GacAssemblyInstallReference -AssemblyName $AssemblyName)
}


function Uninstall-GacAssembly {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ })]
        [string]
        $Path
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    Write-Information $Path
    $name = Get-AssemblyName -Path $Path
    if (Test-GacAssembly -AssemblyName $name) {
        if (Test-GacAssemblyInstallReference -AssemblyName $name) {
            Write-Verbose -Message 'The assembly is referenced by an installer and cannot be uninstalled from GAC.'
        } else {
            Gac\Remove-GacAssembly -AssemblyName $name -Verbose:($VerbosePreference -eq 'Continue')
        }
    } else {
        Write-Verbose -Message 'The assembly is already uninstalled from GAC.'
    }
}
