<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-16"/>
	
	<!--Printing options-->
	<xsl:variable name="ReportHeader">Header of report</xsl:variable>
	<xsl:variable name="PrintReportHeader">0</xsl:variable>
	<xsl:variable name="PrintReportTitle">1</xsl:variable>
	<xsl:variable name="PrintBarcode">1</xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="2"/>
	<xsl:variable name="PageBreak_After_Cells" select="8"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -2" />
	<xsl:variable name="Cell_Height" select="200 * (2 div $No_Cells)" />
	<xsl:variable name="Font_Size" select="10 * (2 div $No_Cells)"/>

	<!-- Logo -->
	<xsl:variable name="BackgroundImage_URL">http://biocase.zfmk.de/images/logo/zfmk_logo_small.png</xsl:variable>
	<xsl:variable name="Space"> </xsl:variable>


	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<html>
			<head>
				<style type="text/css">
					@import url(http://biocase.zfmk.de/images/logo/font_barcode.css);
					html,body{height:100%;width:100%}
					body{padding:0;margin:0;font-family: Frutiger, "Frutiger Linotype", Univers, Calibri, "Gill Sans", "Gill Sans MT", "Myriad Pro", Myriad, "DejaVu Sans Condensed", "Liberation Sans", "Nimbus Sans L", Tahoma, Geneva, "Helvetica Neue", Helvetica, Arial, sans-serif;font-size:<xsl:value-of select="$Font_Size"/>pt}
					p{clear:left;margin:0.1em 0;padding:0;width:100%}
					.taxon_name{border-bottom:1px solid #000;border-top:1px solid #000;font-weight:bold;padding:0.3em 0;text-align:center}
					.font_bold{font-weight:bold;}
					.font_bold_italic{font-weight:bold;font-style:italic;}
					.font_title{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39'}
					.left{float:left}
					.center{text-align:center}
					.right{float:right;clear:right;}
					.row{height:<xsl:value-of select="$Cell_Height"/>px;margin:0;width:100%;}
					.row .even{background-color:#fff;}
					.row .odd{background-color:#fff;}
					div.cell{display:block;background: url(<xsl:value-of select="$BackgroundImage_URL"/>) no-repeat top center;border:1px solid #aaa;float:left;height:<xsl:value-of select="$Cell_Height"/>px;margin:0;padding:3px 7px;width:<xsl:value-of select="$Cell_Width"/>%;overflow:hidden}
					.border_bottom{border-bottom:1px solid #000}
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
		<p style="margin-top:13px">
			<span class="left">
				<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
			</span>
			<span class="right">
				<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
			</span>
		</p>

		<p class="taxon_name">
			<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
				<xsl:if test="position()=1">
					<xsl:for-each select="./Taxon/TaxonPart">
						<xsl:call-template name="TaxonPart"/>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
		</p>

		<xsl:call-template name="Event"/>

		<p>
			<span class="left">
				<xsl:apply-templates select="Collectors"/>
				<xsl:text> </xsl:text>
			</span>
			<span class="right">
				<xsl:text> </xsl:text>
				<xsl:call-template name="CollectionDate"/>
			</span>
		</p>

		<xsl:if test="./Units/MainUnit/Identifications/Identification/ResponsibleName != ''">
			<p>
				det.
				<xsl:if test="./Units/MainUnit/Identifications/Identification/Agent/FirstNameAbbreviation != ''">
					<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/FirstName"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/SecondName"/>
			</p>
		</xsl:if>

		<xsl:for-each select="./SpecimenParts/SpecimenPart">
			<xsl:if test="position()=1">
				<xsl:if test="./PreparationMethod!= ''">
					<p class="left">
						<xsl:value-of select="concat('fix. ' , ./PreparationMethod)"/>
					</p>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="./CollectionSpecimen/DepositorsName != '' or $PrintBarcode = 1">
			<p>
				<xsl:if test="./CollectionSpecimen/DepositorsName != ''">
					<span class="left">
						<xsl:value-of select="./CollectionSpecimen/DepositorsName"/>
					</span>
				</xsl:if>
				<xsl:if test="$PrintBarcode = 1">
					<span class="right font_barcode">
						*<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>*
					</span>
				</xsl:if>
			</p>
		</xsl:if>
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
			<xsl:call-template name="CollectionMonth"/>
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

	<xsl:template name="Event">
		<p>
			<xsl:if test="./CollectionEvent/CountryCache != ''">
				<xsl:value-of select="./CollectionEvent/CountryCache"/>
			</xsl:if>
			<xsl:if test="./CollectionEvent/LocalityDescription != ''">
				<xsl:value-of select="concat(', ',./CollectionEvent/LocalityDescription)"/>
			</xsl:if>
			<xsl:for-each select="./CollectionEventLocalisations/Localisation">
				<xsl:choose>
					<xsl:when test="./ParsingMethod = 'SamplingPlot'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Gazetteer'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Altitude'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1,./MeasurementUnit)"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test="./CollectionEvent/CollectionMethod != ''">
				<xsl:value-of select="concat(', ',./CollectionEvent/CollectionMethod)"/>
			</xsl:if>
		</p>
		<xsl:for-each select="./CollectionEventLocalisations/Localisation">
			<xsl:if test="./ParsingMethod = 'Coordinates'">
				<xsl:if test="./Location2 != '' or ./Location1 != ''">
					<p>
						<xsl:if test="./Location2 != ''">
							<xsl:value-of select="./Location2"/>
						</xsl:if>
						<xsl:text>/</xsl:text>
						<xsl:if test="./Location1 != ''">
							<xsl:value-of select="./Location1"/>
						</xsl:if>
					</p>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="CollectionMonth">
		<xsl:if test="./CollectionEvent/CollectionMonth != ''">
			<xsl:if test="./CollectionEvent/CollectionMonth = 1">I</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 2">II</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 3">III</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 4">IV</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 5">V</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 6">VI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 7">VII</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 8">IIX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 9">IX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 10">X</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 11">XI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 12">XII</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
