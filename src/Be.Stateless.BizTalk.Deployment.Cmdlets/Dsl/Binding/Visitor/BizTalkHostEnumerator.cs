﻿#region Copyright & License

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

using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Be.Stateless.BizTalk.Dsl.Binding.Visitor
{
	public class BizTalkHostEnumerator : IApplicationBindingVisitor, IEnumerable<string>
	{
		#region IApplicationBindingVisitor Members

		void IApplicationBindingVisitor.VisitApplicationBinding<TNamingConvention>(IApplicationBinding<TNamingConvention> applicationBinding)
			where TNamingConvention : class { }

		void IApplicationBindingVisitor.VisitReferencedApplicationBinding(IVisitable<IApplicationBindingVisitor> referencedApplicationBinding) { }

		void IApplicationBindingVisitor.VisitOrchestration(IOrchestrationBinding orchestrationBinding)
		{
			_hosts.Add(orchestrationBinding.ResolveHost());
		}

		void IApplicationBindingVisitor.VisitReceivePort<TNamingConvention>(IReceivePort<TNamingConvention> receivePort) where TNamingConvention : class { }

		void IApplicationBindingVisitor.VisitReceiveLocation<TNamingConvention>(IReceiveLocation<TNamingConvention> receiveLocation) where TNamingConvention : class
		{
			_hosts.Add(receiveLocation.Transport.ResolveHost());
		}

		void IApplicationBindingVisitor.VisitSendPort<TNamingConvention>(ISendPort<TNamingConvention> sendPort) where TNamingConvention : class
		{
			_hosts.Add(sendPort.Transport.ResolveHost());
			if (sendPort.BackupTransport.IsValueCreated) _hosts.Add(sendPort.BackupTransport.Value.ResolveHost());
		}

		#endregion

		#region IEnumerable<string> Members

		public IEnumerator<string> GetEnumerator()
		{
			return _hosts.Distinct().GetEnumerator();
		}

		IEnumerator IEnumerable.GetEnumerator()
		{
			return GetEnumerator();
		}

		#endregion

		private readonly List<string> _hosts = new();
	}
}
