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
using Be.Stateless.BizTalk.Install.Command.Proxy;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	internal class PowerShellOutputAppender : MarshalByRefObject, IOutputAppender
	{
		internal PowerShellOutputAppender(System.Management.Automation.Cmdlet cmdlet)
		{
			_cmdlet = cmdlet ?? throw new ArgumentNullException(nameof(cmdlet));
		}

		#region IOutputAppender Members

		public void WriteInformation(string message)
		{
			_cmdlet.WriteInformation(message, null);
		}

		public void WriteVerbose(string message)
		{
			_cmdlet.WriteVerbose(message);
		}

		#endregion

		private readonly System.Management.Automation.Cmdlet _cmdlet;
	}
}
