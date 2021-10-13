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

# Synopsis: Install Windows EventLog Sources
task Deploy-EventLogSources {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Name
        if (-not [System.Diagnostics.EventLog]::SourceExists($_.Name)) {
            New-EventLog -LogName $_.LogName -Source $_.Name
        }
    }
}

# Synopsis: Remove Windows EventLog Sources
task Undeploy-EventLogSources -If { -not $SkipUninstall } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Name
        if ([System.Diagnostics.EventLog]::SourceExists($_.Name)) {
            Remove-EventLog -Source $_.Name
        }
    }
}
