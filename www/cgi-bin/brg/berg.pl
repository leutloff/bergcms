#!/usr/bin/perl
#############################################################################
# Start page to work an a single issue. Allows selecting an article
# for further work in different ways.
#
# (c) 2008, 2009, 2010, 2011 Heiko Decker
# (c) 2011, 2012 Christian Leutloff
# 
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
#############################################################################

use strict;
use warnings;

use CGI qw/:standard :html4/;      # Standard CGI Functions
use CGI::Carp qw(fatalsToBrowser); # Show fatal errors in the browser and not only as Internal Server Error
use Fcntl qw/:flock :seek/;        # define LOCK_EX, SEEK_SET etc. 
use PerlIO::encoding;              # Change character encoding when desired, e.g. when writing back to disk 
use utf8;                          # UTF-8 character encoding is recognize in regular expressions, too.

# Standard Input and Standard Output is UTF-8:
binmode(STDIN, ":encoding(utf8)");
binmode(STDOUT, ":encoding(utf8)");

#---> Global Variables
my $VERSION="v2.08, 12.08.2012";
my $TX0=time();#Startzeit (Sekunden)->11.6.2008->get_processing_time   ()->Verarbeitungszeit ermitteln >3s werden angezeigt!
my $LASTfx;# letzte Feldposition (wird aus Tabellenkopf ermittelt) - zur html-Ausgabebugbehebung 17.3.2009
my $nix='';#Dummy$
my ($BTS,$BTE)=(0,1);#Border=Gitternetzliniendicke für Tabellen:Suche,Ergebnis
#---ENDE: HauptConfig: Anpassung an Server
#
my $MySelf=$ENV{'REQUEST_URI'} || (defined($ENV{'SCRIPT_NAME'}) ? $ENV{'SCRIPT_NAME'}.'?'.$ENV{'QUERY_STRING'} : undef) || $0;#eigene Adresse - REQUEST_URI wird bei dem Perl-Test-Web-Server nicht gesetzt

# Database Format and related:
my $dbfile = "";# Name and Path of the selected DB file
my $lim = "\t";# fields in the Database are separated by a TAB
#             a          b       c      d     e   f        g         h       i
my $felder = "Artikel-ID,Kapitel,Nummer,Titel,Typ,Kopftext,Haupttext,Fußtext,TSID";

my $feldtyp = "!";# search in shown fields only or "*" search in all field of the database line 
my $idz = "";# database ID - which DB to use 
my $thema = "";# Purpose of the DB
my $headline = "";# View of the DB (which part is shown)
my ($Kopf, $Tab);
my $rKopf = \$Kopf;
my $rTab  = \$Tab;
my ($treffer,$von);

#----> function prototypes --------------------------------
sub create_database();
sub get_todo_fields();

#----> function prototypes of the shared functions --------
sub replace_umlauts($);
sub replace_html_umlauts($);
sub print_error_page($);
sub print_html_version();

#----> Übergabe-Parameter (HauptDatenSatz)---------------------------
get_db_info(defined(param('AW'))?param('AW'):'berg'); #Listeneintrag (Auswahlliste) merken
#----> SuchFilter-Auswertung!---------------------------
my $FIM=defined(param('FI'))?param('FI'):'';# Feldwahl gegen ALLE Felder ersetzen (s.a. tabfilter2() u. 1-Spaltenstatistik->map_unique_rows()) 20.3.2009
$FIM=~s/\*./\*\*/;# 1Feldwahl gegen ALLE Felder ersetzen (s.a. 1-Spaltenstatistik->map_unique_rows()) 20.3.2009
my $filter="";
if(param('VFI')){$nix=" ";} else{$nix="";}
my $Bfilter=(defined(param('VFI'))?param('VFI'):'*bcdei').$nix.(defined(param('FI'))?param('FI'):'');#zusammenfügen der Filterfelder 15.12.04 - 
my @fi = split(/\s+/, $Bfilter);
my @feldname;
my @fidx;# fields to display
my @qidx;# fields for sorting
my @fip;
my $fiz;
my @fim;
my $feldx="";# FeldreihenfolgeSet
my $el;
$_=$felder;
my $feldz=tr/,//;#Anzahl Felder
#--------- AUSWERTUNG des Filters!
foreach $el(@fi)
    {
    $filter = $filter . $el . " ";
    my $lg=length($el)-1;
    $el=~s/\?//g;     #ab hier ALLE '?' entfernen! - wegen Scriptabbruch-Vorbeugung!

    if($el=~/^\!|^\*/)    #falls !Feld-> Feldx merken für Feldsel.Suchen! 22.7.2004
        {
        $feldx=uc(substr($el,1,$lg));
        $feldtyp=substr($el,0,1);#Feldtyp=! oder * 8.8.2005->falls * ->Feldanzeige wie ! jedoch Suche in allen Feldern!
        my $fidxz=0;# FeldIndexzähler
        if ($el=~/\!\*|\*\*/)# alle Felder für Sortierung verwenden /de 29.7.2004
            {
            #print_error_page("feldz=$feldz");
            while ($fidxz<=$feldz) {$fidx[$fidxz]=$fidxz;$fidxz++;}
            next;
            }
        #Setzen der neuen Feldreihenfolge!
        while ($fidxz<$lg) {$fidx[$fidxz]=ord(substr($feldx,$fidxz,1))-65;$fidxz++;}
        next;
        }
    if($el=~/^\-/) { $fiz++; push(@fim,substr($el,1,$lg));}
    else  {push(@fip,$el);}
    }

