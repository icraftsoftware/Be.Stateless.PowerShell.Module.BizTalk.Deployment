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
using System.Collections;
using System.Linq;
using Xunit.Abstractions;

namespace Be.Stateless.BizTalk.Install.Command.Binding
{
	internal class TestOutputAppender : MarshalByRefObject, IOutputAppender
	{
		public TestOutputAppender(ITestOutputHelper output)
		{
			_output = output;
		}

		#region IOutputAppender Members

		public void WriteInformation(string message)
		{
			_output.WriteLine($"{AppDomain.CurrentDomain.FriendlyName}:{message}");
		}

		public void WriteVerbose(string message)
		{
			_output.WriteLine($"{AppDomain.CurrentDomain.FriendlyName}:{message}");
		}

		public void WriteObject(object @object)
		{
			_output.WriteLine(@object.ToString());
		}

		public void WriteObject(object @object, bool enumerateCollection)
		{
			if (enumerateCollection)
			{
				foreach (var item in @object as IEnumerable ?? Enumerable.Empty<object>())
				{
					_output.WriteLine(item.ToString());
				}
			}
			else
			{
				_output.WriteLine(@object.ToString());
			}
		}

		#endregion

		private readonly ITestOutputHelper _output;
	}
}
