<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
<xsl:output version='1.0' encoding='UTF-8'/>
<xsl:param name="schema-urzedow" select="'KodyUrzedowSkarbowych_v3-0E.xsd'"/>
	
<xsl:template match="/">

<html lang="pl">
<head>
	<title>Urzędowe Potwierdzenie Odbioru</title>
	<meta charset="utf-8"/>
	<style>
		.upo {font-family: 'Arial', sans-serif; max-width: 650px; padding-top: 20px; margin-left: auto; margin-right: auto; font-size: 11pt;}
		.tyt {margin-bottom: 20px; text-align: center; font-size: 14pt;}
		.sek {background-color: #e0e0e0; border: 2px solid black; text-align: left; margin-bottom: 5px; padding-left: 10px}
		.seh {font-weight: bold; margin: 10px 0;}
		.inf {font-size: 10pt; padding-bottom: 10px;}
		.pol {border-top: 2px solid black; border-left: 1px solid black; background-color: white;}
		.p50 {display: table-cell; width: 320px;}
		.ety {text-align: left; font-size: 10pt; padding: 3px; color: #808080;}
		.war {text-align: center; font-size: 16px; padding-top: 15px; padding-bottom: 10px;}
		.brl {border-left: 2px solid black;}
		.nip {padding-right: 50px;}
		.stc {padding-bottom: 30px;}
		.stp {padding-top: 10px;}
		.wyd {text-align: left; font-size: 10pt;}
		.wer {float: right;}
		.we2 {font-size: 11pt; border: 2px solid black; display: table-cell; padding: 2px; width: 100px; text-align: center;}
		.nbr {border-right: none;}
		.b {font-weight: bold;}
	</style>
</head>

<body>
	<div class="upo">
		<div class="tyt">URZĘDOWE POŚWIADCZENIE ODBIORU<br/>DOKUMENTU ELEKTRONICZNEGO</div>
   		<xsl:apply-templates select="//Potwierdzenie"/> 
	</div>
</body>

</html>

</xsl:template>

<xsl:template match="Potwierdzenie">

	<div class="sek">
		<div class="seh">A. PEŁNA NAZWA PODMIOTU, KTÓREMU DORĘCZONO DOKUMENT ELEKTRONICZNY</div>
		<div class="pol">
			<div class="war b"><xsl:value-of select="NazwaPodmiotuPrzyjmujacego"/></div>
		</div>
	</div>

	<div class="sek">
		<div class="seh">B. INFORMACJA O DOKUMENCIE</div>
		
		<div class="inf">Dokument został zarejestrowany w systemie teleinformatycznym Ministerstwa Finansów</div>
		
		<div class="pol">
			<div class="p50">
				<div class="ety">Identyfikator dokumentu:</div>
				<div class="war"><xsl:value-of select="NumerReferencyjny"/></div>
			</div>
			<div class="p50 brl">
				<div class="ety">Dnia (data, czas):</div>
				<div class="war b"><xsl:value-of select="DataWplyniecia"/></div>				
			</div>
		</div>
					
		<div class="pol">
			<div class="ety">Skrót złożonego dokumentu - identyczny z wartością użytą do podpisu dokumentu:</div>
			<div class="war"><xsl:value-of select="SkrotDokumentu"/></div>
		</div>
		
		<div class="pol">
			<div class="ety">Skrót dokumentu w postaci otrzymanej przez system (łącznie z podpisem elektronicznym):</div>
			<div class="war"><xsl:value-of select="SkrotZlozonejStruktury"/></div>
		</div>		
		
		<div class="pol">
			<div class="ety">Dokument zweryfikowano pod względem zgodności ze strukturą logiczną:</div>
			<div class="war"><xsl:value-of select="NazwaStrukturyLogicznej"/></div>
		</div>	
		
		<div class="pol">
			<div class="p50">
				<div class="ety">Identyfikator podatkowy podmiotu występującego jako pierwszy na dokumencie:</div>
				<div class="war b"><span class="nip">NIP1</span><xsl:value-of select="NIP1"/></div>
			</div>
			<div class="p50 brl">
				<div class="ety">Identyfikator podatkowy podmiotu występującego jako drugi na dokumencie:</div>
				<div class="war"></div>				
			</div>
		</div>
		
		<div class="pol">
			<div class="ety">Urząd skarbowy, do którego został złożony dokument:</div>
			<div class="war b">
				<xsl:variable name="schema" select="document($schema-urzedow)"/>
				<xsl:variable name="kodUrzedu" select="KodUrzedu"/>
				<xsl:value-of select="$schema//xs:simpleType[@name='TKodUS']//xs:enumeration[@value=$kodUrzedu]//xs:documentation"/>
			</div>
		</div>	
			
		<div class="pol">
			<div class="ety">Stempel czasu:</div>
			<div class="war stc"><xsl:value-of select="StempelCzasu"/></div>
		</div>			
		
		<div class="pol">
			<div class="ety">Dokument wystawiony automatycznie przez system teleinformatyczny Ministerstwa Finansów:</div>
			<div class="p50">
				<div class="ety">Data i czas wystawienia dokumentu:</div>
			</div>
			<div class="p50">
				<div class="war b"><xsl:copy-of select="//*[local-name()='SigningTime']"/></div>
			</div>
		</div>
	</div>
			
	<div class="stp">
		<div class="wyd">Wydruk: <script>document.write(new Date().toLocaleString().replace(/(\d{2}).(\d{2}).(20\d{2}),/, '$3-$2-$1'))</script></div>
		<div class="wer">
			<div class="we2 nbr b">UPO (4)</div>
			<div class="we2">1/1</div>
		</div>
	</div>
	
</xsl:template>

</xsl:stylesheet>