#zusammenfügen der Pinfelder
my $fpin=defined(param('VPI'))?param('VPI'):'';#.$nix.(defined(param('PIN'))?param('PIN'):'');
my $sortflg=0;#Sortierfolge->aufsteigend(default)
if (pin_tst('!-')) {$sortflg=1;}
my $Gkflg=0;#Großkleinschreibung Standard=AUS! ->Einschaltbar ->!G ab 7.5.2009 - wegen uniq ->1Spaltenmodus
if (pin_tst('!G')) {$Gkflg=1;}
my $sortFields = "";
if (pin_tst('!q'))# setting the fields for sorting
{
	($nix,my $beginField)=split(/!q/, $fpin);
	($sortFields,$nix)=split(/ /, $beginField);
}
else
{
	$sortFields = "bcdi";
}
# setting the fields for sorting
{
	my $lg=length($sortFields);
    my $fidxz = 0;
    while ($fidxz<$lg) 
    { 
    	$qidx[$fidxz] = ord(substr($sortFields, $fidxz, 1)) - ord('a');
    	$fidxz++; 
    } 	
}
#----> DB prüfen, ggf. Artikelnummern ergänzen-------------------------------
if (-e $dbfile)
{
	if (!check_database_entries())
	{ 
	    correct_database(); 
	}    
}
else
{
	create_database();
}

#----> Ausgabe dynamische HTML-Seite VollZeilen bzw Feldmodus----------------
$rKopf=add_table_head();
($rTab,$treffer,$von)=add_article_references($dbfile, $filter, $felder);
#print_error_page($filter."(".length($filter).")".$maxzeil.$feldx);

print header('-charset' => 'utf-8');
print  start_html('-title'     => $headline,
                  '-style'     => {'src'=>"/brg/css/bgcrud.css"},
                  '-encoding'  => 'utf-8',
                  '-lang'      => 'de');
print '<div id="suche">';
add_title_and_navigation($headline, $filter, $treffer, $von);
print '</div> ';
print '<div id="ergebnis"> <table class="ergebnis" border="'.$BTE.'">'."\n".$rKopf;
print $rTab.'</table></div>';
print_html_version();
print end_html();

