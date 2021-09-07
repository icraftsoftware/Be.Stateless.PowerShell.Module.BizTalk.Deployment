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
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsCommon.Get, Nouns.AffiliateApplication)]
	[OutputType(typeof(AffiliateApplication))]
	public class GetAffiliateApplication : System.Management.Automation.Cmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation($"SSO {nameof(AffiliateApplication)}s are being loaded...", null);
			var affiliateApplications = AffiliateApplicationName.IsNullOrEmpty()
				? AffiliateApplication.FindByContact()
				: AffiliateApplicationName == AffiliateApplication.ANY_CONTACT_INFO
					? AffiliateApplication.FindByContact(AffiliateApplication.ANY_CONTACT_INFO)
					: new[] { AffiliateApplication.FindByName(AffiliateApplicationName) };
			WriteObject(affiliateApplications, true);
			WriteInformation($"SSO {nameof(AffiliateApplication)}s have been loaded.", null);
		}

		#endregion

		[Alias("Name")]
		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string AffiliateApplicationName { get; set; }
	}
}
