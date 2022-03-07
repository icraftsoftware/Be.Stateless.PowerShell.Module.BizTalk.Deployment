#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
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

# Synopsis: Deploy business activity models and their indexes
task Deploy-BamConfiguration -If ( (-not $SkipSharedResources) -and ($Manifest.Properties.Type -eq 'Application') ) -Before Enter-DatabaseDeployment `
   Undeploy-BamConfiguration, `
   Deploy-BamActivityModels, `
   Deploy-BamIndexes

# Synopsis: Deploy business activity models
task Deploy-BamActivityModels {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen "BAM Activity Model '$($_.Name)'"
      Invoke-Tool -Command { BM update-all -DefinitionFile:`"$($_.Path)`" }
   }
}

# Synopsis: Create indexes for business activity models
task Deploy-BamIndexes {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen "BAM Index '$($_.Activity)'.'$($_.Name)'"
      Invoke-Tool -Command { BM create-index -Activity:`"$($_.Activity)`" -IndexName:`"IX_$($_.Name)`" -Checkpoint:`"$($_.Name)`" }
   }
}

# Synopsis: Undeploy business activity models
task Undeploy-BamConfiguration -If ( (-not $SkipUninstall) -and (-not $SkipSharedResources) -and ($Manifest.Properties.Type -eq 'Application') ) -After Exit-DatabaseUndeployment `
   Undeploy-BamActivityModels

# Synopsis: Undeploy business activity models
task Undeploy-BamActivityModels {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen "BAM Activity Model '$($_.Name)'"
      Invoke-Tool -Command { BM remove-all -DefinitionFile:`"$($_.Path)`" }
   }
}
