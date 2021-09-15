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
using Be.Stateless.BizTalk.Deployment.Cmdlet.Binding;
using Be.Stateless.BizTalk.Install.Command.Dispatcher;
using Be.Stateless.BizTalk.Install.Command.Proxy;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Application
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsDiagnostic.Test, Nouns.ApplicationState)]
	[OutputType(typeof(bool))]
	public class TestApplicationState : ApplicationBindingBasedCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteVerbose("Testing BizTalk Application's expected state...");
			try
			{
				using (var dispatcher = CommandDispatcherFactory<ApplicationStateValidationCommandProxy>.Create(this, NoLock))
				{
					dispatcher.Run();
				}
				WriteObject(true);
			}
			catch (Exception exception) when (!exception.IsFatal())
			{
				WriteVerbose(exception.ToString());
				WriteObject(false);
			}
		}

		#endregion
	}
}
