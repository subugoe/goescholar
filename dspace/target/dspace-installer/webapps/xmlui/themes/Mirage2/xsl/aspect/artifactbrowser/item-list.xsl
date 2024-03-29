<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">

                <div class="item-wrapper row">
                    <div class="col-sm-3 hidden-xs">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                    <div class="col-sm-9">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>

		<!-- <div class="btn-group"> -->
		<xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file">
		<a class="btn btn-default btn-xs" role="button">
                        <xsl:attribute name="href"><xsl:value-of select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[1]/mets:FLocat/@xlink:href" /></xsl:attribute>
                        <span class="glyphicon glyphicon-download-alt"></span><i18n:text>xmlui.Mirage2.DIM-open</i18n:text>
                </a>
                </xsl:if>
		<xsl:if test="//dim:field[@element='description'][@qualifier='abstract']">
                        <a type="button" href="#abstract" class="btn btn-default btn-xs abstract"  role="button">
                            <span class="glyphicon glyphicon-align-justify"></span> <i18n:text>xmlui.Mirage2.DIM-abstract-link</i18n:text>
                        </a>
		</xsl:if>
		<!-- </div> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
	    <span class="type">
		<small>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="//dim:field[@element='type' and @qualifier='subtype'] and (//dim:field[@element='type' and @qualifier='subtype'] != //dim:field[@element='type' and not(@qualifier)])">
					<xsl:value-of select="//dim:field[@element='type' and @qualifier='subtype']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//dim:field[@element='type' and not(@qualifier)]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<i18n:text><xsl:value-of select="concat('xmlui.Mirage2.DIM-type-', $type)" /></i18n:text>
	<!-- <xsl:choose>
			<xsl:when test="$type = 'journal article'">	
                            <i18n:text>xmlui.Mirage2.DIM-journal-article</i18n:text>
			</xsl:when>
                        <xsl:when test="$type = 'anthology article'">
                              <i18n:text>xmlui.Mirage2.DIM-anthology-article</i18n:text>
                        </xsl:when>
                        <xsl:when test="$type = 'anthology'">
                               <i18n:text>xmlui.Mirage2.DIM-anthology</i18n:text>
                        </xsl:when>
                        <xsl:when test="$type = 'monograph'">
                              <i18n:text>xmlui.Mirage2.DIM-monograph</i18n:text>
                        </xsl:when>
                        <xsl:when test="$type = 'workingPaper'">
                             <i18n:text>xmlui.Mirage2.DIM-working-paper</i18n:text>
                        </xsl:when>
			<xsl:when test="$type = 'review'">
                             <i18n:text>xmlui.Mirage2.DIM-review</i18n:text>
                        </xsl:when>
		</xsl:choose> -->
		</small>
	    </span>
            <h4 class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </h4>
            <div class="artifact-info">
                <div class="author">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author'][position() &lt; 11]">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
			    <xsl:if test="count(//dim:field[@element='contributor'][@qualifier='author' and descendant::text()]) &gt; 10"> 
	                        <a data-toggle="collapse">
					<xsl:attribute name="href"><xsl:value-of select="concat('#', substring-before(//dim:field[@element='contributor'][@qualifier='author'][11], ','))" /></xsl:attribute>
				 et al.</a>

        	                <div class="collapse">
					<xsl:attribute name="id"><xsl:value-of select="substring-before(//dim:field[@element='contributor'][@qualifier='author'][11], ',')" /></xsl:attribute>
                	                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author'][position() &gt; 10]">
					<span>
                                  		<xsl:if test="@authority">
                                    		<xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  		</xsl:if>
                                  		<xsl:copy-of select="node()"/>
					</span>
					</xsl:for-each>					
				</div>
			    </xsl:if>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
		<xsl:if test="dim:field[@qualifier='subtype'] = 'review'">	
			<span class="reviewing">
				<i18n:text>xmlui.Mirage2.DIM-reviewing</i18n:text>
			</span>
			<xsl:for-each select="//dim:field[@qualifier='reviewing']">
			<span class="reviewing">
				<xsl:value-of select="." />
			</span>
			</xsl:for-each>
		</xsl:if>
	
		<!-- <xsl:if test="dim:field[@qualifier='subtype'] = 'journal article'"> -->
		<xsl:choose>
		<xsl:when test="//dim:field[@element='type' and not(@qualifier)] = 'journalArticle'">
		  <span class="biblio">
			<xsl:value-of select="//dim:field[@element='bibliographicCitation' and @qualifier='journal']" />
			<xsl:if test="//dim:field[@qualifier='volume']">
				<xsl:value-of select="concat(' ', //dim:field[@element='date' and @qualifier='issued'], '; ')" />
				<xsl:value-of select="//dim:field[@qualifier='volume']" />
			</xsl:if>
			<xsl:if test="//dim:field[@qualifier='issue']">
                                <xsl:value-of select="concat('(', //dim:field[@qualifier='issue'], ')')" />
                        </xsl:if>
			<xsl:if test="//dim:field[@qualifier='firstPage'] and //dim:field[@qualifier='lastPage']">
                                <xsl:value-of select="concat('  p.', //dim:field[@qualifier='firstPage'], '-', //dim:field[@qualifier='lastPage'])" />
                        </xsl:if>
			<xsl:if test="//dim:field[@qualifier='articlenumber']">
                                <xsl:value-of select="concat(': Art. ', //dim:field[@qualifier='articlenumber'])" />
                        </xsl:if>
		  </span>
		</xsl:when> 
		<xsl:otherwise>
                        <!-- <xsl:if test="not(dim:field[@qualifier='ispartofseries'])"> -->
                        <span class="biblio">
                            <xsl:if test="dim:field[@element='publisher']">
                                <span class="publisher">
                                    <xsl:copy-of select="dim:field[@element='publisher' and not(@qualifier)]/node()"/>
				    <xsl:if test="//dim:field[@element='publisher' and @qualifier='place']">
					    <xsl:value-of select="concat(': ', //dim:field[@element='publisher' and @qualifier='place'])" />
				    </xsl:if>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,4)"/>
                            </span>
                        </span>
                        <!-- </xsl:if> -->
                </xsl:otherwise>

	     </xsl:choose>
            </div>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <!-- <xsl:value-of select="util:shortenString($abstract, 220, 10)"/> -->
		    <xsl:value-of select="$abstract"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


   <xsl:template match="mets:fileSec" mode="artifact-files">
	<xsl:param name="href"/>
	<xsl:value-of select="$href" />
	<xsl:copy-of select="./node()" />
   </xsl:template>

    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail artifact-preview">
	    <xsl:copy-of select="mets:fileGrp[@USE='THUMBNAIL']" />
            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <img class="img-responsive" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                        select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:otherwise>
                        <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </div>
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



        <!-- Generate the info about the item from the metadata section -->
        <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
                <div class="artifact-info">
                    <span class="author">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dim:field[@element='publisher']">
                                <span class="publisher">
                                    <xsl:copy-of select="dim:field[@element='publisher' and not(@qualifier)]/node()"/>
                                    <xsl:value-of select="concat(': ', //dim:field[@element='publisher' and @qualifier='place'])" />
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template>

</xsl:stylesheet>