#----------------------------------------------------------------
# Output of Table Header incl. Link for Actions and Navigation 
#----------------------------------------------------------------
sub add_title_and_navigation
{
    my ($info, $filter, $treffer, $von) = @_;   
    print '<a name="TopOfWindow"></a>';
    #print (p,$MySelf,p,$RootRef,p,$info,p,$xinfo);
    my $text="";
    my $fi=$filter;
    $fi=~s/\!\w+|\*\w+|\!\*|\*\*//g;#entfernen aller FeldDef-Blöcke und Leerzeichen
    if ($fi eq "")# falls Filter leer->limitierte Satzausgabe+Hinweis!
    {
        $text=$treffer." Eintr&auml;ge "; 
    }
    else
    {
    	$text=$treffer ."/" . $von ;
    }
    
    # get actual parameter list
    my @para=split(/\?/,$MySelf);
    my $cmdparamlist = defined $para[1] ? '?'.$para[1] : '';
        
    print CGI::start_table({'-class' => 'suche','-border' => 0, '-width' => '100%'});
    print Tr(th({'-colspan' => 5}, $headline));
    print CGI::start_Tr();
    
    # Navigation to other parts of the system
    print td('<a href="/" target="_top" title="Beenden - Zur Startseite"><img src="/brg/bgico/abort-22.png" alt="" width="22" height="22" border="0"></a>');#.' '.$RootRef);
       
    print "<td>";
    print '<a title="Gemeindeinformation zusammenstellen (alt)" href="/cgi-bin/brg/xsc.pl'.$cmdparamlist.'">',
          '<img src="/brg/bgico/ark-22.png" alt="" width="22" height="22" border="0">',
          '</a> ';
    print '<a title="Gemeindeinformation zusammenstellen" href="/cgi-bin/brg/maker'.$cmdparamlist.'">',
          '<img src="/brg/bgico/maker-22.png" alt="" width="22" height="22" border="0">',
          '</a> ';
 
    print '<br />';
    print '<a title="Gemeindeinformation herunterladen" href="/dlb/feginfo.pdf">',
          '<img src="/brg/bgico/pdfreaders-f-22px.png" alt="" width="22" height="22" border="0">',
          '</a> ';
    print "</td>";
       
       
    # Navigation inside actual database
    print th(prepare_options());
    
    # Search related
    print "<th>";
    print $text." <br /> ";
    print start_form('-method' => 'POST',
                     #'-action' => $MySelf);
                     '-action' => '/cgi-bin/brg/berg.pl');#?AW='.(defined param('AW') ? param('AW') : 'berg').'&VFI=!bcdfgh&VPI=!abgx -');
    # change the values of VFI and VPI:                 
    param('VFI', '!bcdfgh');
    #param('VPI', '!e!abgx -');# highlight does not work because links are replaced, too
    param('VPI', '!ebgx -');
    print hidden(-name => 'AW'), 
          hidden(-name => 'VFI'), 
          hidden(-name => 'VPI');                     
    print textfield(
        '-name' => 'FI',
        '-size' => '10',
        '-maxlenght' => '200',
        ), 
        '<button name="klix" type="submit" ><img src="/brg/bgico/search-16.png" alt="Suchen" width="16" height="16" border="0"></button>';
    print end_form();   
    print "</th>";
    
    # Help
    print td('<a title="Dokumentation" href="/brg/hilfe.html">',
       '<img src="/brg/bgico/help-22.png" alt="" width="22" height="22" border="0">',
       '</a>');
    
    print CGI::end_Tr();
    print CGI::end_table();
}


#----------------------------------------------------------------
#      TabellenKopf-Ausgabe
#----------------------------------------------------------------
sub add_table_head
    {
    my @f = split( /,/, $felder);
    my @fx;
    my $fz=0;
    my $fzx=-1;
    my ($el, $html);
    my $rhtml=\$html;

    if ($feldx eq "")#NichtFeldModus
        {
        foreach $el (@f)
            {
            $fzx++;# abs. Feldnummer
            next if ($el =~ /^X/) ;
            $fx[$fz++]=$el;
            }
        #if($lfnflg){unshift(@fx, "LfNr");}
        }
    else
        {
        #print_error_page(map({"(".$f[$_].")" } @fidx));
        foreach $el (@fidx)
            {
            $fzx++;# abs. Feldnummer
            $fx[$fz]=$f[$el];$fz++;
            }
        }
    $html .= "<TR>";
    $html.="<TD><i>ED</i></TD>";#Ergänzung um CRUD-Link
    map ({$html .= "<TH>" . replace_umlauts($_) . "</TH>"} @fx);
    $html .= "</TR>\n";
    $LASTfx=$fzx;# eff. Letzte Feldposition merken 17.3.2009
    return $$rhtml;
    }

