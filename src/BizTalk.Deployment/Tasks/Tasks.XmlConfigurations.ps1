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

# Synopsis: Apply XML configuration customizations
task Deploy-XmlConfigurations `
    Apply-XmlConfigurations, `
    Invoke-XmlConfigurationActions

# Synopsis: Revert XML configuration customizations
task Undeploy-XmlConfigurations `
    Revert-XmlConfigurations, `
    Invoke-XmlUnconfigurationActions

# Synopsis: Apply XML configuration specifications
task Apply-XmlConfigurations {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Merge-ConfigurationSpecification -Path $_.Path -CreateBackup -CreateUndo -ConfigurationFileResolvers $([Be.Stateless.BizTalk.Dsl.Configuration.Resolvers.BizTalkConfigurationFileResolverStrategy]::new())
    }
}

# Synopsis: Apply XML configuration actions
task Invoke-XmlConfigurationActions {
    $Resources | ForEach-Object -Process { $_ } -PipelineVariable xca | ForEach-Object -Process {
        Write-Build DarkGreen $xca.Path
        switch ($xca.Action) {
            'Append' { Add-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath -Name $xca.Name -Attributes $xca.Attributes }
            'Update' { Set-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath -Attributes $xca.Attributes }
            'Delete' { Remove-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath }
            default { throw "Unknown XML configuration action $($xca.Action)." }
        }
    }
}

# Synopsis: Remove XML configuration specifications
task Revert-XmlConfigurations -If { -not $SkipUninstall } {
    $Resources | ForEach-Object -Process {
        Get-ChildItem -Path "$($_.Path).*.undo" -File | Sort-Object -Descending | ForEach-Object -Process {
            Write-Build DarkGreen $_
            Merge-ConfigurationSpecification -Path $_ -ConfigurationFileResolvers $([Be.Stateless.BizTalk.Dsl.Configuration.Resolvers.BizTalkConfigurationFileResolverStrategy]::new())
            Remove-Item -Path $_ -Force
        }
    }
}

# Synopsis: Apply XML unconfiguration actions
task Invoke-XmlUnconfigurationActions {
    $Resources | ForEach-Object -Process { $_ } -PipelineVariable xca | ForEach-Object -Process {
        Write-Build DarkGreen $xca.Path
        switch ($xca.Action) {
            'Append' { Add-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath -Name $xca.Name -Attributes $xca.Attributes }
            'Update' { Set-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath -Attributes $xca.Attributes }
            'Delete' { Remove-ConfigurationElement -ConfigurationFile $xca.Path -XPath $xca.XPath }
            default { throw "Unknown XML configuration action $($xca.Action)." }
        }
    }
}

