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
using System.Reflection;
using System.Xml;
using Be.Stateless.Resources;
using FluentAssertions;
using Moq;
using Xunit;
using static FluentAssertions.FluentActions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	public class ExpandApplicationBindingFixture
	{
		[Fact]
		public void UnescapeXmlTree()
		{
			var document = new XmlDocument();
			document.Load(ResourceManager.Load(Assembly.GetExecutingAssembly(), "Be.Stateless.BizTalk.Resources.Bindings.SBMessaging.xml"));

			var sutMock = new Mock<ExpandApplicationBinding> { CallBase = true };
			sutMock.Setup(m => m.WriteWarning(It.IsAny<string>()));

			Invoking(() => sutMock.Object.UnescapeXmlTree(document.DocumentElement)).Should().NotThrow();

			sutMock.Verify(m => m.WriteWarning(It.IsAny<string>()), Times.Never);
		}

		[Fact]
		[SuppressMessage("ReSharper", "StringLiteralTypo")]
		public void UnescapeXmlTreeWithAngularBracketsInText()
		{
			const string xml = @"<TransportTypeData>&lt;StsUri vt=""8""&gt;https://&amp;lt;Namespace&amp;gt;-sb.accesscontrol.windows.net/&lt;/StsUri&gt;</TransportTypeData>";

			var document = new XmlDocument();
			document.LoadXml(xml);

			var sutMock = new Mock<ExpandApplicationBinding> { CallBase = true };
			sutMock.Setup(m => m.WriteWarning(It.IsAny<string>()));

			sutMock.Object.UnescapeXmlTree(document.DocumentElement);

			document.DocumentElement!.OuterXml
				.Should().Be("<TransportTypeData><StsUri vt=\"8\">https://&lt;Namespace&gt;-sb.accesscontrol.windows.net/</StsUri></TransportTypeData>");
			document.DocumentElement!.FirstChild.InnerText
				.Should().Be("https://<Namespace>-sb.accesscontrol.windows.net/");

			sutMock.Verify(m => m.WriteWarning(It.IsAny<string>()), Times.Never);
		}
	}
}
