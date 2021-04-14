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

# Synopsis: Deploy Windows Services
task Deploy-WindowsServices Undeploy-WindowsServices, {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $arguments = @{
            Name           = $_.Name
            BinaryPathName = $_.Path
            Credential     = $_.Credential
            StartupType    = $_.StartupType
        }
        if (![string]::IsNullOrWhiteSpace($_.DisplayName)) { $arguments.DisplayName = $_.DisplayName }
        if (![string]::IsNullOrWhiteSpace($_.Description)) { $arguments.Description = $_.Description }
        New-Service @arguments
    }
}

# Synopsis: Undeploy Windows Services
task Undeploy-WindowsServices -If { -not $SkipUndeploy } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        # https://stackoverflow.com/questions/4967496/check-if-a-windows-service-exists-and-delete-in-powershell
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($_.Name)'"
        if ($service) {
            Stop-Service -Name $_.Name -Force
            Remove-CimInstance -InputObject $service -ErrorAction Stop
        }
    }
}
