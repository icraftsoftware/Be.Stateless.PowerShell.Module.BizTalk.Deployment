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
using Be.Stateless.BizTalk.Install.Command;
using Be.Stateless.BizTalk.Install.Command.Extensions;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsDiagnostic.Test, Nouns.ApplicationBinding)]
	[OutputType(typeof(bool))]
	public class TestApplicationBinding : ApplicationBindingBasedCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteVerbose($"BizTalk Application {ResolvedApplicationBindingType.FullName} bindings are being tested...");
			try
			{
				ApplicationBindingCommandFactory
					.CreateApplicationBindingValidationCommand(ResolvedApplicationBindingType)
					.Initialize(this)
					.Execute(WriteVerbose);
				WriteObject(true);
			}
			catch (Exception exception) when (!exception.IsFatal())
			{
				WriteVerbose(exception.ToString());
				WriteObject(false);
			}
			WriteVerbose($"BizTalk Application {ResolvedApplicationBindingType.FullName} bindings have been tested.");
		}

		#endregion
	}
}
