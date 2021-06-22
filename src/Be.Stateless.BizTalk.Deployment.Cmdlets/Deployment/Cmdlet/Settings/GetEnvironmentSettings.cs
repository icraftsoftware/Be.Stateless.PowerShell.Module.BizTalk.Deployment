#region Copyright & License

// Copyright © 2012 - 2021 François Chabot
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#endregion

using System;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Dsl.Environment.Settings;
using Be.Stateless.BizTalk.Dsl.Environment.Settings.Extensions;
using Be.Stateless.BizTalk.Install;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.Reflection;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Settings
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsCommon.Get, Nouns.EnvironmentSettings)]
	[OutputType(typeof(IEnvironmentSettings))]
	public class GetEnvironmentSettings : ProviderPathResolvingCmdlet
	{
		#region Base Class Member Overrides

		protected override void BeginProcessing()
		{
			DeploymentContext.EnvironmentSettingOverridesType = EnvironmentSettingOverridesType;
			DeploymentContext.TargetEnvironment = TargetEnvironment;
		}

		protected override void ProcessRecord()
		{
			WriteVerbose($"{nameof(IEnvironmentSettings)}-derived type is being loaded...");
			using (new BizTalkAssemblyResolver(msg => WriteInformation(msg, null), true, System.IO.Path.GetDirectoryName(ResolvedEnvironmentSettingsAssemblyFilePath)))
			{
				// see https://stackoverflow.com/a/1477899/1789441
				// see https://stackoverflow.com/a/41858160/1789441
				var resolvedEnvironmentSettingsType = AppDomain
					.CurrentDomain
					.Load(Assembly.LoadFile(ResolvedEnvironmentSettingsAssemblyFilePath).GetName())
					.GetEnvironmentSettingsType(true);
				WriteDebug($"Resolved EnvironmentSettingsType: '{resolvedEnvironmentSettingsType.AssemblyQualifiedName}'.");
				var environmentSettings = (IEnvironmentSettings) Reflector.GetProperty(resolvedEnvironmentSettingsType, "Settings");
				WriteObject(environmentSettings);
			}
			WriteVerbose($"{nameof(IEnvironmentSettings)}-derived type has been loaded.");
		}

		#endregion

		[Parameter(Mandatory = false)]
		[ValidateNotNull]
		public Type EnvironmentSettingOverridesType { get; set; }

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string EnvironmentSettingsAssemblyFilePath { get; set; }

		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }

		private string ResolvedEnvironmentSettingsAssemblyFilePath =>
			_resolvedEnvironmentSettingsAssemblyFilePath ??= ResolvePowerShellPath(EnvironmentSettingsAssemblyFilePath, nameof(EnvironmentSettingsAssemblyFilePath));

		private string _resolvedEnvironmentSettingsAssemblyFilePath;
	}
}
