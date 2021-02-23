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
using Be.Stateless.BizTalk.Dsl.Environment.Settings;
using Be.Stateless.BizTalk.Settings.Sso;
using Be.Stateless.Linq.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsData.Update, Nouns.AffiliateApplicationStore)]
	[OutputType(typeof(void))]
	public class UpdateAffiliateApplicationStore : PSCmdlet
	{
		#region Base Class Member Overrides

		[SuppressMessage("ReSharper", "SuspiciousTypeConversion.Global")]
		protected override void ProcessRecord()
		{
			if (string.Compare(AffiliateApplication.Name, EnvironmentSettings.ApplicationName, StringComparison.OrdinalIgnoreCase) != 0)
				throw new InvalidOperationException(
					$"{nameof(AffiliateApplication)} name '{AffiliateApplication.Name}' does not match {nameof(EnvironmentSettings)} one '{EnvironmentSettings.ApplicationName}'.");

			if (EnvironmentSettings is IProvideSsoSettings ssoSettingProvider)
			{
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplication.Name}''s {nameof(ConfigStore)} is being updated...", null);

				WriteVerbose($"Loading existing{nameof(ConfigStore)}.");
				var configStore = AffiliateApplication.ConfigStores.Default;
				ssoSettingProvider.SsoSettings.ForEach(
					kvp => {
						WriteVerbose($"Adding property '{kvp.Key}' to {nameof(ConfigStore)}.");
						configStore.Properties.Add(kvp.Key, kvp.Value);
					});
				WriteVerbose($"Saving {nameof(ConfigStore)} changes.");
				configStore.Save();

				WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplication.Name}''s {nameof(ConfigStore)} has been updated.", null);
			}
			else
			{
				WriteInformation(
					$"SSO {nameof(AffiliateApplication)} '{AffiliateApplication.Name}''s {nameof(ConfigStore)} update is being skipped: {nameof(EnvironmentSettings)} does not provide any SSO Settings.",
					null);
			}
		}

		#endregion

		[Alias("Application")]
		[Parameter(Mandatory = true)]
		[ValidateNotNull]
		public AffiliateApplication AffiliateApplication { get; set; }

		[Alias("Settings")]
		[Parameter(Mandatory = true)]
		[ValidateNotNull]
		public IEnvironmentSettings EnvironmentSettings { get; set; }
	}
}
