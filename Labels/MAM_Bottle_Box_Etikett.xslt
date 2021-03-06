<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-16"/>
	
	<!--Printing options-->
	<xsl:variable name="ReportHeader">Header of report</xsl:variable>
	<xsl:variable name="PrintReportHeader">0</xsl:variable>
	<xsl:variable name="PrintReportTitle">1</xsl:variable>
	<xsl:variable name="PrintCountryCache">0</xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="2"/>
	<xsl:variable name="PageBreak_After_Cells" select="10"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -2" />
	<xsl:variable name="Cell_Height" select="200 * (2 div $No_Cells)" />
	<xsl:variable name="Font_Size" select="10 * (2 div $No_Cells)"/>

	<!-- Logo -->
	<xsl:variable name="BackgroundImage_URL">http://biocase.zfmk.de/images/logo/zfmk_logo.jpg</xsl:variable>
	<xsl:variable name="Space"> </xsl:variable>


	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<html>
			<head>
				<style type="text/css">
					@import url(http://biocase.zfmk.de/images/logo/font_barcode.css);
					html,body{height:100%;width:100%}
					body{padding:0;margin:0;font-family: Frutiger, "Frutiger Linotype", Univers, Calibri, "Gill Sans", "Gill Sans MT", "Myriad Pro", Myriad, "DejaVu Sans Condensed", "Liberation Sans", "Nimbus Sans L", Tahoma, Geneva, "Helvetica Neue", Helvetica, Arial, sans-serif;font-size:<xsl:value-of select="$Font_Size"/>pt}
					p{clear:left;margin:0.1em 0;padding:0;}
					.font_bold{font-weight:bold;}
					.font_bold_italic{font-weight:bold;font-style:italic;}
					.font_title{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39'}
					.left{float:left}
					.right{float:right;clear:right;}
					.row{height:<xsl:value-of select="$Cell_Height"/>px;margin:0;width:100%;}
					.row .even{background-color:#fff;}
					.row .odd{background-color:#fff;}
					div.cell{background: url(<xsl:value-of select="$BackgroundImage_URL"/>) no-repeat bottom right;
						border:1px solid #aaa;float:left;height:<xsl:value-of select="$Cell_Height"/>px;margin:0;padding:3px 7px;width:<xsl:value-of select="$Cell_Width"/>%;overflow:hidden}
					.breakafter{page-break-after:always; color: white}
				</style>
			</head>
			<body>
				<!--xsl:call-template name="Header"/-->
				<xsl:if test="$PrintReportHeader = 1">
					<hr/>
					<span style="font_title">
						<xsl:value-of select="$ReportHeader"/>
					</span>
				</xsl:if>
				<xsl:for-each select="/LabelPrint/LabelList/Label">
					<xsl:call-template name="label">
						<xsl:with-param name="num">
							<xsl:value-of select="position()"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="Header">
		<p class="font_title">
			<xsl:value-of select="./ProjectTitle"/>
		</p>
		<p align="center">
			(<xsl:value-of select="./Title"/>)
		</p>
	</xsl:template>

	<xsl:template name="label">
		<xsl:param name="num"/>
		<xsl:if test="$num mod $No_Cells = 1">
			<div class="row">
				<xsl:for-each select="/LabelPrint/LabelList/Label[position() &gt;= $num and position() &lt;= ($num + $No_Cells -1)]">
					<xsl:choose>
						<xsl:when test="position() mod 2 = 1">
							<div class="cell odd">
								<xsl:call-template name="content"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="cell even">
								<xsl:call-template name="content"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:if test="$num mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="content">
			<p class="font_bold">
				<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
					<xsl:if test="position()=1">
						<xsl:for-each select="./Taxon/TaxonPart">
							<xsl:call-template name="TaxonPart"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?'">
					<xsl:text> </xsl:text>
					<xsl:value-of select="./Units/MainUnit/Gender"/>
				</xsl:if>
			</p>

			<xsl:call-template name="Event"/>

			<p>
				<span class="left">
					<xsl:call-template name="CollectionDate"/>
				</span>
				<span class="right">
					<xsl:apply-templates select="Collectors"/>
				</span>
			</p>

			<p>
				<xsl:if test="./Units/MainUnit/Identifications/Identification/ResponsibleName != ''">
					<span class="right" >
						det.
						<xsl:if test="./Units/MainUnit/Identifications/Identification/Agent/FirstNameAbbreviation != ''">
							<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/FirstName"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/SecondName"/>
					</span>
				</xsl:if>
			</p>
			<p>
				<xsl:choose>
					<xsl:when test="./Units/MainUnit/UnitAnalysis/Analysis/AnalysisName!= ''">
						<xsl:for-each select="./Units/MainUnit/UnitAnalysis/Analysis">
							<xsl:value-of select="AnalysisName"/>=<xsl:value-of select="AnalysisResult"/>
							<xsl:if test="position()!= last()">, </xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="./CollectionSpecimen/Notes != ''">
						<xsl:value-of select="./CollectionSpecimen/Notes"/>
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</p>

			<xsl:call-template name="Relations"/>

		<p class="font_bold">
			<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
			<xsl:if test="./CollectionEvent/CollectorsEventNumber!= ''">
				<span class="right">
					<xsl:value-of select="./CollectionEvent/CollectorsEventNumber"/>
				</span>
			</xsl:if>
		</p>
		<p class="font_barcode">*<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>*</p>
	</xsl:template>

	<xsl:template name="TaxonPart">
		<xsl:if test="self::node()[HybridSeparator]">
			<xsl:value-of select="concat(' ' , ./HybridSeparator, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierLeading != ''">
			<xsl:value-of select="concat(./QualifierLeading, ' ')"/>
		</xsl:if>
		<i>
			<xsl:value-of select="concat(./Genus,' ')"/>
		</i>
		<xsl:if test="./QualifierGenus != ''">
			<xsl:value-of select="concat(./QualifierGenus, ' ')"/>
		</xsl:if>
		<!--xsl:if test="./AuthorsGenus != ''">
      <xsl:value-of select="concat(./AuthorsGenus, ' ')"/>
    </xsl:if-->
		<xsl:if test="./Rank = 'gen.'">
			sp. <!--xsl:value-of select="concat('sp. ', ' ')"/-->
		</xsl:if>
		<xsl:if test="./InfragenericEpithet != ''">
			<xsl:if test="./Rank = 'subgen.'">
				<xsl:value-of select="concat(./Rank, ' ')"/>
			</xsl:if>
			<i>
				<xsl:value-of select="concat(./InfragenericEpithet, ' ')"/>
			</i>
		</xsl:if>
		<xsl:if test="./AuthorsInfrageneric != ''">
			<xsl:value-of select="concat(./AuthorsInfrageneric, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierSpecies != ''">
			<xsl:value-of select="concat(./QualifierSpecies, ' ')"/>
		</xsl:if>
		<i>
			<xsl:value-of select="concat(./SpeciesEpithet, ' ')"/>
		</i>
		<xsl:if test="./AuthorsSpecies != ''">
			<xsl:value-of select="concat(./AuthorsSpecies, ' ')"/>
		</xsl:if>
		<xsl:if test="./Rank != 'sp.' and ./Rank != 'subgen.' and ./InfraspecificEpithet != ''">
			<xsl:value-of select="concat(./Rank, ' ')"/>
		</xsl:if>
		<xsl:if test="./InfraspecificEpithet != ''">
			<xsl:if test="./QualifierInfraspecific != ''">
				<xsl:value-of select="concat(./QualifierInfraspecific, ' ')"/>
			</xsl:if>
			<i>
				<xsl:value-of select="concat(./InfraspecificEpithet, ' ')"/>
			</i>
			<xsl:if test="./AuthorsInfraspecific != ''">
				<xsl:value-of select="concat(./AuthorsInfraspecific, ' ')"/>
			</xsl:if>
		</xsl:if>
		<xsl:if test="./Undefined != ''">
			<xsl:value-of select="concat(./Undefined, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierTerminatory != ''">
			<xsl:value-of select="concat(./QualifierTerminatory, ' ')"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CollectionDate">
		<xsl:if test="./CollectionEvent/CollectionYear != '' or ./CollectionEvent/CollectionMonth != '' or ./CollectionEvent/CollectionDay != ''">
			<xsl:value-of select="./CollectionEvent/CollectionDay"/>
			<xsl:if test="./CollectionEvent/CollectionDay != ''">.</xsl:if>
			<xsl:value-of select="./CollectionEvent/CollectionMonth"/>
			<xsl:if test="./CollectionEvent/CollectionMonth != ''">.</xsl:if>
			<xsl:value-of select="./CollectionEvent/CollectionYear"/>
		</xsl:if>
		<xsl:if test="./CollectionEvent/CollectionDate != '' and not(./CollectionEvent/CollectionYear) and not(./CollectionEvent/CollectionMonth) and not(./CollectionEvent/CollectionDay)">
			<xsl:value-of select="./CollectionEvent/CollectionDate"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Collectors">
		leg. <xsl:apply-templates select="Collector"/>
	</xsl:template>

	<xsl:template match="Collector">
		<xsl:if test="./Agent/FirstNameAbbreviation != ''">
			<xsl:value-of select="./Agent/FirstName"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="./Agent/SecondName"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="CollectorsNumber"/>
		<xsl:if test="position()!= last()">, </xsl:if>
	</xsl:template>
	<xsl:template match="CollectorsNumber">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template name="NamedPlace">
		<xsl:for-each select="./CollectionEventLocalisations/Localisation">
			<xsl:if test="./ParsingMethod = 'Gazetteer'">
				<xsl:if test="./Location1 != ''">
					<xsl:value-of select="./Location1"/>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="EventHabitat">
		<xsl:if test="./CollectionEvent/HabitatDescription != ''">
			<xsl:text> </xsl:text>
			<xsl:value-of select="./CollectionEvent/HabitatDescription"/>.
		</xsl:if>
	</xsl:template>

	<xsl:template name="Event">
		<p>
			<xsl:call-template name="NamedPlace"/>
		</p>
		<p>
			<xsl:if test="$PrintCountryCache = 1">
				<xsl:if test="./CollectionEvent/CountryCache != ''">
					<xsl:value-of select="./CollectionEvent/CountryCache"/>
					.
				</xsl:if>
			</xsl:if>
			<xsl:value-of select="./CollectionEvent/LocalityDescription"/>
			<xsl:if test="./CollectionEvent/HabitatDescription != ''">
				<xsl:text> </xsl:text>
				<xsl:value-of select="./CollectionEvent/HabitatDescription"/>
			</xsl:if>
		</p>
		<p>
			<xsl:call-template name="EventHabitat"/>
		</p>
		<p>
			<xsl:call-template name="GeoCoordinates"/>
		</p>
	</xsl:template>

	<xsl:template name="GeoCoordinates">
		<xsl:for-each select="./CollectionEventLocalisations/Localisation">
			<xsl:if test="./ParsingMethod = 'Coordinates'">
				<xsl:if test="./Location2 != ''">
					Lat 
					<xsl:choose>
						<xsl:when test ="./Location2 &lt; 0">
							(S) 
						</xsl:when>
						<xsl:otherwise>(N) </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="./Location2"/>
				</xsl:if>
				<xsl:text>/</xsl:text>
				<xsl:if test="./Location1 != ''">Long 
					<xsl:choose>
						<xsl:when test ="./Location1 &lt; 0">
							(W) 
						</xsl:when>
						<xsl:otherwise>(E) </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="./Location1"/>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Relations">
		<p>
			<xsl:if test="./Relations/Relation/RelatedSpecimenDisplayText!= ''">
				<xsl:for-each select="./Relations/Relation">
					<xsl:value-of select="RelatedSpecimenDisplayText"/>
					<xsl:if test="RelationType!= ''">
						(<xsl:value-of select="RelationType"/>)
					</xsl:if>
					<xsl:if test="position()!= last()">, </xsl:if>
				</xsl:for-each>
			</xsl:if>
		</p>
	</xsl:template>

	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
