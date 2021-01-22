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

# Synopsis: Deploy SQL databases and execute SQL deployment scripts
task Deploy-Configurations Apply-XmlConfigurations

# Synopsis: Undeploy SQL databases and execute SQL undeployment scripts
task Undeploy-Configurations -If { -not $SkipUndeploy } Undo-XmlConfigurations

# Synopsis: Apply XML configuration customizations
task Apply-XmlConfigurations {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Get-ConfigurationSpecification -Path $_.Path | Merge-ConfigurationSpecification -CreateBackup -CreateUndo
    }
}

# Synopsis: Remove XML configuration customizations
task Undo-XmlConfigurations -If { -not $SkipUndeploy } {
    $Resources | ForEach-Object -Process {
        Split-Path $_.Path | Get-ChildItem -Filter "$($_.Name).*.undo" -File | Resolve-Path | Select-Object -ExpandProperty ProviderPath | ForEach-Object -Process {
            Write-Build DarkGreen $_
            Get-ConfigurationSpecification -Path $_ | Merge-ConfigurationSpecification -CreateBackup
            Remove-Item -Path $_ -Force
        }
    }
}
