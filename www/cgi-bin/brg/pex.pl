#!/usr/bin/perl
#############################################################################
# This program extracts the content from the CSV database and handles the 
# commands starting with >. Output is a LaTeX file for final processing.
#
# (c) 2007, 2009, 2010, 2011 Heiko Decker
# (c) 2011, 2012 Christian Leutloff
# 
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
# Aufruf  perl pex.pl <NAME> <Bericht>
# Ergebnis : generiert aus TeX-Meta-DatenBank-Datei: NAME.csv
#            eine LaTeX-Datei (Bericht.tex)
#
# Hinweis: die TeX-Meta-DatenBank-Datei: NAME.CSV  kann via Internet gepflegt/Erweitert werden (DDMS->berg/bgcrud.pl)
#
# FORMAT NAME.PEX (Datenbank)
#    FeldNr-> Feldertrenner=TAB(\t=\09x) -> Felder 1-3 bilden eine ORDNUNGSHIERACHIE!
#     0:    Bericht...........................dies ist nun der Artikelindex (AI) - war: hier können verschiedene Berichte in einer DB gebündelt werden(0.Sortierkriterium/Ausgabereihenfolge der Artikel)
#     1:    Kapitel...........................Ordnungsbegriff für Themenblöcke(1.Sortierkriterium/Ausgabereihenfolge der Artikel)
#     2:    Nr................................Ordnungsbegriff = LfNr -> sortiert die Ausgabereihenfolge der Artikel unterhalb der Kapitel(2.Sortierkriterium/Ausgabereihenfolge der Artikel)
#     3:    Titel.............................Ordnungsbegriff = Titel:Artikeleüberschrift (3.Sortierkriterium/Ausgabereihenfolge der Artikel)
#     4:    Typ...............................3 Satztypen -> K=Konfiguration (Dokumentvorlagen, Datendef. etc.)  F=Fixdaten (Titelseite, Impressum etc.) werden als Einzel
#     5:    Kopftext..........................Text im PEX-Format ->Metasprache-> Vorlage für TeX-Formatierung/Umsetzung
#     6:    Haupttext.........................Text im PEX-Format ->Metasprache-> Vorlage für TeX-Formatierung/Umsetzung
#     7:    Fußtext...........................Text im PEX-Format ->Metasprache-> Vorlage für TeX-Formatierung/Umsetzung
#        ->die Aufteilung in Kopf-, Haupt- und Fußtext soll der Übersicht bei der Eingabe im Webbrowser dienen->wird im Hash als ein Text zusammengefasst!
#
#############################################################################
#package BERG::PEX;

use strict;
use warnings;

use IO::File;                      #FileHandel(OO-Generation!)
use Fcntl qw/:flock/;              # LOCK_EX etc. definieren
use PerlIO::encoding;              # Zeichenkodierung ändern können, z.B. beim Wegschreiben 
use utf8;                          # UTF-8 Kodierung auch in regulären Ausdrücken berücksichtigen

use vars qw(@EXPORT_OK @ISA $VERSION);

$VERSION = 'v2.08/15.12.2012';
# exports are used for testing purposes
#@EXPORT_OK = qw(add_author add_bold add_caption add_italic replace_characters);
#@ISA = qw(Exporter);

# Standardeingabe und Standardausgabe in UTF-8:
binmode(STDIN, ":encoding(utf8)");
binmode(STDOUT, ":encoding(utf8)");

# run is called, when this script is used as standalone script.
# Otherwise the methods are available from the package.
#__PACKAGE__->run( @ARGV ) unless caller();

#---Start : Globale --------------------------------------------------
my %BEF=();#TextMakro-Befehlshash 23.10.2010
my $SPM=1;#SpaltenMemo - damit Automatik bei TagGesamtTabellen(=1spaltig) und zurücksetzen funzt!27.11.2008
my %TTKEY=();#TagTabellenSpalten-Hash init -> GesamtArtikelTabelle 26.11.2008
my $TTKAP="";#Kapitelspeicher-> Tabellenplot nach Kapitelwechsel! 26.11.2008
my $TTAB="";#Tabellenplot-Speicher Inhalt wird nach Kapitelwechsel ausgegeben 26.11.2008
my $TABTXTFLG=2;#ArtikelTagFlag-> 2=komplett 1=NUR InfoKopftabelle(ohne Textanhang 0=ABSCHALTEN(komplett ausblenden->man.Übersichtstabellen einfügen möglich!26.11.2008
my $BILDFLG=1;#1=Bildausgabe 0=Bildunterdrückung - oeko-Formatierung fuer erstellungsphase 10.6.2008
my $NL="\\\\";#LatexNewline
my $ITZ=0;#Latex\item-Zähler
my $ITS="";# letztes Metazeichen - wird in testit() ggf. mit ausgegeben, Beispielwert ist \item
my $KAPM="Kapitel";#Kapitelspeicher->Hirachie->Thema(Kapitel)->Tag(falls Nr=1-7)->Titel
my $TAGM=0;#WochentagsSpeicher->Hirachie->Thema(Kapitel)->Tag(falls Nr=1-7)->Titel
my @TXZ;#globaler Textzeilenspeicher
my $Iformat="|p{10mm}||p{42mm}|";#InfoTabellenformat->Artikelheader (falls gewünscht ! - unterbinden: 1.Zeile = >*
#my $Bpfad="bilder";#Bilder-Pfad -> *.jpg-Archiv
my $Bpfad="/home/aachen/cgi-bin/brg/br/bilder";#Bilder-Pfad -> *.jpg-Archiv
my $Logopfad="/home/aachen/cgi-bin/brg/br/icons";#Bilder-Pfad -> *.jpg-Archiv
my $SCALE=undef;#Skalierung festlegen, z.B. bei Tabellen
my $SGOF=undef;#SchriftgroessenOffset
my $Monat=undef;#Erscheinungsmonat
my $Jahr=undef;#Erscheinungsjahr
my $NUMMER=undef;#Fortlaufende Nummerierung der Gemeindeinformationen
my $AUSGABEZEITRAUM=undef;#Text der Ausgabe mit Erscheinungsjahr/Erscheinungsmonat; wird im PDF Inhaltsverzeichnis verwendent 
my $AUSGABE=undef;#Text mit $AUSGABEZEITRAUM und fortlaufender Nummerierung; Unterschrift der Titelseite
my $AUFLAGE=undef;#Auflagenhöhe
my $Rende=undef;#Datum des Redaktionsschlusses
my $RENDE=undef;#Text zum Redaktionsschluss
#-----WochentagDef s. INFOLISTE
my @WTG= qw(nix Montag  Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);
#-----SchriftgroessenDef />sg#N#
my $SGO=4;# Standardschriftgröße
my $SGU=$SGO+0;# Standardschriftgröße der kleinsten Überschrift
my @SG= qw(\\tiny \\scriptsize \\footnotesize \\small \\normalsize \\large \\Large \\LARGE \\huge \\Huge);
#-----Zeilenabstandsdichte />sg#N#
my $ZD0=1;# StandardZeilendiche =1
my $ZDM=1;# StandardMEMO-Zeilendiche =1 24.5.2007->bei >zd#0 wird ZD0=ZDM!
my $ZDI=0.5;# StandardZeilendiche =0.5ex Items
# TODO verschieben
my %symbole=();#Symbolhash aus pifont
$symbole{"karo"}=117;
$symbole{"dreieck"}=115;
$symbole{"kasten"}=111;
$symbole{"kreis"}=109;
$symbole{"finger"}=43;
$symbole{"hand"}=44;
$symbole{"kreuz"}=55;
$symbole{"kreuzjesu"}=62;
$symbole{"haken"}=51;
$symbole{"schere"}=34;
$symbole{"pfeil"}=212;
$symbole{"stern"}=80;
$symbole{"stift"}=46;
$symbole{"herz"}=170;
$symbole{"brief"}=41;
$symbole{"blume"}=96;
$symbole{"telefon"}=37;

