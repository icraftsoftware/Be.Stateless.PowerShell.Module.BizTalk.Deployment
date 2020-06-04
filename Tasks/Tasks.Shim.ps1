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

Enter-BuildTask {
    # assign task's matching ItemGroup's Items to Items variables
    $taskObject = $Task.Name -split '-' | Select-Object -Skip 1
    Set-Variable -Name Items -Option ReadOnly -Scope Local -Value (Get-ItemGroup -Name $taskObject) -Force
}

Exit-BuildTask {
    # ignore error to prevent failure should the variable Items not be defined
    Remove-Variable -Name Items -Scope Local -Force -ErrorAction Ignore
}

function Get-ItemGroup {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [switch]
        $ThrowOnError
    )
    if ($null -ne $Name -and $ItemGroups.ContainsKey($Name)) {
        @($ItemGroups.$Name)
    } elseif ($ThrowOnError) {
        throw "ItemGroup '$Name' has not been defined."
    } else {
        @()
    }
}
