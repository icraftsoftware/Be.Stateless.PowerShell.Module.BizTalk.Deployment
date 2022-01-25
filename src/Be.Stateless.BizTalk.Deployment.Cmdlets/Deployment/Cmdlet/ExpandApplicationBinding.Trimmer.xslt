<?xml version="1.0" encoding="utf-8"?>
<!--

  Copyright © 2012 - 2022 François Chabot
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
  http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

-->
<!-- ReSharper disable twice MarkupAttributeTypo -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                exclude-result-prefixes="msxsl xsd">
  <xsl:output method="xml" indent="yes" cdata-section-elements="passphrase Password password"/>
  <xsl:strip-space elements="*" />

  <!--
      *
      * phased processing:
      *   1. clean up bindings, e.g. discard empty stages, default values, enclosed passwords/pass phrases in CDATA, etc...
      *   2. clear empty pipelines, i.e. pipelines without any component at any stage
      *
      -->

  <xsl:template match="/">
    <xsl:variable name="trimmed">
      <xsl:apply-templates mode="trimming-one" select="/" />
    </xsl:variable>
    <xsl:apply-templates mode="trimming-two" select="msxsl:node-set($trimmed)" />
  </xsl:template>

  <!--
      *
      * 1st processing phase - clean up bindings
      *
      -->

  <xsl:template match="@*|node()" mode="trimming-one">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="trimming-one" >
        <!-- uncomment the following line should you want to sort the attributes -->
        <!-- <xsl:sort select="name(.)" /> -->
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="trimming-one" />
    </xsl:copy>
  </xsl:template>

  <!-- sort Services, SendPorts, ReceivePorts, ReceiveLocations -->
  <xsl:template match="ModuleRefCollection|Services|SendPortCollection|ReceivePortCollection|ReceiveLocations" mode="trimming-one">
    <xsl:copy>
      <xsl:apply-templates select="ModuleRef|Service|SendPort|ReceivePort|ReceiveLocation" mode="trimming-one">
        <xsl:sort select="@Name" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <!-- sort Pipeline Components' Properties but don't take the chance to reorganize them when there could be xml preprocess comments -->
  <xsl:template match="Component/Properties[not(comment())]" mode="trimming-one">
    <xsl:copy>
      <xsl:apply-templates select="*" mode="trimming-one">
        <xsl:sort select="local-name(.)" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- sort CustomProps elements but don't take the chance to reorganize them when there could be xml preprocess comments -->
  <xsl:template match="CustomProps[not(comment())]|Config[not(comment())]" mode="trimming-one">
    <xsl:copy>
      <xsl:apply-templates select="*" mode="trimming-one">
        <xsl:sort select="local-name(.)" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- discard pipeline's stages for which all of their components have their default values (i.e. no value has been set) -->
  <xsl:template match="Stage[not(.//Component/Properties/*/text() or .//Component/Properties/*/*)]" mode="trimming-one" />

  <!-- ensure absolutely no tracking at all is ever performed by DTA/TDDS -->
  <xsl:template match="Tracking" mode="trimming-one" />
  <xsl:template match="@TrackingOption" mode="trimming-one">
    <xsl:attribute name="{name(.)}">None</xsl:attribute>
  </xsl:template>

  <!-- discard unmodified (default values), unset, useless, or sometimes offending nodes and attributes -->
  <xsl:template mode="trimming-one" match="@*[name(.) != 'matchingPattern' and name(.) != 'replacementPattern' and string-length(.) = 0]">
    <xsl:message>
      <xsl:text>Trimming has removed empty attribute: </xsl:text>
      <xsl:value-of select="name(.)"/>
    </xsl:message>
  </xsl:template>
  <xsl:template mode="trimming-one" match="Authentication[text() = '0']" />
  <xsl:template mode="trimming-one" match="Description[@xsi:nil = 'true']" />
  <xsl:template mode="trimming-one" match="@Description[not(text())]" />
  <xsl:template mode="trimming-one" match="DeliveryNotification[text() = '1']" />
  <xsl:template mode="trimming-one" match="InboundTransforms[not(text())]" />
  <xsl:template mode="trimming-one" match="OrderedDelivery[text() = 'false']" />
  <xsl:template mode="trimming-one" match="Priority[text() = '5']" />
  <xsl:template mode="trimming-one" match="RouteFailedMessage" />
  <xsl:template mode="trimming-one" match="SecondaryTransport[not(Address/text())]" />
  <xsl:template mode="trimming-one" match="StopSendingOnFailure[text() = 'false']" />
  <xsl:template mode="trimming-one" match="Transforms[not(text())]" />
  <xsl:template mode="trimming-one" match="TrackedSchemas/node()|TrackedSchemas/@*" />
  <xsl:template mode="trimming-one" match="Host/@NTGroupName" />

  <!-- discard unset service window elements -->
  <xsl:template mode="trimming-one" match="ServiceWindowEnabled[text() = 'false']" />
  <xsl:template mode="trimming-one" match="FromTime[preceding-sibling::ServiceWindowEnabled/text() = 'false']" />
  <xsl:template mode="trimming-one" match="ToTime[preceding-sibling::ServiceWindowEnabled/text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationServiceWindowEnabled[text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationFromTime[preceding-sibling::ReceiveLocationServiceWindowEnabled/text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationToTime[preceding-sibling::ReceiveLocationServiceWindowEnabled/text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationStartDateEnabled[text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationStartDate[preceding-sibling::ReceiveLocationStartDateEnabled/text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationEndDateEnabled[text() = 'false']" />
  <xsl:template mode="trimming-one" match="ReceiveLocationEndDate[preceding-sibling::ReceiveLocationEndDateEnabled/text() = 'false']" />

  <!--
      *
      * 2nd processing phase - clear empty pipelines
      *
      -->

  <xsl:template match="@*|node()" mode="trimming-two">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="trimming-two" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="ReceivePipelineData[not(*/Stages/*)]" mode="trimming-two">
    <ReceivePipelineData xsi:nil="true" />
  </xsl:template>

  <xsl:template match="SendPipelineData[not(*/Stages/*)]" mode="trimming-two">
    <SendPipelineData xsi:nil="true" />
  </xsl:template>

</xsl:stylesheet>
