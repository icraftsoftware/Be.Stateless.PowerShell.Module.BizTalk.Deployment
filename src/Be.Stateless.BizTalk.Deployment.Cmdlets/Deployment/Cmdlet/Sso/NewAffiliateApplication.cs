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

using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using Be.Stateless.BizTalk.Settings.Sso;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsCommon.New, Nouns.AffiliateApplication)]
	[OutputType(typeof(AffiliateApplication))]
	public class NewAffiliateApplication : AffiliateApplicationCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			var affiliateApplication = AffiliateApplication.FindByName(ResolvedAffiliateApplicationName);
			if (affiliateApplication == null)
			{
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{ResolvedAffiliateApplicationName}' is being created...", null);
				affiliateApplication = AffiliateApplication.Create(ResolvedAffiliateApplicationName, AdministratorGroups, UserGroups);
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{ResolvedAffiliateApplicationName}' has been created.", null);
			}
			else
			{
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{ResolvedAffiliateApplicationName}' already exists.", null);
			}
			WriteObject(affiliateApplication);
		}

		#endregion

		[Parameter(Mandatory = false, ParameterSetName = BY_NAME_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = false, ParameterSetName = BY_SETTINGS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string[] AdministratorGroups { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = BY_NAME_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = false, ParameterSetName = BY_SETTINGS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string[] UserGroups { get; set; }
	}
}
