#region Copyright & License

// Copyright © 2012 - 2022 François Chabot
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
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Dsl.Environment.Settings;
using Be.Stateless.BizTalk.Dsl.Environment.Settings.Extensions;
using Be.Stateless.BizTalk.Install;
using Be.Stateless.BizTalk.Management.Automation;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.BizTalk.Settings.Sso;
using Be.Stateless.Extensions;
using Be.Stateless.Linq.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsData.Update, Nouns.AffiliateApplicationStore)]
	[OutputType(typeof(ConfigStore))]
	public class UpdateAffiliateApplicationStore : PSCmdlet
	{
		#region Base Class Member Overrides

		protected override void BeginProcessing()
		{
			WriteInformation($"Updating SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)}...", null);
		}

		protected override void ProcessRecord()
		{
			var affiliateApplication = AffiliateApplication.FindByName(AffiliateApplicationName)
				?? throw new InvalidOperationException($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}' was not found.");

			var resolvedEnvironmentSettingsAssemblyFilePath = this.ResolvePath(EnvironmentSettingsAssemblyFilePath);
			var assemblyResolutionProbingPaths = this.ResolvePaths(AssemblyProbingFolderPath)
				.Prepend(Path.GetDirectoryName(resolvedEnvironmentSettingsAssemblyFilePath))
				.Prepend(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location))
				.ToArray();

			using (new BizTalkAssemblyResolver(WriteVerbose, true, assemblyResolutionProbingPaths))
			{
				WriteInformation($"Resolving {nameof(IEnvironmentSettings)}-derived singleton in assembly '{EnvironmentSettingsAssemblyFilePath}'...", null);
				var environmentSettings = AssemblyLoader.Load(EnvironmentSettingsAssemblyFilePath).GetEnvironmentSettingsSingleton(true);
				WriteInformation(
					$"Resolved {nameof(IEnvironmentSettings)}-derived singleton '{environmentSettings.GetType().AssemblyQualifiedName}' in assembly '{environmentSettings.GetType().Assembly.Location}'.",
					null);

				if (string.Compare(AffiliateApplicationName, environmentSettings.ApplicationName, StringComparison.OrdinalIgnoreCase) != 0)
					throw new InvalidOperationException(
						$"{nameof(AffiliateApplication)} name '{AffiliateApplicationName}' does not match {environmentSettings.GetType().Name} one '{environmentSettings.ApplicationName}'.");

				if (!EnvironmentSettingOverridesTypeName.IsNullOrEmpty())
				{
					WriteInformation($"Resolving EnvironmentSettingOverridesType '{EnvironmentSettingOverridesTypeName}'...", null);
					DeploymentContext.EnvironmentSettingOverridesType = Type.GetType(EnvironmentSettingOverridesTypeName, true);
					WriteInformation($"Resolved EnvironmentSettingOverridesType in assembly '{DeploymentContext.EnvironmentSettingOverridesType.Assembly.Location}'.", null);
				}
				DeploymentContext.TargetEnvironment = TargetEnvironment;

				if (environmentSettings is IProvideSsoSettings ssoSettingProvider)
				{
					WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} is being updated...", null);
					WriteVerbose($"Loading default {nameof(ConfigStore)}.");
					var configStore = affiliateApplication.ConfigStores.Default;
					ssoSettingProvider.SsoSettings.ForEach(
						kvp => {
							WriteVerbose($"Adding or updating property '{kvp.Key}' to {nameof(ConfigStore)}.");
							configStore.Properties[kvp.Key] = kvp.Value;
						});
					WriteVerbose($"Saving {nameof(ConfigStore)} changes.");
					configStore.Save();
					WriteObject(configStore);
					WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} has been updated.", null);
				}
				else
				{
					WriteInformation(
						$"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} has not been updated because {environmentSettings.GetType().Name} does not provide any SSO Settings.",
						null);
				}
			}
		}

		#endregion

		[Alias("Name")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string AffiliateApplicationName { get; set; }

		[Alias("ProbingPath")]
		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPath { get; set; }

		[Alias("SettingsTypeName")]
		[Parameter(Mandatory = false)]
		[ValidateNotNull]
		public string EnvironmentSettingOverridesTypeName { get; set; }

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string EnvironmentSettingsAssemblyFilePath { get; set; }

		[Alias("Environment")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }
	}
}