my %idx=();#IndexHash - DB einscannen
my $inp = "";# Filename for the input
my $OUPTEX = "";# Filename for the output    
my @stack = "";#BefehlsReturnStack
my $OUT = undef;# Handle to the resulting output file 

#-----Start (Main)-----------    
#sub run
#{
    $inp = $ARGV[0];
    if (!$inp) { $inp="feginfo.csv"; }
    if ($ARGV[1])
        {   
        if ($ARGV[1] =~ /.tex$/) { $OUPTEX = $ARGV[1]; }
        else { $OUPTEX = $ARGV[1].".tex"; }
        }
    else
        {
        $OUPTEX=$inp;
        $OUPTEX=~s/.csv/.tex/;
        }
    die "Fehler: Input- ($inp) und Outputdatei ($OUPTEX) dürfen nicht gleich sein!" if ($OUPTEX eq $inp);      
    #my $OUT=IO::File->new(">$OUPTEX");
    open($OUT, ">:encoding(utf8)", $OUPTEX) or die "Die Ausgabedatei $OUPTEX kann nicht geöffnet werden.";
    if(defined $OUT) {;} else {die "Fehler beim Oeffnen von $OUPTEX";}

    print_version();
    load_database();
    create_tex();
#}

#-----------------------------------------------------
sub print_version # Version in TeX-Datei und Standardausgabe
#-----------------------------------------------------
{
    my $msg = "Programm: $0, $VERSION (Perl $]) ---> Dokument: IN($inp) => OUT($OUPTEX) [ ".scalar localtime()." ]\n";
    print $OUT '%'." $msg";
    print "$msg";
}

#-----------------------------------------------------
sub load_database #...parsen der PEX-DB-Datei ->hash!
#-----------------------------------------------------
    {
    my (@f,$k,$s,$PIN);
    my $LIM="\x09";
    #$PIN=IO::File->new("<$inp");
    open($PIN, "<:encoding(utf8)", $inp);   
    if(defined $PIN) {;} else {die  "Fehler beim Öffnen von $inp!";}
    flock($PIN, LOCK_SH) || die("\nFehler: Konnte die Datei $inp nicht zum Lesen sperren (load_database)!\n");
    print "\nMoment bitte ...PeX-DB [$inp] wird gescannt!...\n";
    while (<$PIN>)
        {
        chompx(\$_);#UniversalChomp-call by Reference
        @f=split(/$LIM/,$_);
        #next if $f[0] eq $OUPTEX;# nur texte aus def. Bericht laden - 0 ist nun der AI (Artikelindex)
        next if ($f[2] !~ /^[0-9-+]*$/ || $f[2]<0);# Texte mit Nr.<0 oder keiner Zahl direkt ausblenden!
        #$k=$f[0].$LIM.$f[1].$LIM.$f[2].$LIM.$f[3];# Key= Bericht+Kapitel+Nr+Titel - Ordnungshierachie!
        $k=$f[1].$LIM.$f[2].$LIM.$f[3];# Key=Kapitel+Nr+Titel - Ordnungshierachie!
        if (defined $f[7])
        {
            $s=$f[1].$LIM.$f[2].$LIM.$f[3].$LIM.$f[4].$LIM.$f[5]."<br>".$f[6]."<br>".$f[7]."<br>";
        }
        else
        {
            $s=$f[1].$LIM.$f[2].$LIM.$f[3].$LIM.$f[4].$LIM.$f[5]."<br>".$f[6]."<br> <br>";
        }
        $idx{$k}=$s;#->ab in den Sort-Hash
        }
    flock($PIN, LOCK_UN) || print "\nFehler: Konnte die Datei $inp nicht zum Lesen sperren (load_database)!\n";
    $PIN->close();
    }