#----------------------------------------------------------------
#      Tabellen-Ausgabe über Suchfilter EINZEL-FELD-SUCHE
#----------------------------------------------------------------
sub add_article_references
{
    my ($dbfile, $filter, $felder) =  @_;
    my %sorth=(); # SortierCache für Feldselektive Ausgaben
    my (@f, $el, $edkey, @fx, $html,$s);
    my $rhtml=\$html;
    my $rfx=\@fx;
    my @ff = split(/,/, $felder);
    my $sortrf;
    my $treffer=0;
    my $von=0;
    my $articleId='';# Artikelnummer für die CRUD-Funktionalität - löst filepos ab wg. Multiuser
    open (EINGABE, "<:encoding(utf8)", "$dbfile") || print_error_page( "Datei $dbfile konnte nicht geöffnet werden");
    flock(EINGABE, LOCK_SH) || print_error_page("Fehler: Konnte die Datei $dbfile nicht zum Lesen sperren (add_article_references)!");
    my $fldaz=length($feldx)-1;# bei Einzelspalte(uniq) maxzeilen ignorieren! s.u.  6.10.2008
    if($feldx eq '*'){$fldaz=1;}
    while (<EINGABE>)
    {
        $von++;
        my $actualArticle = $_;
        @f=split(/$lim/,$actualArticle);
        $articleId=($f[0]=~/\d+/) ? '&AI='.$f[0] : '';# vorneweg die Artikelnummer bestimmen       
        if ($feldtyp eq "!"){$s=get_fieldset();$_=$s;}#8.8.2005 falls '*' -> alle Felder für Suche berücksichtigen!
        if(!is_matching_field()){ next; }#Treffer?->falls nicht->NEXT!
        if ($feldtyp eq "*"){$s=get_fieldset();}#26.3.2008->PerformanceTuning->get_fieldset() wird hier NUR auf Treffermenge angewendet!
        $treffer++;
        $sorth{get_sortset($actualArticle)}=get_edit_link($articleId).$lim.$s;#.$lim.get_sortset($actualArticle);
    }
    flock(EINGABE, LOCK_UN) || print_error_page("Fehler: Konnte zum Lesen gesperrte Datei $dbfile nicht freigeben (add_article_references)!");       
    close(EINGABE); 
    $treffer=0;
    if($sortflg){$sortrf='remove_html_tags($b) cmp remove_html_tags($a)';} # abwärts
    else {$sortrf='remove_html_tags($a) cmp remove_html_tags($b)';} # aufwärts
    foreach $el (sort {eval($sortrf)} (keys %sorth))
    {
        $edkey=$el;
        $treffer++;
        @fx=split(/$lim/,$sorth{$edkey});
        $fx[$LASTfx]=" " if !$fx[$LASTfx]; #Trick->'letztes' Feld spacen falls leer-damit Tabellengitter immer vollständig!  17.3.2009
        $html .= "<tr>"; # ZeilenMapping aus Array!
        map_unique_rows($rfx,$rhtml);
        $html .= "</tr>\n";
    }
    map ({$html=~s/($_)(?=[^>]*<)/<span class="match">$1<\/span>/gi} @fip);
    return ($$rhtml,$treffer,$von.get_processing_time   ());
}

# prepare link to the given article
sub get_edit_link
{
	my $articleReference=shift;
	my $editLink='<a href="'.'/cgi-bin/brg/bgcrud.pl'.'?AW='.(defined param('AW') ? param('AW') : 'berg').$articleReference;
    if(defined param('VFI')){ $editLink .= '&VFI='.param('VFI');}
    if(defined param('VPI')){ $editLink .= '&VPI='.param('VPI');}
    if(defined param('FI')){ $editLink .= '&FI='.param('FI');}
    $editLink .= '" title="Bearbeiten"> ';
    $editLink .= '<img src="/brg/bgico/pencil-22.png" alt="Bearbeiten" width="22" height="22">';
    $editLink .= ' </a>';
    return replace_umlauts($editLink);
}

sub is_matching_field #VollzeilenSuche
    {
    my ($e,$x,$x0);
    $x0=\$_;
    foreach $e(@fip)
        {
        $x=$x0;
        if($Gkflg) {return(0) unless ($$x=~/$e/);}else{return(0) unless ($$x=~/$e/i);}
        }
    foreach $e(@fim)
        {
        $x=$x0;
        if($Gkflg) {return(0) if ($$x=~/$e/) ;} else {return(0) if ($$x=~/$e/i) ;}
        }
    return(1);
    }

