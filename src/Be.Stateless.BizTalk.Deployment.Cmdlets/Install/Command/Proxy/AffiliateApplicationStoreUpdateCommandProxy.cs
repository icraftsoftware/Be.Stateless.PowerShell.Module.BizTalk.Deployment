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
using Be.Stateless.BizTalk.Dsl.Environment.Settings;
using Be.Stateless.BizTalk.Dsl.Environment.Settings.Extensions;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.BizTalk.Settings.Sso;
using Be.Stateless.Extensions;
using Be.Stateless.Linq.Extensions;

namespace Be.Stateless.BizTalk.Install.Command.Proxy
{
	// TODO to be moved to Dsl.Binding repo once NoLock is working... but don't know in which assembly yet
	[SuppressMessage("ReSharper", "ClassNeverInstantiated.Global", Justification = "Instantiated by IsolatedCommandDispatcher.")]
	public class AffiliateApplicationStoreUpdateCommandProxy : CommandProxy
	{
		#region Base Class Member Overrides

		protected override void Execute(IOutputAppender outputAppender)
		{
			var environmentSettings = ResolveEnvironmentSettings(outputAppender);
			if (string.Compare(AffiliateApplicationName, environmentSettings.ApplicationName, StringComparison.OrdinalIgnoreCase) != 0)
				throw new InvalidOperationException(
					$"{nameof(AffiliateApplication)} name '{AffiliateApplicationName}' does not match {environmentSettings.GetType().Name} one '{environmentSettings.ApplicationName}'.");

			if (environmentSettings is IProvideSsoSettings ssoSettingProvider)
			{
				outputAppender.WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} is being updated...");

				var affiliateApplication = AffiliateApplication.FindByName(AffiliateApplicationName)
					?? throw new InvalidOperationException($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}' was not found.");
				outputAppender.WriteVerbose($"Loading existing {nameof(ConfigStore)}.");
				var configStore = affiliateApplication.ConfigStores.Default;
				ssoSettingProvider.SsoSettings.ForEach(
					kvp => {
						outputAppender.WriteVerbose($"Adding or updating property '{kvp.Key}' to {nameof(ConfigStore)}.");
						configStore.Properties[kvp.Key] = kvp.Value;
					});
				outputAppender.WriteVerbose($"Saving {nameof(ConfigStore)} changes.");
				configStore.Save();

				outputAppender.WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} has been updated.");
			}
			else
			{
				outputAppender.WriteInformation(
					$"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}''s {nameof(ConfigStore)} update is being skipped as {environmentSettings.GetType().Name} does not provide any SSO Settings.");
			}
		}

		[SuppressMessage("Usage", "CA2208:Instantiate argument exceptions correctly")]
		protected override void Prepare(IOutputAppender outputAppender)
		{
			if (AffiliateApplicationName.IsNullOrEmpty()) throw new ArgumentNullException(nameof(AffiliateApplicationName));
			if (EnvironmentSettingsAssemblyFilePath.IsNullOrEmpty()) throw new ArgumentNullException(nameof(EnvironmentSettingsAssemblyFilePath));
			if (TargetEnvironment.IsNullOrEmpty()) throw new ArgumentNullException(nameof(TargetEnvironment));

			DeploymentContext.TargetEnvironment = TargetEnvironment;
			if (!EnvironmentSettingOverridesTypeName.IsNullOrEmpty()) DeploymentContext.EnvironmentSettingOverridesType = ResolveEnvironmentSettingOverridesType(outputAppender);
		}

		#endregion

		public string AffiliateApplicationName { get; set; }

		public string EnvironmentSettingOverridesTypeName { get; set; }

		public string EnvironmentSettingsAssemblyFilePath { get; set; }

		public string TargetEnvironment { get; set; }

		private IEnvironmentSettings ResolveEnvironmentSettings(IOutputAppender outputAppender)
		{
			outputAppender.WriteInformation($"Resolving {nameof(IEnvironmentSettings)}-derived singleton in assembly '{EnvironmentSettingsAssemblyFilePath}'...");
			var environmentSettings = AssemblyLoader.Load(EnvironmentSettingsAssemblyFilePath).GetEnvironmentSettingsSingleton(true);
			outputAppender.WriteInformation(
				$"Resolved {nameof(IEnvironmentSettings)}-derived singleton '{environmentSettings.GetType().AssemblyQualifiedName}' in assembly '{environmentSettings.GetType().Assembly.Location}'.");
			return environmentSettings;
		}

		private Type ResolveEnvironmentSettingOverridesType(IOutputAppender outputAppender)
		{
			outputAppender.WriteInformation($"Resolving EnvironmentSettingOverridesType '{EnvironmentSettingOverridesTypeName}'...");
			var environmentSettingOverridesType = Type.GetType(EnvironmentSettingOverridesTypeName, true);
			outputAppender.WriteInformation($"Resolved EnvironmentSettingOverridesType in assembly '{environmentSettingOverridesType.Assembly.Location}'.");
			return environmentSettingOverridesType;
		}
	}
}