#-----------------------------------------------------
sub create_tex #...TeX-Dokument aus SortHash generieren!
#-----------------------------------------------------
    {
    my ($kap,$zz,$k,$tnr,$titel,$typ,$text,$top,$x,$ueber,$s);
    my $LIM="\x09";
    print  "\nMoment bitte ...TeX-Dokument [$OUPTEX] wird erzeugt!...\n";
    foreach $k (sort keys %idx)
        {
        ($kap,$tnr,$titel,$typ,$text)=split(/$LIM/,$idx{$k});
        @TXZ=split(/<br>/,$text);# Textblock in Zeilenspeicher!
        $zz++;
        print "$zz\t$kap\t$tnr\t$titel\t$typ\t$#TXZ\n";
        # todo: hier verweis auf den artikel ausgeben
        #plott_zeilen();
        #TODO: TTKAP entfernen
        if($TTKAP && (($tnr==9 || $TTKAP ne $kap))) # falls Tagestabelle aktiv und Kapitelwechsel generell - jetzt abschließen 26.11.2008
            {
            $TTKAP=""; print $OUT '\end{tabular}'."\n";
            print $OUT '\newpage'."\n";#Seitenvorschub am Ende
            testit(">SPALTEN#".$SPM);
            }
    
        if ($typ eq "A") # Artikel->Hierachie-Management.............Kapitel,Wochentag,Titel
            {
            if($KAPM ne $kap)# Kapitelwechsel?
                {
                $KAPM=$kap;
                print $OUT "% Kapitelwechsel= $KAPM ($TTKAP) \n";
                ($x,$ueber)=split(/\:/,$kap);
                if (("Angebote" eq $ueber) || ("Hauskreise" eq $ueber)) 
                    {
                    if ("Angebote" eq $ueber) 
                        {
                        $top='>1#Regelm\"a{\ss}ige Angebote (alt)#x'; testit($top);#section generieren 
                        $top='>2#\"Uberblick (alt)#x'; testit($top);#subsection generieren
                        }
                    else
                        {
                        $top=">2#".$ueber." (alt)#x"; testit($top);#section generieren    
                        } 
                    }
                 else
                    {
                    $top=">1#".$ueber."#x"; testit($top);#section generieren    
                    }
                }
            if($tnr==0||$tnr>7)#kein Wochentag
                {
                #if($TABTXTFLG==0 && $tnr==9){next;} #Tagesartikel-Anhänge auch ausblenden 26.11.2008
                if(length($titel)>=2){$top=">2#".$titel."#x"; testit($top);}#subsection generieren
                }
            else # Wochentag
                {
                if ($TAGM!=$tnr)#Tageswechsel->subsection generieren
                    {
                    $TAGM=$tnr;
                    if($TABTXTFLG>0) # subsection generieren, falls Artikel/Tagherachie gewünscht 26.11.2008
                        {
                        $top=">2#".$WTG[$tnr]."#x"; testit($top);
                        }
                    }
                if($TABTXTFLG>0 && length($titel)>=2) # sub-subsection generieren, falls Artikel/Tagherachie gewünscht 26.11.2008
                        {
                        $top=">3#".$titel."#x"; testit($top);#sub-subsection generieren
                        }
                }
    
            if ($TXZ[0]!~/^\>\*/) # falls KEIN führendes >* ---> InfoKopf erzeuegen
                {
                if($TABTXTFLG==0)   #ArtikelTag-Generierung NUR, falls erwünscht! 26.11.2008
                    {
                    if($TTKAP eq $KAPM){print_table_for_day($titel);next;} # falls aktuelle Tabelle erzeugt werden doll?
                    else # sonst übergehen
                        {
                        if($tnr==9){create_infotab();}# falls TagesTabellenTag=9->Ausgeben 27.11.2008
                        else
                            {
                            while($#TXZ>=0)
                                {
                                $s=shift(@TXZ);# leeren des Zeilenspeichers
                                last if $s=~/^\>\*/;# falls >* folgt abbruch!
                                }
                            next;
                            }
                        }
                    #
                    }
                else
                    {
                    create_infotab(); if($tnr!=9){next if($TABTXTFLG==1);}#Textanhang nach InfoKopftabelle EIN>1/AUS=1blenden 25.11.2008 next;
                    }
                }
            else {shift(@TXZ);} # 1. Dummyzeile entfernen!
            }
        # Resttextzeilen interpretieren/generieren
        while($#TXZ>=0)
            {
            $s=shift(@TXZ);
            if($s=~/^>tt0/){last if($TABTXTFLG!=0);} #
            else{testit($s);}
            }
        }
    }

#TODO entfernen:
#-----------------------------------------------------
sub create_infotab  #...Artikel-Kopftabelle generieren!
#-----------------------------------------------------
    {
    my ($hl,@f,$s,$format);
    $format=$Iformat;
    if($SCALE){$format=~ s/([0-9.]+)/sprintf("%1.1f",$1 * $SCALE) /ge; }# TabellenSpaltenSkalierung!
    $hl="";
    if($format=~/\|/)# Vertikallinien im TabFormat?->Horizontallinie
          {
          $hl="\\cline{1-2}\n";
          }
    print $OUT " \\begin{tabular}{$format}$hl";
    while($#TXZ>=0)
        {
        $s=shift(@TXZ);# leeren des Zeilenspeichers
        last if $s=~/^\>\*/;# falls >* folgt abbruch!
        $s=~ s/Tel.:|Tel:/\\ding\{37\}/g; #falls Tel.?-> Telefonsymbolersatz
        $s=~ s/e-mail:|email:|mail:/\\ding\{41\}/ig; #falls email.?-> Briefsymbolersatz
        @f=split(/#/,$s);
        my $fx=$f[0];
        if($fx=~s/^\-//g)# falls 1.Zeichen in 1.Spalte ="-" ->Hline unterbinden
              { print $OUT "$fx&$f[1]$NL\n";}
        else {print $OUT "$fx&$f[1]$NL$hl\n";}
        }
    print $OUT "\\end{tabular} $NL [1.5ex]\n";
    }



#-----------------------------------------------------
sub print_table #...Tabelle     bis >* erzeugen
#-----------------------------------------------------
    {
    my($nix,$pos,$rahmen,$ueb)=split(/#/,$_);
    my(@f,$e,$s,$ra,$lin,$fx);
    $ra="";$lin="";
    if($rahmen eq "|"){$ra="|";$lin="\\hline";}
    print $OUT "\\begin{tabular}".$pos."{".$ra;
    #--- 1.Zeile=Spaltenbreiten
    $s=shift(@TXZ);
    @f=split(/#/,$s);
    foreach $e(@f)
        {
        if($SCALE) # falls Skalierung
            {
            $e=~ s/([0-9.]+)/sprintf("%1.1f",$1 * $SCALE) /ge;
            }
        print $OUT "L{$e}".$ra;
        }
    print $OUT "} $lin \n";

    #--- 2.Zeile=Ueberschriften
    $s=shift(@TXZ);
    @f=split(/#/,$s);
    $s="";
    foreach $e(@f){$s.="\\".$ueb."{$e}&";}
    chop($s);print $OUT "$s $NL $lin $lin\n";
    #--- 3...n.Zeile=Tabellenzeilen(Inhalte)
    $s="?";
    while($s)
        {
        $s=shift(@TXZ);
        $s =~ s/Tel.:|Tel:/\\ding\{37\}/g; #falls Tel.?-> Telefonsymbolersatz - TODO: Standardfunktion für Tel und Email nutzen!
        $s =~ s/e-mail:|email:|mail:/\\ding\{41\}/ig; #falls email.?-> Briefsymbolersatz
        last if($s=~/\>\*/);
        @f=split(/#/,$s);
        $fx=$f[0];
        if (!defined($fx)) { $fx=''; }# TODO: change this to avoid following unnecessary comparisons/processing
        if($fx=~s/^\-//g)# falls 1.Zeichen in 1.Spalte ="-" ->Hline unterbinden!
            {$f[0]=$fx;$fx="-";}#..Tricki!
        $s=""; foreach $e(@f){$s.="$e&";};chop($s);
        if($fx=~s/^\-//g)# falls 1.Zeichen in 1.Spalte ="-" ->Hline unterbinden!
            { print $OUT "$s $NL \n";}
        else{print $OUT "$s $NL $lin\n";}
        }
    print $OUT "\\end{tabular} \n";
    }


#-----------------------------------------------------
sub print_list  #...z.B.Terminliste bis >* erzeugen
#-----------------------------------------------------
{
    my ($nix,$fixedsize)=split(/#/,$_);
    my($d,$t,$s);
    if (defined $fixedsize)
    {
        print $OUT "\\hspace*{1.4cm}\\begin{minipage}{0.83\\linewidth}\%\n"; # diese minipage sollte gar nicht notwendig sein! warum wird diese print_list verschoben!?       
        print $OUT "\\begin{basedescript}{\\desclabelstyle{\\pushlabel}}\%\n";
        print $OUT "\\desclabelwidth{$fixedsize}\%\n";
        print $OUT "\\setlength{\\labelsep}{1ex}\%\n";
        print $OUT "\\setlength{\\itemindent}{0pt}\%\n";
        print $OUT "\\setlength{\\leftmargin}{0pt}\%\n";
        print $OUT "\\setlength{\\rightmargin}{0pt}\%\n";
    }
    else
    {
        print $OUT "\\begin{description}\n";
        add_list_space();
    }
    while($#TXZ>=0)# sind noch Elemente im Array?
        {
        $s=shift(@TXZ);
        last if($s=~/\>\*/);
        # TODO einfügen, um Kommentare zu ignorieren, ala: next if ($s=~/^\%/); # plus whitespace ignorieren
        $s=replace_characters($s);
        ($d,$t)=split(/#/,$s);
        if (defined $t)
            {
            print $OUT "\\item[$d] $t\n";
            }
        else
            {
            print $OUT "\\item[$d] \n" if (defined $d);                
            }
        }
    if (defined $fixedsize)
    {
        print $OUT "\\end{basedescript}\n";
        print $OUT "\\end{minipage}\n";
        
    }
    else
    {
        print $OUT "\\end{description}\n";
    }
}

#-----------------------------------------------------
sub print_picturecredits#...Einfuegen Bildnachweis
#-----------------------------------------------------
{
    print $OUT "\\renewcommand\\indexname{Bildnachweis}\%\n";
    print $OUT "\\printindex\n";
}

#-----------------------------------------------------
sub print_image_jpg  #...Einfuegen JPG-Bildatei
#-----------------------------------------------------
    {
    my ($nix,$kom,$xf,$dn,$b,$photographer)=split(/#/,$_);
    my ($sx,$dx);
    if($BILDFLG==0){print $OUT "\n{\\Large\\ding\{212\} BILD: $dn.jpg}\\\\\n";return;}# 212 ist ein dicker Rechtspfeil
    if(not -e "$Bpfad/$dn.jpg")
    {
        print $OUT "\n{\\Large\\ding\{212\} Bild \\textbf\{FEHLT\}: $Bpfad/$dn.jpg}\\\\\n";
        print "* Bild fehlt: $Bpfad/$dn.jpg\n";
        return;
    }

    $b=~s/opt/width=.95\\linewidth,keepaspectratio/g;#optimal Ersatz
    $b=~s/t\:/type\=/g;#t=typeersatz
    $b=~s/s\:/scale\=/g;#s=Scalierersatz
    $b=~s/r\:/angle\=/g;#r=Rotierersatz
    $b=~s/rp\:/origin\=/g;#rp=RotierPunktersatz(tl,tc,tr,lc,cc,rc,lB,cB,rB,lb,cb,rb)
    $b=~s/b\:/width\=/g;#b=Breitenersatz
    $b=~s/h\:/height\=/g;#hb=Hoehenersatz
    print $OUT "\\parbox[c]{\\linewidth}{\\center\n";
    print $OUT "\\includegraphics[".$b."]{"."$Bpfad/$dn.jpg}\n";
    if (defined $photographer) { print $OUT "\\index{$photographer}\%\n"; }
    #original: if ($kom){print $OUT "\\centerline{\\emph{".$kom."}}$NL"."[3ex]\n";}
    if ($kom){print $OUT "\\\\ \\textit{".$kom."}"."\n";}
    print $OUT "\\vspace{1.5ex plus 1ex minus 1ex}"."\n";
    print $OUT "}\n";
    }

#-----------------------------------------------------
sub print_background_image_jpg  #...Einfuegen jpg-Hintergrund-Bildatei
#-----------------------------------------------------
    {
    my ($nix,$px,$py,$hx,$bx,$dn)=split(/#/,$_);
    my ($hy,$sx,$dx);
    if($BILDFLG==0){print $OUT "\n{\\Large\\ding\{212\} BILD: $dn.jpg}\\\\\n";return;}
    if(not -e "$Bpfad/$dn.jpg"){print $OUT "\n{\\Large\\ding\{212\} Bild \\textbf\{FEHLT\}: $Bpfad/$dn.jpg}\\\\\n";return;}
    $hy=$hx-1;
    $py-=$hy;
    print $OUT "{\\unitlength=1mm \\begin{picture}(0,0) \\put($px,$py){\\includegraphics["."width=$bx"."mm,height=$hx"."mm]{$Bpfad/$dn.jpg}} \\end{picture}}\n";
    }

#-----------------------------------------------------
sub add_logo_image_jpg  #...Einfuegen jpg- Logo/Icon-Bildatei
#-----------------------------------------------------
    {
    my $s=shift;
    my ($tx1,$nix,$dn,$hx,$tx2)=split(/:/,$s);
    #if(not defined $dn) { $dn = ""; }
    #if(not defined $tx2) { $tx2 = ""; }
    if($BILDFLG==0){print $OUT "\n{\\Large\\ding\{212\} LOGO: $dn.jpg}\\\\\n";return($tx1." ".$tx2." ");}
    if(not -e "$Logopfad/$dn.jpg")
    {
        print $OUT "\n{\\Large\\ding\{212\} Logo \\textbf\{FEHLT\}: $Logopfad/$dn.jpg}\\\\\n";
        print "* Logo fehlt: $Logopfad/$dn.jpg\n";
        return($tx1." ".$tx2." ");
    }
    #return($tx1."\%\n\\includegraphics[height=".$hx."]{$Logopfad/$dn.jpg}\%\n".$tx2." ");
    return($tx1."\\setlength\\intextsep{0pt}\\begin{wrapfigure}{L}{0pt}\%\n\\includegraphics[height=".$hx."]{$Logopfad/$dn.jpg}\%\n\\end{wrapfigure}\%\n".$tx2." ");
    # argh der folgende Text muss noch Bestandteil sein 8-( return($tx1."\\begin{figwindow}[1,1,\%\n\\includegraphics[height=".$hx."]{$Logopfad/$dn.jpg},}\%\n\\end{figwindow}\%\n".$tx2." ");
    }

#-----------------------------------------------------
sub testit #...Existiert MetaZeicheneinleitung?
#----------------------------------------------------
    {
    my $s=shift;
    $s=replace_characters($s);
    if($s =~ /^>/) #1.Zeichen MetaSteuerzeichen?
        {
        evaluate_commands($s);
        }
    else
        {
        print $OUT $ITS.$s."\n";
        }
    }

#-----------------------------------------------------
sub evaluate_commands #...Metazeichenauswertung
#-----------------------------------------------------
    {
    my $s=shift;
    my (@f,$it,$t,$u,$nix);
    chompx(\$s);#UniversalChomp-call by Reference;
    $s=~s/>+//g;
    $_=$s;
    @f=split(/#/,$s);#Argumente->f
    #...Abschnittsberschriften+Def.
    if($f[0] eq "fg") {print $OUT "\\fontsize{".$f[1]."pt}{".$f[2]."pt}\\selectfont\n";return;} #FontGroesse!
    if($f[0] eq "zd")
        {
        if($f[1]>0){$ZD0=$f[1];}else{$ZD0=$ZDM;}
        print $OUT "\\normalbaselines\\linespread{$ZD0}\\selectfont\n";return;
        } #StandardZeilendiche 1=Normal! - falls 0->auf $ZDM setzen 24.5.2007
    if($f[0] eq "tsx") {$TABTXTFLG=$f[1];return;} #Textanhang nach InfoKopftabelle EIN/AUSblenden 25.11.2008
    if($f[0] eq "bsx")#Bildschalter EIN(1) / AUS(0) - 0 -> Bilder werden durch Text ersetzt! 10.6.2008
    {
        #$BILDFLG=$f[1];
        print $OUT "\n% Bildschalter bsx ist obsolete, da PeX prüft, ob Bild da ist oder nicht. Ansonsten Option draft im Kopf von Dokumentenvorlage verwenden.\n";
        print "* Bildschalter bsx ist obsolete, da PeX prüft, ob Bild da ist oder nicht. Ansonsten Option draft im Kopf von Dokumentenvorlage verwenden.\n";
        return; 
    }
    if($f[0] eq "zdm") {$ZDM=$f[1]; $ZD0=$ZDM;return;} #StandardZeilendichte-Memo->wird bei zd#0 als Rücksetzwert genommen! 24.5.2007
    if($f[0] eq "zdi") {$ZDI=$f[1]; return;} #StandardZeilendicheItems 0.5(ex)=Normal!
    if($f[0] eq "zdt") {print $OUT "\\extrarowheight $f[1]\n"; return;} #ExtraZeilenSpace bei Tabellen 2pt
    if($f[0] eq "sdt") {print $OUT "\\setlength{\\tabcolsep}{$f[1]}\n"; return;} #ExtraSpaltenSpace bei Tabellen z.B. 2pt 27.11.2008
    if($f[0] eq "sg") #Schriftgroessen 0..9/ 4=Normal!
    {
        #$f[1]=~s/,/./g;
        if ($f[1] =~ /^[0-9]$/ )
        {
            $SGO=$f[1]+$SGOF; print $OUT $SG[$SGO]."\n";
        }
        else
        {
            print $OUT "% sg ignoriert (Schriftgröße 0..9): $f[1]\n";
        }
        return; 
    }
    if($f[0] eq "sgof") {$SGOF=$f[1];return;} #SchriftgroessenOffset -2,1,0,+1,+2
    if($f[0] =~/tscale/i) {$SCALE=$f[1]; return;} # TabellenSpaltenSkalierungsfaktor
    if($f[0] eq "u") {$u=add_caption($f[1]);print $OUT "$u\n";return;} #Ueberschrift
    if($f[0] eq "k") {$u=add_italic($f[1]);print $OUT "$u\n";return;} #add_italic
    if($f[0] eq "f") {$u=add_bold($f[1]);print $OUT "$u\n";return;} #add_bold
    if($f[0] eq "i") {$u=add_author($f[1]);print $OUT "$u\n";return;} #Autor
    if($f[0] eq "1")
    {
        if ($f[1] =~/^-/) { print $OUT "% section ignoriert (wg. -): $f[1]\n";return; }
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\section{$u} ",$f[2]);return; }
    }
    if($f[0] eq "2")
    {
        if ($f[1] =~/^-/) { print $OUT "% subsection ignoriert (wg. -): $f[1]\n";return; }
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\subsection{$u} ",$f[2]);return;}
    }
    if($f[0] eq "3")
    {
        if ($f[1] =~/^-/) { print $OUT "% subsubsection ignoriert (wg. -): $f[1]\n";return; }
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\subsubsection{$u} ",$f[2]);return;}
    }
    if($f[0] =~/BPFAD/i) {$Bpfad=$f[1]; return;} #Standardjpg-Bildverzeichnis
    #...AbschnittsEnde (LIFO-Stack)
    if($f[0] eq "*")#prüfen ob Nummerierungsblock aktiv?
        {
        $t=pop(@stack);
        if (defined($t))
            {
            if ($t=~/itemize|enumerate|dinglist/){$ITZ--;}
            print $OUT $t."\n";
            }
        if(!defined($ITZ)) {$ITS="";}
        if(!$ITZ) {$ITS="";}
        #print $s."=".$t;<STDIN>;
        return;
        }
    #...man. Seiten bzw. Spaltenwechsel
    if($f[0] eq "+") {print $OUT "\\newpage\n";return;}
    if($f[0] eq "!") {print $OUT "\\columnbreak\n";return;}

    if($f[0] =~/DATEN/i)
        {
        ($nix,$Monat,$Jahr,$AUFLAGE,$Rende)=split(/#/,$s);#globale Daten
        initialize();
        return;
        }
    #if($f[0] =~/BEF/i) {textmakro(@f);return;}
    if($f[0] =~/SPALTEN/i) {print_columns($f[1]);return;}
    if($f[0] =~/NUM/i){print_enumeration();return;}
    if($f[0] =~/PUN/i) {print_itemize();return;}
    if($f[0] =~/SYMBOL/i) {print_dinglist($f[1]);return;}
    #if($f[0] =~/INDEX/i) {bindex();return;}
    #if($f[0] =~/INFOLISTE/i) {infoliste();return;}
    if($f[0] =~/INFOTAB/i) {$Iformat=$f[1];return;}# InfoTab-Tabellenformat ->ArtikelHeader
    if($f[0] =~/LISTE/i) {print_list();return;}
    if($f[0] =~/TABELLE/i) {print_table();return;}
# TODO entfernen:
    if($f[0] =~/TAGTAB/i && $TABTXTFLG==0) {print_table_for_day_init($f[1]);return;}
    if($f[0] =~/BILDNACHWEIS/i) { print_picturecredits(); return; }
    if($f[0] =~/BILD/i) {print_image_jpg();return;}   
    if($f[0] =~/HBILD/i) {print_background_image_jpg();return;}
    if($f[0] =~/INHALT/i)
        { # falls 2. Parameter diesen als Inhaltsüberschrift verwenden 16.10.2009
        if($f[1]){print $OUT "\\def\\contentsname{{\\Large $f[1]}}\\tableofcontents\n\\clearpage";return;}
        else{print $OUT "\\def\\contentsname{\\Large Inhalt\\large\\dotfill $NUMMER/$Jahr}\\tableofcontents\n\\clearpage";return;}
        }
    if($f[0] =~/AUFLAGE/i) {print $OUT "Auflage: $AUFLAGE\n";return;}
    # AUSGABEZEITRAUM mus vor AUSGABE stehen, damit es zuerst passt
    if($f[0] =~/AUSGABEZEITRAUM/i) {print $OUT "$AUSGABEZEITRAUM"; if (defined $f[1]) {print $OUT $f[1];} return;}
    if($f[0] =~/AUSGABE/i) {print $OUT "{\\Large $AUSGABE}";return;}
    if($f[0] =~/RENDE/i) {print $OUT "$RENDE";return;}
    }

#-----------------------------------------------------
sub initialize #...Basisdaten initialisieren
#-----------------------------------------------------
    {
    my @m=qw(null Januar Februar März April Mai Juni Juli August September Oktober November Dezember);
    my $memo;
    my $nj=$Jahr+1;
    $NUMMER=($Jahr-1972)*6+($Monat+1)/2-3;# AusgabenNummernberechnung
    $AUSGABEZEITRAUM=$m[$Monat]."/".$m[$Monat+1]." $Jahr";
    $AUSGABE=$AUSGABEZEITRAUM."\\hfill$NUMMER\n\n";
    $memo=$m[$Monat+1]." ".$Jahr;
    $RENDE='Redaktionsschluss für die nächste Ausgabe: \textbf{'."$Rende. $memo}$NL";
    print "Ausgabe: $AUSGABE\t$Jahr\t\t$NUMMER\n$RENDE\n";
    }

# TODO entfernen
#-----------------------------------------------------
sub print_table_for_day # eine Zeile der Tagesartikel-Gesamttabelle  ausgeben 26.11.2008
#-----------------------------------------------------
    {
    my $titel=shift;
    my (@f,$s,$k,$w,@tab,$l);
    foreach $s (%TTKEY) { if (defined $TTKEY{$s}) {$tab[$TTKEY{$s}]=" ";}}#vorbelegen
    $tab[0]=$titel;
    while($#TXZ>=0)
        {
        $s=shift(@TXZ);# leeren des Zeilenspeichers
        last if $s=~/^\>\*/;# falls >* folgt Abbruch!
        $s=replace_characters($s);
        @f=split(/#/,$s);# 2spaltige Kopftabelle Feld und Inhalt auslesen
        if (defined $f[0])
            {
            $f[0]=~s/ |\-//g;#leerzeichen und - eleminieren!
            if(!$f[0])# falls Feld leer letzem Feld zuordnen
                {$f[0]=$l;} else {$l=$f[0];}
            $tab[$TTKEY{$f[0]}].=" ".$f[1] if (defined($TTKEY{$f[0]}));
            }
        }
    print $OUT ''.join('&',@tab).'\\\\ \hline'."\n";
    }

# TODO entfernen
#-----------------------------------------------------
sub print_table_for_day_init # initialisieren der Tagesartikel-Gesamttabelle 26.11.2008
#-----------------------------------------------------
    {
    my $s=shift;
    my @f=split(/,/,$s);
    my $k=0;
    my ($e,$sn,$br);
    my $format='|';
    my $u;
    $TTKAP=$KAPM; # akt. Kapitel merken
    # my $titel=shift(@f);
    foreach $s (@f)
        {
        $s=~s/ //g;#leerzeiche raus
        if($s){
        ($sn,$br)=split(/=/,$s);#Spaltenname, Spaltenbreite filtern 27.11.2008
        $TTKEY{$sn}=$k;
        $k++;$format.='L{'.$br.'}|';$u.='\emph{'.$sn.'}&';} #Spaltenreihenfolge im Hash festlegen
        }
    print $OUT "\\begin{tabular}{$format}".'\hline'."\n";
    chop($u);
    print $OUT ''.$u.' \\\\ \hline \hline'."\n";
    }

##-----------------------------------------------------
#sub textmakro #...Fett, Kursiv u.v.m man definieren und mit '::?' mitten im Text einbinden (?=beliebiges Zeichen) 23.10.2010
##-----------------------------------------------------
#    {
#    my @f=@_;
#    $BEF{$f[1]}=$f[2];#TextMakro in hash stellen!
#    }
#
#-----------------------------------------------------
sub print_columns #...Spaltenanz setzen
#-----------------------------------------------------
    {
    $SPM=shift;
    push(@stack,"\\end{multicols}\n");
    print $OUT "\\begin{multicols}{$SPM}\n";
    }

#-----------------------------------------------------
sub print_enumeration#...FolgeZeilen durchnummerieren
#-----------------------------------------------------
    {
    $ITZ++;
    $ITS="\\item ";
    push(@stack,"\\end{enumerate}\n");
    print $OUT "\\begin{enumerate}\n";
    add_list_space();
    }

#-----------------------------------------------------
sub print_itemize #...FolgeZeilen durchpunktieren
#-----------------------------------------------------
    {
    $ITZ++;
    $ITS="\\item ";
    push(@stack,"\\end{itemize}\n");
    print $OUT "\\begin{itemize}\n";
    add_list_space();
    }
#-----------------------------------------------------
sub print_dinglist #...FolgeZeilen durchpunktieren mit Symbolen aus pifont
#-----------------------------------------------------
    {
    my $s=shift;
    my $sym;

    $sym=$symbole{$s};
    if(!$sym){$sym=97;}#default = blume
    $ITZ++;
    $ITS="\\item ";
    push(@stack,"\\end{dinglist}\n");
    print $OUT "\\begin{dinglist}{$sym}\n";
    add_list_space();
    }

#-----------------------------------------------------
sub print_alignment #...Zeile rechts,zentriert oder linksbuendig
#-----------------------------------------------------
    {
    my ($s,$p)=@_;
    if (defined $p)
        {
        if ($p eq "l")
           {print $OUT "\\begin{raggedright}\n$s\n\\end{raggedright}\n";return;}
        if ($p eq "r")
           {print $OUT "\\begin{raggedleft}\n$s\n\\end{raggedleft}\n";return;}
        if ($p eq "z")
           {print $OUT "\\begin{centering}\n$s\n\\end{centering}\n";return;}
        }
    print $OUT "$s\n";
    }

#-----------------------------------------------------
sub add_bold #...Zeile hervorheben
#----------------------------------------------------
    {
    my $s=shift;
    my $x=$SGO;
    if ($x<0) {$x=0;}
    return('\textbf{'.$s.'}');
    }
#-----------------------------------------------------
sub add_italic #...Zeile in Kursiv
#----------------------------------------------------
    {
    my $s=shift;
    my $x=$SGO;
    if ($x<0) {$x=0;}
    return('\textit{'.$SG[$x]." ".$s.'}');
    }
#-----------------------------------------------------
sub add_author # Author of article
#----------------------------------------------------
    {
    my $s=shift;
    my $x=$SGO-1;
    if ($x<0) {$x=0;}
    if (!defined($s)) { $s=''; print "* Autor fehlt.\n"; }# TODO add line number or other context
    return('\textit{'.$SG[$x]." ".$s.'}'."\n"."\\bigskip");
    }
#-----------------------------------------------------
sub add_caption #...Ueberschrift erzeugen
#----------------------------------------------------
    {
    my $s=shift;
    $s=~ s/^ +//g;#remove leading space
    # set in bold letter and add some space:
    return('\textbf{~\\\\'."\n".$s.'}'."\n".'\vspace{.5\baselineskip plus 1ex minus 0.5ex}');# TODO \\ wieder entfernen, da nicht robust und nicht variabel.
    }

#-----------------------------------------------------
sub add_hierachical_caption #...Ueberschrift für Hierarchien
#----------------------------------------------------
    {
    my $s=shift;
    $s=~ s/^ +//g;#remove leading space
    return($s);
    }

#-----------------------------------------------------
sub add_list_space #...Zeilendichte für listen-kontext(items)
#----------------------------------------------------
    {
    my $p=$ZDI/2;
    print $OUT "\\setlength{\\itemsep}{$ZDI"."ex}\n";
    print $OUT "\\setlength{\\parsep}{$p"."ex}\n";
    }

#-----------------------------------------------------
sub replace_characters #...Suchen/ersetzen
#----------------------------------------------------
# CP1250: https://secure.wikimedia.org/wikipedia/de/wiki/Windows-1250
# CP1250 -> Unicode: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1250.TXT
    {
    my $s=shift;
    #my $cz;#Counter f. Zeichen 16.10.2009
    #print $OUT "% - testit()=> $s\n";
    if($s =~ /^;/) #1.Zeichen ;=Kommentar->bergehen!
       {return("");}
    if($s !~ /^>/)
        {  # suchen/ersetzen TextMakros 23.10.2010
        while($s =~/(::.)/)
            {
            if($s=~s/(::.)>/$1\{/g){$s.='}';} #::.>  falls Befehl f. ganze restzeile gelten soll einbinden {}
            $s=~s/(::.)/$BEF{$1}/g;
            }
        }
    if($s =~ /:logo:/) #enthaelt Zeile Logo(Grafik)-Einbindung?
        {$s=add_logo_image_jpg($s);}
    $s =~ s/(\d+ *)\%/$1\\\%/gi; #n%  richtig setzen
    $s =~ s/<a href.+<\/a>//gi; #Links richtig setzen
    #...Sonderzeichen TeX-kompatibel ersetzen, egal ob UTF-8 kodiert oder in HTML...
    $s =~ s/\x{2026}|&#x2026;|\.\.\./\\ldots\\ /g; #0x85  0x2026  #HORIZONTAL ELLIPSIS - ...-Zeichen
    $s =~ s/\x{2013}|&#x2013;/--/g;  # 0x96 0x2013 #8211 #EN DASH - falls mittellanges Minus (&#8211;)/langer Gedankenstrick
    $s =~ s/\x{2014}|&#x2014;/---/g; # 0x97 0x2014       #EM DASH - langer Gedankenstrick ---
    $s =~ s/&#164;|\x{20AC}|&#x20AC;/\\euro{}/g; # 0x80  0x20AC #8364 #EURO SIGN 
    #    $value=~s/\x{2022}/&#x2022;/g; # 0x95 0x2022  #BULLET ?
    
    # Einfache Anführungszeichen werden alle umgesetzt auf: 0x29    0x0029  #RIGHT PARENTHESIS
    # 0x82 0x201A  #SINGLE LOW-9 QUOTATION MARK
    # 0x91 0x2018  #LEFT SINGLE QUOTATION MARK
    # 0x92 0x2019  #RIGHT SINGLE QUOTATION MARK
    $s =~ s/\x{201A}|&#x201A;|\x{2018}|&#x2018;|\x{2019}|&#x2019;|&#x0029;/\'/g; #falls ' im Text -> Latex'Ersatz
    
    #...reservierte Latex-Spezialzeichen
#    my $cz=$s=~tr/&/&/;
#    if($cz<2){$s =~ s/\&/\\&/g;} #&  nur Einzel-& ersetzen/sonst Tabelle
    $s =~ s/\§/\\S/g; # Paragraphzeichen
    #...Telefon/Mailsymbole einbauen!
    $s =~ s/Tel.:|Tel:/\\ding\{37\}/ig; #falls Tel.?-> Telefonsymbolersatz
    $s =~ s/e-mail:|email:|mail:/\\ding\{41\}/ig; #falls email.?-> Briefsymbolersatz
    $s=dbquote($s); # falls " oder „/“ im Text -> Latex"Ersatz"
    
    # Doppelte Anführungszeichen
    # hier nun noch wenigstens die Umsetzung nach TeX, auch wenn es in dbquote nicht gepasst hat.
    # So kann sichergestellt werden, dass von \textit{} nicht nur der öffnende oder schließende Teil 
    # eingefügt wird.
    # TODO hier eine Warnung ausgeben, da vermutlich keine Absicht vorliegt?
    $s =~ s/\x{201C}|&#x201C;/\"'/g; # 0x93 0x201C       #LEFT DOUBLE QUOTATION MARK  - Anführungszeichen oben   
    $s =~ s/\x{201D}|&#x201D;/\"'/g; # 0x94 0x201D #8220 #RIGHT DOUBLE QUOTATION MARK - Anführungszeichen oben “
    $s =~ s/\x{201E}|&#x201E;/\"`/g; # 0x84 0x201E #8222 #DOUBLE LOW-9 QUOTATION MARK - Anführungszeichen unten „
    
    return($s);
    }

#-----------------------------------------------------
sub dbquote #...Anfuehrungszeichen ersetzen(Latex), prüft auf " und „/“
#----------------------------------------------------
    {
    my $s=shift;
    # "- sollte nicht ersetzt werden;
    # nur wenn auch das schließende Ende erfasst wird, wird die Ersetzung vorgenommen.
    $s=~s/(^|[ \f\n\r\t\(]+)\"([a-zA-Z0-9ßöäüÖÄÜéè\( ][-a-zA-Z0-9ßöäüÖÄÜéè\(\),\.\?\+\:! ]*?)\"([,\.\)]?[,\.\:\)!]?(\s+|$))/$1\\textit{\\glqq $2\\grqq}$3/g;
    # nun auch für die expliziten Anführungszeichen
    $s=~s/(\x{201E}|&#x201E;)(.*?)(\x{201C}|&#x201C;|\x{201D}|&#x201D;|\")/\\textit{\\glqq $2\\grqq}/g;
    return $s;
    }

sub chompx #...loescht universal(Windows,Dos,Linx-Zeilenvorschub!) sonst: Probleme bei TeX-Konvertierung!
    {
    my $s=shift;
    $$s=~s/\x0a|\x0d//g;
    }

#sub plott_zeilen
#    {
#    my($a,$z);
#    foreach $a (@TXZ){$z++;print "$z\t$a\n";}
#    <stdin>;
#    }

1;

__END__
