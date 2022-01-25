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

namespace Be.Stateless.BizTalk.Dsl.Binding.Visitor
{
	[Flags]
	public enum BizTalkServiceInitializationOptions
	{
		None = 0,
		Orchestrations = 1 << 0,
		ReceiveLocations = 1 << 1,
		SendPorts = 1 << 2,
		All = Orchestrations | ReceiveLocations | SendPorts
	}

	public static class BizTalkServiceInitializationOptionsExtensions
	{
		public static bool RequireNoInitialization(this BizTalkServiceInitializationOptions options)
		{
			return options == BizTalkServiceInitializationOptions.None;
		}

		public static bool RequireOrchestrationInitialization(this BizTalkServiceInitializationOptions options)
		{
			return options.HasFlagFast(BizTalkServiceInitializationOptions.Orchestrations);
		}

		public static bool RequireReceiveLocationInitialization(this BizTalkServiceInitializationOptions options)
		{
			return options.HasFlagFast(BizTalkServiceInitializationOptions.ReceiveLocations);
		}

		public static bool RequireSendPortInitialization(this BizTalkServiceInitializationOptions options)
		{
			return options.HasFlagFast(BizTalkServiceInitializationOptions.SendPorts);
		}

		private static bool HasFlagFast(this BizTalkServiceInitializationOptions options, BizTalkServiceInitializationOptions flag)
		{
			return (options & flag) != 0;
		}
	}
}