sub get_fieldset # returns the selected parts from the article 
    {
    my @f = split(/$lim/, $_);
    my $e;
    my $x = "";
    foreach $e(@fidx)
        {
        $x.=$lim.(defined($f[$e])?$f[$e]:'');
        }
    return substr($x, 1);# remove first $lim again
    }

sub get_sortset # returns the fields of the article that are used for as sorting key
{
  	my $actualArticle = shift;
    my @f = split(/$lim/, $actualArticle);
    my $e;
    my $x = "";
    foreach $e(@qidx)
    {
        $x .= '#'.(defined($f[$e]) ? $f[$e] : '');
    }
    return substr($x, 1);# remove first # again
}

sub map_unique_rows #Falls flg -> Wiederholungen des SpaltenInhalts blanken!
    {
    my ($rfx,$rhtml)=@_;#Array-Referenz
    my $sp;
    map ({$sp=$_;
        $$rhtml .= "<td>" . replace_umlauts((defined($sp)?$sp:'')) . "</td>";
        } @$rfx);
    }

#----------------------------------------------------------------
#      Suchen/Laden -Auswertungs-SET! in IndexDB
# TODO ersetzen, in dem die entsprechenden Definitionen an die entsprechende Stelle geschoben werden. - gemeinsam für berg.pl und bgcrud.pl!
#----------------------------------------------------------------
sub get_db_info
{
    my $auswahl=shift;
    my $memo = '';
    if ($auswahl=~/bbup/)
    {
        $memo = 'Backup:Gemeindezeitungs-Backup-Datenbank#br/feginfo.bup';
    }
    else
    {
        $memo = 'Gemeindezeitungs-Generator#br/feginfo.csv'
    }
    ($headline, $dbfile)=split(/#/, $memo);
}

# sets the selections
# replaces the multiple loads of berg.opt
sub prepare_options
{
#  a          b       c      d     e   f        g         h       i
# "Artikel-ID,Kapitel,Nummer,Titel,Typ,Kopftext,Haupttext,Fußtext,TSID";
	my (%sid, $optionLines, $k, @f, $opx);
    @f=split(/&/,$MySelf."&");#weitere Parameter vorheriger Optionen löschen!
    my $myeff=$f[0];

# orig: AW=bbup#zurück zum Zeitungsgenerator#Zeitungsgenerator#?AW=berg&VFI=!bcdei&VPI=!ebgx!-!tzuletzt ge%C3%A4nderte Artikel
	if (defined(param('AW')) && param('AW')=~/bbup/)
	{
		$optionLines = <<OPTLINES;
AW=bbup#zur%C3%BCck zum Zeitungsgenerator#Zeitungsgenerator#?AW=berg&VFI=!bcdei&VPI=!qi !-!tzuletzt ge%C3%A4nderte Texte
OPTLINES
	}
	else
	{
# AW=berg# FeG-Zeitung generieren NG# <img src="/xvico/ark.png" alt="Gemeindeinfo zusammenstellen" width="25" height="25" border="0"> #/cgi-bin/brg/xsc.pl?:PARAM:		
# AW=berg#4) Suche - nur in Kopfdaten#lokal#&VFI=!bcdei&VPI=!ebgx!tSuche - nur in Kopfdaten
# AW=berg#8) Suche im gesamten Kontext#global#&VFI=*bcdei&VPI=!bcdeigx!tSuche im gesamten Kontext
# AW=berg#9) Textsuche (m. Hervorhebung der Fundstellen!)#Text?#&VFI=!bcdfgh&VPI=!abgx!tSuche in allen Texten&FI=redaktion
# orig:   AW=berg#0b) NUR aktive Texte#aktiv#&VFI=!bcde -\-\d{2,}&VPI=!ebgx!tNUR aktive Texte
# wanted: AW=berg#05) nur aktive Texte#aktiv#&VFI=!bcdei -\\-\\d{2,}&VPI=!ebgx!tnur aktive Texte
# orig:   AW=berg#6) Einstellungen(Basisdaten und Dokumenteneinstellungen)#Einst.#&VFI=!bcd -(-\d{1,}|2:|1:|3:|9:)&VPI=!ebgx!tDokumenteneinstellungen
# wanted: AW=berg#09) Einstellungen (Basisdaten und Dokumenteneinstellungen)#Einst.#&VFI=!bcdei -(-\\d{1,}|2:|1:|3:|9:)&VPI=!ebgx!tDokumenteneinstellungen
# orig: AW=berg#0a) zuletzt geänderte Einträge#aktuell bearb.#&VFI=!id&VPI=!ebgx!-!tzuletzt geaenderte Artikel

        $optionLines = <<OPTLINES; 
AW=berg#01) Aufgabenliste des Redaktionsteams#To-Do#?AW=berg&VFI=*gf dolist&VPI=!tToDo
AW=berg#02) Bilder hochladen#Bilder#/cgi-bin/brg/bgul.pl?:PARAM:
AW=berg#03) Alle Texte der Datenbank#Alles#?AW=berg&VFI=*bcdei&VPI=!qbcdi
AW=berg#04) zuletzt ge%C3%A4nderte Texte#bearbeitet#?AW=berg&VFI=!bcdei&VPI=!qi !-!tzuletzt ge%C3%A4nderte Texte
AW=berg#05) nur aktive Texte#aktiv#?AW=berg&VFI=!bcdei -\\t\\-\\d{1,3}\\t&VPI=!qbcdi !tnur aktive Texte
AW=berg#06) Artikelliste#Artikel#?AW=berg&VFI=!bcdei ^(1|9): -\\s-\\d&VPI=!qbcdi !tArtikelliste
AW=berg#07) Angebotsliste#Angebote#?AW=berg&VFI=!bcdei ^2: -\\s-\\d&VPI=!qbcdi !tAngebotsliste
AW=berg#08) Hauskreisliste#HKs#?AW=berg&VFI=!bcdei ^3: -\\s-\\d&VPI=!qbcdi !tHauskreisliste
AW=berg#09) Einstellungen (Basisdaten und Dokumenteneinstellungen)#Einst.#?AW=berg&VFI=!bcdei ^0:\\w&VPI=!qbcdi !tDokumenteneinstellungen
AW=berg#10) Backup-Archiv#Backup#?AW=bbup&VFI=!bcdei&VPI=!bcdeigx!-!tBackup-Archiv
OPTLINES
    }
    foreach (split(/\n/,$optionLines))
    {
    	chomp();
        @f=split(/#/,$_);
        $sid{(defined($f[0])?$f[0]:'').(defined($f[1])?$f[1]:'').(defined($f[2])?$f[2]:'')}=$_;#SortID-Hash füllen - Optionsreihenfolge=Zwangssortieren ab 20.8.2007
    }
    my $optset = "<tr>";
    my $optcnt = 0;
    foreach $k( sort{remove_html_tags($a) cmp remove_html_tags($b)} keys %sid)
    {
        #print $sid{$k}, "\n";
        @f=split(/#/,$sid{$k});
        $opx=defined($f[3]) ? $f[3] : "";
        $opx=~s/:FI:/$filter/;#Filter durch akt. Variable ersetzen ! 4.7.2008
        #eval $opx;
        if($opx=~/:PARAM:/)# z.B. xsc.cgi um Parameter ergänzen
        {
            my @para=split(/\?/,$MySelf);
            if (defined $para[1]) { $opx=~s/:PARAM:/$para[1]/; }
            else  { $opx=~s/:PARAM://; }
        } 
        #print '$opx:', $opx, ', $f[1]:', $f[1], ', $f[2]:', $f[2], "\n";
        if ($f[3]=~/^\&/) # beginnt der Zusatzparameter mit '&' -> Filterparameter - sonst als normalen LINK interpretieren!!! 13.10.2005
        { 
            $optset.='<td><a href="'.$myeff.$opx.'" title="'.replace_umlauts($f[1]).'" >'.$f[2].'</a></td>'."\n";
        }
        else 
        {
        	$optset.='<td><a href="'.$opx.'" title="'.replace_umlauts($f[1]).'" >'.$f[2].'</a></td>'."\n";
        }
        $optcnt++;
        #print_error_page($optset);
    }
    $optset .= "</tr>";
    #print $optset, "\n";
    
    # add sub title
    my $additionaltitle = '&nbsp;';
    if (pin_tst('!t'))
    {
        ($nix, $additionaltitle) = split(/!t/i,$fpin);
        $additionaltitle = ' => '.replace_umlauts($additionaltitle);
    }
  	$optset .= Tr(th({'-colspan' => $optcnt}, $additionaltitle));
    
    return('<table class="suche" border="0">'.$optset.'</table>');       
}

sub remove_html_tags # entferne beliebigen HTML-Tag am Anfang des Referenz-$ ! 18.3.2005
    {
    my $p=shift;#ScalarReferens!
    $p=~s/^<.*?>//;
    return(uc($p));
    }

#----------------------------------------------------------------------------
# Calculates the processing of this script.
#----------------------------------------------------------------------------
sub get_processing_time 
    {
    my $tges=time()-$TX0;
    if($tges>0){
    	return(" (".$tges." s)");
    }
    return(" ");
    }

sub pin_tst # jeder pin/Opt.-Befehl kann jetzt auch voreingestellt($flags) werden! 29.1.2009
    {
    my $f=shift;
    #if ($fpin=~/$f/  || $flags=~/$f/){return(1);}
    if ($fpin=~/$f/) { return (1); }
    return (0);
    }
    
#----------------------------------------------------------------
# Sicherstellen, dass in der ersten Spalte der DB auch nur Nummern stehen
#----------------------------------------------------------------
sub check_database_entries
    {
    #return(1) if (param('AW')!~/berg/ and param('AW')!~/bbup/);# nur diese beiden Datenbanken sollen geprüft werden  
    open(FILE, "<:encoding(utf8)", "$dbfile") || print_error_page("Fehler: Datei ($dbfile) existiert nicht! (check_database_entries - ".$!.")");# Input öffnen, auch zum Schreiben.
    flock(FILE, LOCK_EX) || print_error_page("Fehler: Konnte die Datei $dbfile nicht zum Schreiben sperren (check_database_entries - ".$!.")!");# die gesamte Operation gegen parallele Zugriffe sichern, deswegen auch hier schon Schreibschutz
    my $ret=1;
    while(<FILE>)
        {
        my @f = split (/$lim/, $_);# in Einzelfelder zerlegen
        if ($f[0]!~/\d+/)
            {
            $ret=0;# in dieser Zeile ist keine Zeile in dem Bericht-Feld, das die Artikelnummer beinhalten soll
            last;
            }
        }
    flock(FILE, LOCK_UN) || print_error_page("Fehler: Konnte zum Schreiben gesperrte Datei $dbfile nicht freigeben (check_database_entries - ".$!.")!");
    close(FILE);
    return($ret);
    }

#----------------------------------------------------------------
# Die erste Spalte der DB durchnummerieren
#----------------------------------------------------------------
sub correct_database
    {
    #return if (param('AW')!~/berg/ and param('AW')!~/bbup/);# nur diese beiden Datenbanken sollen geändert werden  
    open(FILE, "+<:encoding(utf8)", "$dbfile") || print_error_page("Fehler: Datei ($dbfile) existiert nicht! (correct_database - ".$!.")");# Input öffnen, auch zum Schreiben.
    flock(FILE, LOCK_EX) || print_error_page("Fehler: Konnte die Datei $dbfile nicht zum Schreiben sperren (correct_database - ".$!.")!");# die gesamte Operation gegen parallele Zugriffe sichern
    my $articleId=1;
    my @lines=();
    while(<FILE>)
        {
        my @f = split(/$lim/, $_);# in Einzelfelder zerlegen
        $f[0] = "$articleId";
        push(@lines, join($lim,@f));
        ++$articleId;
        }
    seek(FILE, 0, SEEK_SET);
    my $line='';
    foreach $line (@lines)
        {
        print FILE $line;
        }
    flock(FILE, LOCK_UN) || print_error_page("Fehler: Konnte zum Schreiben gesperrte Datei $dbfile nicht freigeben (correct_database - ".$!.")!");
    close(FILE);
    }

#----------------------------------------------------------------
# Create a new and empty database with TODO only
#----------------------------------------------------------------
sub create_database()
{
    open(COIDX, ">:encoding(utf8)", "$dbfile") || print_error_page("Konnte $dbfile nicht öffnen! (Interner Fehler: ".$!.")");
    #          Artikel-ID,Kapitel,Nummer,Titel,Typ,Kopftext,Haupttext,Fußtext,TSID";   
    print COIDX '1'.$lim.get_todo_fields()."\n";
    close(COIDX);
}

#----------------------------------------------------------------
# Content of TODO entry - except number
#----------------------------------------------------------------
sub get_todo_fields()
{
	return '0:Prolog (Vorlauf)'.$lim.'-01'.$lim.'Redaktion - ToDoList'.$lim.'F'
        .$lim.'Database created on '.get_single_date()
        .$lim.'This is the article that may be use as a To Do List when coordinating the teams work.'
        .$lim.' '.$lim.' ';
}

#----------------------------------------------------------------
# Returns the actual date.
#----------------------------------------------------------------
sub get_single_date
{
    my ($ss,$mm,$hh,$d,$m,$y,$wt)= (localtime(time()))[0..6];
    my @WT=qw(So Mo Di Mi Do Fr Sa);
    $y+=1900;
    $m++;
    return(sprintf("%04d%02d%02d-%02d%02d%02d-%s",$y,$m,$d,$hh,$mm,$ss,$WT[$wt]));
}


#############################################################################
# The following functions are shared between the perl scripts.
# Synchronization ensured the last time on: 2012-08-12
#############################################################################

#----------------------------------------------------------------------------
# Replace german Umlauts with their HTML entity.
# replace_umlauts and replace_html_umlauts must match!
#----------------------------------------------------------------------------
sub replace_umlauts($)
{
    my ($value) = shift;
    if (!defined($value)) { return; }
    $value=~s/ü/&uuml;/g;                        $value=~s/%C3%BC/&uuml;/g;
    $value=~s/ä/&auml;/g; $value=~s/Ã¤/&auml;/g; $value=~s/%C3%A4/&auml;/g;
    $value=~s/ö/&ouml;/g;                        $value=~s/%C3%B6/&ouml;/g;
    $value=~s/Ü/&Uuml;/g;                        $value=~s/%C3%9C/&Uuml;/g;
    $value=~s/Ä/&Auml;/g;                        $value=~s/%C3%84/&Auml;/g;
    $value=~s/Ö/&Ouml;/g;                        $value=~s/%C3%96/&Ouml;/g;
    $value=~s/ß/&szlig;/g;                       $value=~s/%C3%9F/&szlig;/g;
    return $value;
}

#----------------------------------------------------------------------------
# Replace HTML entities with their german Umlauts equivalent in UTF-8.
# replace_umlauts and replace_html_umlauts must match!
#----------------------------------------------------------------------------
sub replace_html_umlauts($)
{
    my ($value) = shift;
    # HTML Kodierung wird nach UTF-8 gewandelt:
    $value=~s/&uuml;/ü/g;
    $value=~s/&auml;/ä/g;
    $value=~s/&ouml;/ö/g;
    $value=~s/&Uuml;/Ü/g;
    $value=~s/&Auml;/Ä/g;
    $value=~s/&Ouml;/Ö/g;
    $value=~s/&szlig;/ß/g;
    return $value;
}

#----------------------------------------------------------------------------
# Print a HTML page with an error message.
#----------------------------------------------------------------------------
sub print_error_page($)
{
    my ($msg) = shift;
    my $gfx = '<img src="/brg/bgico/stop.png" width="75" height="75" alt="Stopp">';
    my $back = '<a href="/cgi-bin/brg/berg.pl" title="Gemeinedezeitungs-Generator erneut laden">'
              .'<img src="/brg/bgico/berg-32.png" width="32" height="32" border="0"></a>'."\n";
    print header('-charset' => 'utf-8'),
          start_html('-title'     => 'Fehler',
                     '-bgcolor'   => 'tomato',
                     '-fontcolor' => 'yellow',
                     '-encoding'  => 'utf-8',
                     '-lang'      => 'de'
          );
    print h2({'-align'=>'center'}, "*\n");
    print table(
        {'-align'=>'center',  '-border' => 8, '-bgcolor' => 'khaki' }, "\n",
        th($gfx), th(replace_umlauts(escapeHTML($msg))), td(replace_umlauts($back))
        ),
        h2({'-align'=>'center'}, "*\n");
    print_html_version();
    print end_html();
    exit 1;
}

#----------------------------------------------------------------------------
# Print the version information (script and Perl).
#----------------------------------------------------------------------------
sub print_html_version()
{
    print "\n";
    print '<p class="version">Version: '.$VERSION." (Perl $])</p>\n";
}    

;
