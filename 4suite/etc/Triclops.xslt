<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
  <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
  <!ENTITY f "http://xmlns.4suite.org/ext">
  <!ENTITY fres "http://xmlns.4suite.org/reserved">
  <!ENTITY dc "http://purl.org/dc/elements/1.1/">
  <!ENTITY fschema "http://schemas.4suite.org/4ss#">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fcore="http://xmlns.4suite.org/4ss/score" xmlns:frdf="http://xmlns.4suite.org/4ss/rdf" xmlns:fhttp="http://xmlns.4suite.org/4ss/http" xmlns:exslt="http://exslt.org/common" xmlns:exslt-string="http://exslt.org/strings" xmlns:exslt-set="http://exslt.org/sets" xmlns:exslt-math="http://exslt.org/math" xmlns:exslt-functions="http://exslt.org/functions" xmlns:exslt-date-time="http://exslt.org/dates-and-times" xmlns:dc="&dc;" xmlns:fres="&fres;" xmlns:rdf="&rdf;" xmlns:f="&f;" xmlns:fschema="&fschema;" xmlns:db="http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#" extension-element-prefixes="f frdf fhttp fcore exslt exslt-set exslt-math exslt-functions exslt-date-time">
  <xsl:output method="html" indent="yes" encoding="utf-8"/>
  <xsl:param name="fres:absolute-path"/>
  <xsl:param name="action"/>
  <xsl:param name="subject"/>
  <xsl:param name="versa-query"/>
  <xsl:variable name="selected-subjects" f:node-set="yes">
    <xsl:copy-of select="fhttp:get-query-args()//*[contains(name(),'subject')]/."/>
  </xsl:variable>
  <xsl:variable name="selected-objects" f:node-set="yes">
    <xsl:copy-of select="fhttp:get-query-args()//*[contains(name(),'object')]/."/>
  </xsl:variable>
  <xsl:variable name="selected-predicates" f:node-set="yes">
    <xsl:copy-of select="fhttp:get-query-args()//*[contains(name(),'predicate')]/."/>
  </xsl:variable>
  <xsl:variable name="user-mappings" f:node-set="yes">
    <frdf:versa-query query="@'{fcore:get-current-user()}'  - db:ns-mappings -> *"/>
  </xsl:variable>


  <xsl:template name="create-versa-list">
    <xsl:param name="string-list"/>
    <xsl:text>list(</xsl:text>
    <xsl:for-each select="$string-list/*">
      <xsl:if test="not(position() = 1)">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>'</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>'</xsl:text>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="fres:NsMapping" mode="mapping">
    <option value="{Prefix}">
      <xsl:value-of select="Prefix"/> -><xsl:value-of select="Uri"/>
    </option>
  </xsl:template>

  <!--User Interface templates-->
  <xsl:template match="/">
    <xsl:variable name="default-mappings" f:node-set="yes">
      <fres:NsMapping>
        <Prefix>vcard</Prefix>
        <Uri>http://4suite.org/nexus/rdfs/vcard#</Uri>
      </fres:NsMapping>
    </xsl:variable>
    <xsl:variable name="selected-subjects-expression">
      <xsl:call-template name="create-versa-list">
        <xsl:with-param name="string-list" select="$selected-subjects"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="selected-predicates-expression">
      <xsl:call-template name="create-versa-list">
        <xsl:with-param name="string-list" select="$selected-predicates"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="selected-objects-expression">
      <xsl:call-template name="create-versa-list">
        <xsl:with-param name="string-list" select="$selected-objects"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$action">
      <xsl:choose>
        <xsl:when test="$action = 'Add Mapping'">
          <fcore:x-update path="{$user-mappings/List/*}">
            <xupdate:modifications version="1.0" xmlns:xupdate="http://www.xmldb.org/xupdate">
              <xupdate:append select="/fres:NsMappings">
                <xupdate:element name="fres:NsMapping">
                  <xupdate:element name="Prefix">
                    <xsl:value-of select="fhttp:get-query-args()//newPrefix"/>
                  </xupdate:element>
                  <xupdate:element name="Uri">
                    <xsl:value-of select="fhttp:get-query-args()//newNsUri"/>
                  </xupdate:element>
                </xupdate:element>
              </xupdate:append>
            </xupdate:modifications>
          </fcore:x-update>
        </xsl:when>
        <xsl:when test="$action = 'Delete Mapping(s)' and fhttp:get-query-args()//deleted-namespaces">
          <fcore:x-update path="{$user-mappings/List/*}">
            <xupdate:modifications version="1.0" xmlns:xupdate="http://www.xmldb.org/xupdate">
              <xsl:for-each select="fhttp:get-query-args()//deleted-namespaces">
                <xsl:variable name="currentPrefix" select="."/>
                <xupdate:remove select="//fres:NsMapping[Prefix = '{$currentPrefix}']"/>
              </xsl:for-each>
            </xupdate:modifications>
          </fcore:x-update>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="ns-mappings-uri" select="fhttp:get-query-args()//ns-mappings-uri"/>
          <frdf:deserialize-and-remove path="/ftss/dashboard/user-mappings.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:db="http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#">
              <rdf:Description rdf:about="{fcore:get-current-user()}">
                <db:ns-mappings rdf:resource="{$user-mappings/List/*}"/>
              </rdf:Description>
            </rdf:RDF>
          </frdf:deserialize-and-remove>
          <frdf:deserialize-and-add path="/ftss/dashboard/user-mappings.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:db="http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#">
              <rdf:Description rdf:about="{fcore:get-current-user()}">
                <db:ns-mappings rdf:resource="{$ns-mappings-uri}"/>
              </rdf:Description>
            </rdf:RDF>
          </frdf:deserialize-and-add>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:variable name="replacedSubjects">
      <xsl:value-of select="f:replace('$subjects',string($selected-subjects-expression),string(fhttp:get-query-args()//versa-query))"/>
    </xsl:variable>
    <xsl:variable name="replacedPredicates">
      <xsl:value-of select="f:replace('$predicates',string($selected-predicates-expression),$replacedSubjects)"/>
    </xsl:variable>
    <xsl:variable name="replacedObjects">
      <xsl:value-of select="f:replace('$objects',string($selected-objects-expression),$replacedPredicates)"/>
    </xsl:variable>
    <xsl:variable name="query-result" f:node-set="yes">
      <xsl:if test="$replacedObjects">
        <xsl:choose>
          <xsl:when test="$user-mappings/List/*">
            <frdf:versa-query query="{$replacedObjects}">
              <xsl:copy-of select="document($user-mappings/List/*)"/>
            </frdf:versa-query>
          </xsl:when>
          <xsl:otherwise>
            <frdf:deserialize-and-add path="/ftss/dashboard/user-mappings.rdf">
              <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:db="http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#">
                <rdf:Description rdf:about="{fcore:get-current-user()}">
                  <db:ns-mappings rdf:resource="/ftss/dashboard/NsMappings.xml"/>
                </rdf:Description>
              </rdf:RDF>
            </frdf:deserialize-and-add>
            <frdf:versa-query query="{$replacedObjects}">
              <xsl:copy-of select="document('/ftss/dashboard/NsMappings.xml')"/>
            </frdf:versa-query>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <html>
      <head>
        <title>4Suite Repository Query</title>
        <style type="text/css">
          <xsl:comment>
.TitleBar {  font-family: "Times New Roman", Times, serif; font-style: italic; color: #000000; font-weight: bold; background-color: #CCCCCC}
</xsl:comment>
        </style>
      </head>
      <body bgcolor="#FFFFFF" text="#000000">
        <form method="post" action="/?xslt=/ftss/dashboard/Triclops.xslt">
          <table border="0" align="center">
            <xsl:call-template name="top-query-form"/>
            <xsl:call-template name="bottom-query-form"/>
            <xsl:call-template name="search-results"/>
          </table>
        </form>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="top-query-form">
    <tr>
      <td colspan="2" class="TitleBar">
        <div align="center">4Suite Repository Triclops Query</div>
      </td>
    </tr>
    <tr>
      <th>Versa Query</th>
      <td>
        <div align="left">
          <textarea cols="140" rows="1" name="versa-query">
            <xsl:value-of select="$replacedObjects" disable-output-escaping="yes"/>
          </textarea>
        </div>
      </td>
    </tr>
    <!--Namespace mapping forms-->
    <tr>
      <td colspan="2">
        <div>Triclops will replace any occurrence of '$subjects' with a versa expression that returns a list of all the selected subjects (from the triples search results below).  It will do the same for '$predicates' and '$objects'</div>
      </td>
    </tr>
    <tr>
      <td colspan="2">
        <div align="left">
          <table>
            <tr>
              <td rowspan="3">
                <select name="deleted-namespaces" multiple="on">
                  <xsl:choose>
                    <xsl:when test="$user-mappings/List/*">
                      <xsl:apply-templates select="document($user-mappings/List/*)" mode="mapping"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="document('/ftss/dashboard/NsMappings.xml')" mode="mapping"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </select>
              </td>
              <td align="right">
                <input type="submit" value="Delete Mapping(s)" name="action"/>
              </td>
              <th align="left">New Prefix</th>
              <td>
                <input name="newPrefix" type="text" size="10"/>
              </td>
            </tr>
            <tr>
              <td align="right">
                <input type="submit" name="action" value="Add Mapping"/>
              </td>
              <th align="left">New Namespace Uri</th>
              <td>
                <input name="newNsUri" size="40" type="text"/>
              </td>
            </tr>
            <tr>
              <th align="right">Namespace Mappings:</th>
              <td>
                <xsl:element name="input">
                  <xsl:if test="$user-mappings/List/*">
                    <xsl:attribute name="value"><xsl:value-of select="$user-mappings/List/*"/></xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="name">ns-mappings-uri</xsl:attribute>
                  <xsl:attribute name="type">text</xsl:attribute>
                  <xsl:attribute name="size">40</xsl:attribute>
                </xsl:element>
              </td>
              <td>
                <input type="submit" value="Change (or create) User Mappings" name="action"/>
              </td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
    <tr>
      <td colspan="2">
        <hr/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="search-results">
    <tr>
      <td class="titleBar" colspan="2">
        <div align="left"> Results</div>
      </td>
    </tr>
    <xsl:choose>
      <xsl:when test="fhttp:get-query-args()//queryType = 'Graph'">
        <!--Graph of results-->
        <tr>
          <td colspan="2">
            <xsl:call-template name="process-graph-query"/>
          </td>
        </tr>
      </xsl:when>
      <xsl:when test="fhttp:get-query-args()//queryType = 'Raw'">
        <!--Raw dump of results-->
        <tr>
          <td colspan="2">
            <xsl:call-template name="process-raw-query"/>
          </td>
        </tr>
      </xsl:when>
      <xsl:otherwise>
        <!--Triple view of results-->
        <tr>
          <td colspan="2">
            <xsl:call-template name="process-triple-query"/>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="bottom-query-form">
    <tr>
      <td class="titleBar" colspan="2">
        <div align="left">
          <input type="submit" name="Submit" value="Execute Metadata Query"/>
          <input type="reset" name="Submit2" value="Reset"/>
          <select name="queryType">
            <xsl:element name="option">
              <xsl:if test="fhttp:get-query-args()//queryType = 'Raw'">
                <xsl:attribute name="selected">on</xsl:attribute>
              </xsl:if>
              <xsl:attribute name="value">Raw</xsl:attribute>
              <xsl:text>Raw Versa Results</xsl:text>
            </xsl:element>
            <xsl:element name="option">
              <xsl:if test="fhttp:get-query-args()//queryType = 'Graph'">
                <xsl:attribute name="selected">on</xsl:attribute>
              </xsl:if>
              <xsl:attribute name="value">Graph</xsl:attribute>
              <xsl:text>RDF Graph</xsl:text>
            </xsl:element>
            <xsl:element name="option">
              <xsl:if test="fhttp:get-query-args()//queryType = 'Triple'">
                <xsl:attribute name="selected">on</xsl:attribute>
              </xsl:if>
              <xsl:attribute name="value">Triple</xsl:attribute>
              <xsl:text>Results as Triples</xsl:text>
            </xsl:element>
          </select>
        </div>
      </td>
    </tr>
    <xsl:if test="$query-result//Resource and fhttp:get-query-args()//manageable">
      <tr>
        <td class="titleBar" colspan="2">
          <div align="left">
            <a href="{$query-result//Resource}" target="dashboard">Manage</a> this resource</div>
        </td>
      </tr>
    </xsl:if>
    <!--
    <xsl:if test="$query-result//Resource and (fhttp:get-query-args()//manageable = '1' or fcore:has-resource($query-result//Resource)) ">
      <tr>
        <td class="titleBar" colspan="2">
          <div align="left">
            <a href="{$query-result//Resource}" target="dashboard">Manage</a> this resource</div>
        </td>
      </tr>
    </xsl:if>-->
  </xsl:template>

  <!--Query processing templates-->
  <xsl:template name="process-raw-query">
    <div align="center">
      <textarea cols="160" rows="15" readonly="on">
        <xsl:copy-of select="$query-result"/>
        <!--frdf:versa-query query="{$replacedObjects}"/-->
      </textarea>
    </div>
  </xsl:template>

  <xsl:template name="process-graph-query">
    <xsl:if test="$query-result">
      <img src='/ftss/dashboard/output.jpg?versa-query=@"{$query-result//Resource}"' usemap="#imageMap" border="1"/>
      <xsl:choose>
        <xsl:when test="document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/RotateGraph = 'Yes'">
          <frdf:visualize scoped="yes" graph-vis="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/gvisExec}" output-path="/ftss/dashboard/output.jpg" map-name="imageMap" uri-format="?xslt=/ftss/dashboard/Triclops.xslt&amp;versa-query=@'%s'&amp;queryType=Graph" max-arcs="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/MaxGraphArcs}" rotate="yes" namespaces="document($user-mappings/List/*)/*">
            <xsl:copy-of select="$query-result"/>
          </frdf:visualize>
        </xsl:when>
        <xsl:otherwise>
          <frdf:visualize scoped="yes" graph-vis="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/gvisExec}" output-path="/ftss/dashboard/output.jpg" map-name="imageMap" uri-format="?xslt=/ftss/dashboard/Triclops.xslt&amp;versa-query=@'%s'&amp;queryType=Graph" max-arcs="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/MaxGraphArcs}" namespaces="document($user-mappings/List/*)/*">
            <xsl:copy-of select="$query-result"/>
          </frdf:visualize>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="process-triple-query">
    <xsl:variable name="subjectConstraints" f:node-set="yes">
      <xsl:choose>
        <xsl:when test="fhttp:get-query-args()//browse-subject">
          <xsl:value-of select="fhttp:get-query-args()//browse-subject"/>
        </xsl:when>
        <xsl:when test="fhttp:get-query-args()//*[starts-with(name(),'mark')] and (fhttp:get-query-args()//subjectSource = 'Selected')">
          <xsl:copy-of select="fhttp:get-query-args()//*[starts-with(name(),'mark')]/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(fhttp:get-query-args()//subjectText)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="predicateConstraints" f:node-set="yes">
      <xsl:choose>
        <xsl:when test="fhttp:get-query-args()//browse-predicate">
          <xsl:value-of select="fhttp:get-query-args()//browse-predicate"/>
        </xsl:when>
        <xsl:when test="fhttp:get-query-args()//*[starts-with(name(),'mark')] and (fhttp:get-query-args()//predicateSource = 'Selected')">
          <xsl:copy-of select="fhttp:get-query-args()//*[starts-with(name(),'mark')]/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(fhttp:get-query-args()//predicateText)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="objectConstraints" f:node-set="yes">
      <xsl:choose>
        <xsl:when test="fhttp:get-query-args()//browse-object">
          <xsl:value-of select="fhttp:get-query-args()//browse-object"/>
        </xsl:when>
        <xsl:when test="fhttp:get-query-args()//*[starts-with(name(),'mark')] and (fhttp:get-query-args()//objectSource = 'Selected')">
          <xsl:copy-of select="fhttp:get-query-args()//*[starts-with(name(),'mark')]/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(fhttp:get-query-args()//objectText)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tabled-result" f:node-set="yes">
      <xsl:apply-templates mode="extract-tabled-data" select="$query-result"/>
    </xsl:variable>
    <table border="1">
      <xsl:apply-templates select="$tabled-result" mode="triple-grid"/>
    </table>
  </xsl:template>

  <!--templates for extracting results for triple result view-->
  <xsl:template match="Resource" mode="extract-tabled-data">
    <xsl:variable name="current-resource" select="."/>
    <xsl:variable name="resource-properties" f:node-set="yes">
      <frdf:versa-query query="properties(@'{.}')"/>
    </xsl:variable>
    <xsl:for-each select="$resource-properties//Resource">
      <xsl:variable name="current-property" select="."/>
      <xsl:variable name="resource-objects" f:node-set="yes">
        <frdf:versa-query query="@'{$current-resource}' - @'{.}' -> *"/>
      </xsl:variable>
      <xsl:for-each select="$resource-objects/List/*">
        <Statement>
          <Subject>
            <xsl:value-of select="$current-resource"/>
          </Subject>
          <Predicate>
            <xsl:value-of select="$current-property"/>
          </Predicate>
          <Object>
            <xsl:value-of select="."/>
          </Object>
        </Statement>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Boolean" mode="extract-tabled-data">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="Number" mode="extract-tabled-data">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="String" mode="extract-tabled-data">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="Statement" mode="triple-grid">
    <tr>
      <th>
        <i>Statement</i>
      </th>
      <xsl:choose>
        <xsl:when test="preceding-sibling::*[1]/Subject = Subject">
          <td/>
        </xsl:when>
        <xsl:otherwise>
          <td>
            <input type="checkbox" name="mark-subject{position()}" value="{Subject}"/>
            <a href='/?xslt=/ftss/dashboard/Triclops.xslt&amp;versa-query=@"{Subject}"&amp;queryType=Triple&amp;manageable=1'>
              <xsl:value-of select="Subject"/>
            </a>
          </td>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <input type="checkbox" name="mark-predicate{position()}" value="{Predicate}"/>
        <xsl:value-of select="Predicate"/>
      </td>
      <td>
        <input type="checkbox" name="mark-object{position()}" value="{Object}"/>
        <xsl:choose>
          <xsl:when test="string-length(./Object) > 200">
            <font size="-1">
              <xsl:value-of select="Object"/>
            </font>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="Object"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="Boolean | Number | String" mode="triple-grid">
    <tr>
      <th>
        <i>Versa Data</i>
      </th>
      <th align="left">
        <xsl:value-of select="name()"/>
      </th>
      <td colspan="2">
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>

  <!--Graphing template-->
  <xsl:template name="graph-metadata">
    <div>
      <img src="/ftss/dashboard/output.jpg?uri={$uri}" usemap="#imageMap" border="1"/>
      <xsl:choose>
        <xsl:when test="document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/RotateGraph = 'Yes'">
          <frdf:visualize graph-vis="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/gvisExec}" output-path="/ftss/dashboard/output.jpg" map-name="imageMap" uri-format="?xslt=/ftss/dashboard/Triclops.xslt&amp;uri=%s" max-arcs="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/MaxGraphArcs}" rotate="yes">
            <xsl:value-of select="$query-result"/>
          </frdf:visualize>
        </xsl:when>
        <xsl:otherwise>
          <frdf:visualize graph-vis="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/gvisExec}" output-path="/ftss/dashboard/output.jpg" map-name="imageMap" uri-format="?xslt=/ftss/dashboard/Triclops.xslt&amp;uri=%s" max-arcs="{document('/ftss/dashboard/DashboardConfig.xml')/DashboardConfig/MaxGraphArcs}">
            <xsl:value-of select="$query-result"/>
          </frdf:visualize>
        </xsl:otherwise>
      </xsl:choose>
      <br/>
      <hr/>
      <em>The graph is actually an image map.  Resources which exist in the repository are outlined in red and are links which take you to the corresponding graph of that resource</em>
    </div>
  </xsl:template>

</xsl:stylesheet>
