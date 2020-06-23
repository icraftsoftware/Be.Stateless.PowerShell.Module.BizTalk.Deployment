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

# Synopsis: Deploy a business activity model and its indexes
task Deploy-BamConfiguration Deploy-BamActivityModels, Deploy-BamIndexes

# Synopsis: Undeploy a business activity model
task Undeploy-BamConfiguration -If { -not $SkipUndeploy } Undeploy-BamActivityModels

# Synopsis: Deploy a business activity model definition file
task Deploy-BamActivityModels {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen "Deploying BAM Activity Model '$($_.Name)'"
        Invoke-Tool -Command { BM update-all -DefinitionFile:"$($_.Path)" }
    }
}

# Synopsis: Create BAM indexes for a set of Activities and Properties
task Deploy-BamIndexes {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen "Creating BAM Index '$($_.Activity)'.'$($_.Name)'"
        Invoke-Tool -Command { BM create-index -Activity:"$($_.Activity)" -IndexName:"IX_$($_.Name)" -Checkpoint:"$($_.Name)" }
    }
}

# Synopsis: Undeploy a business activity model definition file
task Undeploy-BamActivityModels {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen "Undeploying BAM Activity Model '$($_.Name)'"
        Invoke-Tool -Command { BM remove-all -DefinitionFile:"$($_.Path)" }
    }
}
