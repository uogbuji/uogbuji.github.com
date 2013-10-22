<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fcore="http://xmlns.4suite.org/4ss/score"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
                xmlns:f="http://xmlns.4suite.org/ext" 
                xmlns:fres="http://xmlns.4suite.org/reserved"
                extension-element-prefixes="f fcore"
>

<!-- http://localhost:8080/uche.ogbuji.net/tech/4Suite/?xslt=config-helper.xslt -->

  <xsl:variable name="session-id">
    <xsl:if test="not(fcore:has-session())">
      <fcore:create-session/>
    </xsl:if>
  </xsl:variable>

  <xsl:param name="driver"/>
  <xsl:param name="platform"/>
  <xsl:param name="dynreload"/>
  <xsl:param name="tempreap"/>
  <xsl:param name="xsltstrobe"/>
  <xsl:param name="logfile"/>
  <xsl:param name="pidfile"/>
  <xsl:param name="dbmaint"/>

  <xsl:param name='fres:document-root'/>
  <xsl:param name='fres:uri-path'/>

<!--
  <xsl:element name="{$all-stages/stage[.=$stage]/following-sibling::*}"/>
<xsl:message>
        <xsl:value-of select="$stage"/>
</xsl:message>
-->

  <xsl:variable name="stage" select="string(fcore:session-data('STAGE'))"/>

  <xsl:variable name="update-stage" f:node-set="yes">
      <xsl:if test="$stage">
        <xsl:element name="{$stage}"/>
      </xsl:if>
  </xsl:variable>

  <xsl:variable name="render-stage" f:node-set="yes">
    <xsl:choose>
      <xsl:when test="$stage">
        <xsl:element name="{$all-stages/stage[.=$stage]/following-sibling::stage}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$all-stages/stage[1]}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="all-stages" f:node-set="yes">
    <stage>driver</stage>
    <stage>platform</stage>
    <stage>regular</stage>
    <stage>files</stage>
    <stage>finish</stage>
  </xsl:variable>

  <xsl:template match='/'>
    <HTML>
      <HEAD>
        <TITLE>4Suite configuration helper</TITLE>
      </HEAD>
      <BODY>
        <H1>4Suite configuration helper</H1>
        <!--f:dump-vars/-->
        <xsl:apply-templates select="$update-stage/*" mode="update"/>
        <xsl:apply-templates select="$render-stage/*" mode="render"/>
      </BODY>
    </HTML>
    <fcore:session-data key="STAGE">
      <xsl:value-of select="name($render-stage/*)"/>
    </fcore:session-data>
  </xsl:template>

  <xsl:template match='driver' mode="update">
    <fcore:session-data key="DRIVER">
      <xsl:value-of select="$driver"/>
    </fcore:session-data>
  </xsl:template>

  <xsl:template match='driver' mode="render">
    <DIV>
      <FORM ACTION="{$fres:uri-path}?xslt=config-helper.xslt" METHOD="POST">
        <BIG>Choose the database driver</BIG>
        <DL><DT>Flat file</DT>
          <DD>The flat file driver stores repository and RDF data as hashed files in a special directory.  Choose this option if you are running Windows, unless you can connect to a DBMS on a remote machine.  The flat file driver is very fast for small scale use, but becomes overwhelmed quickly if you put it to moderate work.</DD>
        </DL>
        <DL><DT>Simple PostgreSQL</DT>
          <DD>The Simple Postgres driver stores repository files and RDF data in relational tables in the Postgres DBMS, which now comes with most flavors of Linux, and is available on many other operating systems, though the Windows port is not recommeded.  This driver is highly recommended for UNIX-like systems.  It scales much better than the flat file driver.</DD>
        </DL>
<DIV STYLE="height: 25;">
        <INPUT TYPE="RADIO" NAME="driver" VALUE="ff" CHECKED="CHECKED">Flat file</INPUT>
</DIV>
<DIV STYLE="height: 25;">
        <INPUT TYPE="RADIO" NAME="driver" VALUE="pygres">Simple PostgreSQL</INPUT>
</DIV>
<DIV STYLE="height: 25;">
        <INPUT TYPE="SUBMIT" VALUE="next"/>
</DIV>
      </FORM>
    </DIV>
  </xsl:template>

  <xsl:template match='platform' mode="update">
    <fcore:session-data key="PLATFORM">
      <xsl:value-of select="$platform"/>
    </fcore:session-data>
  </xsl:template>

  <xsl:template match='platform' mode="render">
    <DIV>
      <FORM ACTION="{$fres:uri-path}?xslt=config-helper.xslt" METHOD="POST">
        <BIG>Choose your platform</BIG>
        <DL><DT>UNIX</DT>
          <DD>UNIX, Linux, MAC OS X, or any UNIX-like platform</DD>
        </DL>
        <DL><DT>Windows</DT>
          <DD>Windows 98 or more recent.</DD>
        </DL>
