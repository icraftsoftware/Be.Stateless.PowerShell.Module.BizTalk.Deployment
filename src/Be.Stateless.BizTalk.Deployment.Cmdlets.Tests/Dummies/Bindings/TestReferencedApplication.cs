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

using Be.Stateless.BizTalk.Dsl.Binding;
using Be.Stateless.BizTalk.Dsl.Binding.Adapter;
using Be.Stateless.BizTalk.MicroPipelines;

namespace Be.Stateless.BizTalk.Dummies.Bindings
{
	internal class TestReferencedApplication : ApplicationBinding
	{
		public TestReferencedApplication()
		{
			Name = nameof(TestReferencedApplication);
			ReceivePorts.Add(new TestReferencedReceivePort());
			SendPorts.Add(new TestReferencedSendPort());
		}
	}

	internal class TestReferencedReceivePort : ReceivePort
	{
		public TestReferencedReceivePort()
		{
			Name = nameof(TestReferencedReceivePort);
			ReceiveLocations.Add(new TestReferencedReceiveLocation());
		}
	}

	internal class TestReferencedReceiveLocation : ReceiveLocation
	{
		public TestReferencedReceiveLocation()
		{
			Name = nameof(TestReferencedReceiveLocation);
			ReceivePipeline = new ReceivePipeline<XmlReceive>();
			Transport.Adapter = new FileAdapter.Inbound(a => { a.ReceiveFolder = @"c:\file"; });
			Transport.Host = "Ref_App_Rx_Host_File";
		}
	}

	internal class TestReferencedSendPort : SendPort
	{
		public TestReferencedSendPort()
		{
			Name = nameof(TestReferencedSendPort);
			SendPipeline = new SendPipeline<XmlTransmit>();
			Transport.Adapter = new FileAdapter.Outbound(a => { a.DestinationFolder = @"c:\file"; });
			Transport.Host = "Ref_App_Tx_Host_File";
		}
	}
}
