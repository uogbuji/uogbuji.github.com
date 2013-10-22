<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
  <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
  <!ENTITY f "http://xmlns.4suite.org/ext">
  <!ENTITY fres "http://xmlns.4suite.org/reserved">
  <!ENTITY dc "http://purl.org/dc/elements/1.1/">
  <!ENTITY it "http://rdfinference.org/schemata/issue-tracker/">
  <!ENTITY ftss "http://schemas.4suite.org/4ss#">
  <!ENTITY foaf "http://xmlns.com/foaf/0.1/">
  <!ENTITY vsort "http://rdfinference.org/versa/0/2/sort/">
  <!ENTITY vtrav "http://rdfinference.org/versa/0/2/traverse/">
]>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fcore="http://xmlns.4suite.org/4ss/score"
                xmlns:frdf="http://xmlns.4suite.org/4ss/rdf" 
                xmlns:fhttp="http://xmlns.4suite.org/4ss/http" 
                xmlns:exslt="http://exslt.org/common" 
                xmlns:exslt-set="http://exslt.org/sets" 
                xmlns:exslt-math="http://exslt.org/math" 
                xmlns:exslt-functions="http://exslt.org/functions" 
                xmlns:exslt-date-time="http://exslt.org/dates-and-times" 
                xmlns:rdf="&rdf;" 
                xmlns:rdfs="&rdfs;"
                xmlns:f="&f;" 
                xmlns:fres="&fres;"
                xmlns:dc="&dc;"
                xmlns:it="&it;"
                xmlns:ftss="&ftss;"
                xmlns:foaf="&foaf;"
                xmlns:vsort="&vsort;"
                xmlns:vtrav="&vtrav;"
                xmlns:doc="http://docbook.org/docbook/xml/4.0/namespace"
                xmlns:u= "http://uche.ogbuji.net/home/xmlns/"
                extension-element-prefixes="f frdf fhttp fcore exslt exslt-set exslt-math exslt-functions exslt-date-time"
>

  <xsl:variable name="session-id">
    <fcore:create-session/>
  </xsl:variable>

  <xsl:template match='/'>
  </xsl:template>

</xsl:stylesheet>