<DIV STYLE="height: 25;">
        <INPUT TYPE="RADIO" NAME="platform" VALUE="unix" CHECKED="CHECKED">UNIX</INPUT>
</DIV>
<DIV STYLE="height: 25;">
        <INPUT TYPE="RADIO" NAME="platform" VALUE="win">Windows</INPUT>
</DIV>
<DIV STYLE="height: 25;">
        <INPUT TYPE="SUBMIT" VALUE="next"/>
</DIV>
      </FORM>
    </DIV>
  </xsl:template>

  <xsl:template match='regular' mode="update">
    <fcore:session-data key="DYNRELOAD">
      <xsl:value-of select="$dynreload"/>
    </fcore:session-data>
    <fcore:session-data key="TEMPREAP">
      <xsl:value-of select="$tempreap"/>
    </fcore:session-data>
    <fcore:session-data key="XSLTSTROBE">
      <xsl:value-of select="$xsltstrobe"/>
    </fcore:session-data>
    <fcore:session-data key="DBMAINT">
      <xsl:value-of select="$dbmaint"/>
    </fcore:session-data>
  </xsl:template>

  <xsl:template match='regular' mode="render">
    <DIV>
      <FORM ACTION="{$fres:uri-path}?xslt=config-helper.xslt" METHOD="POST">
        <BIG>Set regular actions</BIG>
        <P>Here you set the intervals of several repository jobs (in seconds).  If you choose 0 seconds these jobs are disabled.  The defaults are staggered so that all the jobs don't wake up at the same time.  It is not recommended to set these to below 10 seconds.</P>
        <DL><DT>Dynamic reload</DT>
          <DD>If you change any server configuration files, you have to restart the repository, unless you set the dynamic reload interval, which checks for such server file changes and reloads as appropriate.</DD>
        </DL>
        <DL><DT>Temporary file reaping</DT>
          <DD>This causes the repository to wake up and check for stale temporary files for deletion.  You will want to set this to a non-zero value if you use temporary files in any of your applications.</DD>
        </DL>
        <DL><DT>XSLT strobe</DT>
          <DD>4Suite allows you to register XSLT files to be executed against the repository root container at a regular interval.  This is the strobe that wakes up the dispatch system for these scripts.</DD>
        </DL>
        <xsl:if test="fcore:session-data('DRIVER') = 'pygres'">
          <DL><DT>Database maintenance</DT>
            <DD>There are some DBMS tasks that help maintain performance that 4Suite can schedule for you.  This is a local time on which to perform such maintenance.</DD>
          </DL>
        </xsl:if>
        <DIV STYLE="height: 25;">Dynamic reload: <INPUT TYPE="TEXT" NAME="dynreload" VALUE="100"/></DIV>
        <DIV STYLE="height: 25;">Temporary file reaping: <INPUT TYPE="TEXT" NAME="tempreap" VALUE="110"/></DIV>
        <DIV STYLE="height: 25;">XSLT Strobe: <INPUT TYPE="TEXT" NAME="xsltstrobe" VALUE="120"/></DIV>
        <xsl:if test="fcore:session-data('DRIVER') = 'pygres'">
          <DIV STYLE="height: 25;">Database maintenance: <INPUT TYPE="TEXT" NAME="dbmaint" VALUE="03:30"/></DIV>
        </xsl:if>
<DIV STYLE="height: 25;">
        <INPUT TYPE="SUBMIT" NAME="next" VALUE="next"/>
