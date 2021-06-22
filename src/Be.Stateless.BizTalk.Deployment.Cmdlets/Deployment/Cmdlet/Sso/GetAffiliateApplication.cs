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
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsCommon.Get, Nouns.AffiliateApplication, DefaultParameterSetName = AffiliateApplicationCmdlet.BY_NAME_PARAMETER_SET_NAME)]
	[OutputType(typeof(AffiliateApplication))]
	public class GetAffiliateApplication : PSCmdlet
	{
		#region Base Class Member Overrides

		protected override void BeginProcessing()
		{
			ResolvedAffiliateApplicationName = ParameterSetName switch {
				AffiliateApplicationCmdlet.BY_NAME_PARAMETER_SET_NAME => AffiliateApplicationName,
				AffiliateApplicationCmdlet.BY_SETTINGS_PARAMETER_SET_NAME => EnvironmentSettings.ApplicationName,
				_ => throw new InvalidOperationException($"Unexpected parameter set name: {ParameterSetName}.")
			};
		}

		protected override void ProcessRecord()
		{
			WriteInformation($"SSO {nameof(AffiliateApplication)} are being loaded...", null);
			var affiliateApplications = ResolvedAffiliateApplicationName.IsNullOrEmpty()
				? AffiliateApplication.FindByContact()
				: ResolvedAffiliateApplicationName == AffiliateApplication.ANY_CONTACT_INFO
					? AffiliateApplication.FindByContact(AffiliateApplication.ANY_CONTACT_INFO)
					: new[] { AffiliateApplication.FindByName(ResolvedAffiliateApplicationName) };
			WriteObject(affiliateApplications, true);
			WriteInformation($"SSO {nameof(AffiliateApplication)} have been loaded.", null);
		}

		#endregion

		[Alias("Name")]
		[Parameter(Mandatory = false, ParameterSetName = AffiliateApplicationCmdlet.BY_NAME_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string AffiliateApplicationName { get; set; }

		[Alias("Settings")]
		[Parameter(Mandatory = false, ParameterSetName = AffiliateApplicationCmdlet.BY_SETTINGS_PARAMETER_SET_NAME)]
		[ValidateNotNull]
		public IEnvironmentSettings EnvironmentSettings { get; set; }

		private string ResolvedAffiliateApplicationName { get; set; }
	}
}