</DIV>
      </FORM>
    </DIV>
  </xsl:template>

  <xsl:template match='files' mode="render">
    <xsl:variable name="base-path">
      <xsl:choose>
        <xsl:when test="fcore:session-data('PLATFORM') = 'unix'">/var/local/log/</xsl:when>
        <xsl:when test="fcore:session-data('PLATFORM') = 'win'">C:\TMP\</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <DIV>
      <FORM ACTION="{$fres:uri-path}?xslt=config-helper.xslt" METHOD="POST">
        <BIG>Set some needed file paths</BIG>
        <DL><DT>log file path</DT>
          <DD>The file to which to send the primary 4Suite log</DD>
        </DL>
        <DL><DT>PID file path</DT>
          <DD>The file in which the current 4Suite process is marked.</DD>
        </DL>

        <DIV STYLE="height: 25;">Log file path: <INPUT TYPE="TEXT" NAME="logfile" VALUE="{$base-path}4ss.log"/></DIV>
        <DIV STYLE="height: 25;">PID file path: <INPUT TYPE="TEXT" NAME="pidfile" VALUE="{$base-path}4ss.pid"/></DIV>

        <DIV STYLE="height: 25;">
          <INPUT TYPE="SUBMIT" NAME="next" VALUE="next"/>
        </DIV>
      </FORM>
    </DIV>
  </xsl:template>

  <xsl:template match='files' mode="update">
    <fcore:session-data key="LOG_PATH">
      <xsl:value-of select="$logfile"/>
    </fcore:session-data>
    <fcore:session-data key="PID_PATH">
      <xsl:value-of select="$pidfile"/>
    </fcore:session-data>
  </xsl:template>

  <xsl:template match='finish' mode="render">
    <xsl:variable name="result" xml:space="preserve">
      <xsl:comment>
        Copy this text to a file, and set the full path to this file in an environment variable "FTSERVER_CONFIG_FILE"
      </xsl:comment>
<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  xmlns='http://xmlns.4suite.org/4ss/properties#'
  xml:base=''
>
  <Core rdf:ID='Core'>
    <SystemContainer>ftss</SystemContainer>
<xsl:if test="string(fcore:session-data('DYNRELOAD'))">
    <DynamicReloadInterval><xsl:value-of select="fcore:session-data('DYNRELOAD')"/></DynamicReloadInterval>    
</xsl:if>
<xsl:if test="string(fcore:session-data('TEMPREAP'))">
    <TemporaryReapInterval><xsl:value-of select="fcore:session-data('TEMPREAP')"/></TemporaryReapInterval>
</xsl:if>
<xsl:if test="string(fcore:session-data('XSLTSTROBE'))">
    <XsltStrobeInterval><xsl:value-of select="fcore:session-data('XSLTSTROBE')"/></XsltStrobeInterval>
</xsl:if>
<xsl:if test="string(fcore:session-data('DBMAINT'))">
  <DbMaintenanceTime><xsl:value-of select="fcore:session-data('DBMAINT')"/></DbMaintenanceTime>
</xsl:if>

<xsl:choose>
  <xsl:when test="fcore:session-data('DRIVER') = 'ff'">
    <Driver rdf:parseType='Resource'>
      <rdf:type
resource='http://xmlns.4suite.org/4ss/properties#FlatFile'/>
      <Root>xmlserver</Root>
    </Driver>
  </xsl:when>
  <xsl:when test="fcore:session-data('DRIVER') = 'pygres'">
    <Driver rdf:parseType='Resource'>
      <rdf:type
resource='http://xmlns.4suite.org/4ss/properties#Postgres'/>
      <DbName>xmlserver</DbName>
    </Driver>
  </xsl:when>
</xsl:choose>

    <PidFile><xsl:value-of select="$pidfile"/></PidFile>
    <LogFile><xsl:value-of select="$logfile"/></LogFile>
    
    <xsl:comment>Controller log level (optional; default: notice)</xsl:comment>
    <xsl:comment>one of emerg|crit|error|warning|notice|info|debug</xsl:comment>
    <LogLevel>notice</LogLevel>
  
  </Core> 
</rdf:RDF>
    </xsl:variable>

    <!--
    <DIV>
      <BIG>Here's your configuration file</BIG>
    </DIV>
    <TEXTAREA COLS="80" ROWS="15">
<xsl:copy-of select="$result"/>
    </TEXTAREA>
-->

    <xsl:variable name="uuid" select="f:generate-uuid()"/>
    <xsl:variable name="ttl" select="30"/>
    <fcore:create-raw-file path="/uche.ogbuji.net/tmp/{$uuid}" method="xml">
      <xsl:copy-of select="$result"/>
    </fcore:create-raw-file>
    <fcore:mark-temporary path="/uche.ogbuji.net/tmp/{$uuid}" time-to-live="{$ttl}"/>
    
    <P>Follow <A HREF="/uche.ogbuji.net/tmp/{$uuid}">this link</A> to download your new config file.  It will be purged from the system in about 30 minutes.</P>
    <HR/>
    <P><A HREF="./?xslt=config-helper.xslt">Run the config helper again</A></P>
    <P><A HREF="/uche.ogbuji.net/tech/4Suite/">Uche Ogbuji's 4Suite page</A></P>
    <P><A HREF="/uche.ogbuji.net/">Uche Ogbuji's home</A></P>
    <xsl:if test='fcore:session-invalidate()'/>
  </xsl:template>

</xsl:stylesheet>
