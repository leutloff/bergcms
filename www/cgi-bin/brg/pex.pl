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
package BERG::PEX;

use strict;
use warnings;

use IO::File;                      # FileHandel(OO-Generation!)
use Fcntl qw/:flock/;              # LOCK_EX etc. definieren
use PerlIO::encoding;              # Zeichenkodierung ändern können, z.B. beim Wegschreiben 
use utf8;                          # UTF-8 Kodierung auch in regulären Ausdrücken berücksichtigen
use Cwd qw(abs_path);

use vars qw(@EXPORT_OK @ISA $VERSION);

$VERSION = 'v2.09/28.12.2012';
# exports are used for testing purposes
@EXPORT_OK = qw(add_author add_bold add_caption add_italic
                get_tex_content
                replace_characters);
@ISA = qw(Exporter);

# Standardeingabe und Standardausgabe in UTF-8:
binmode(STDIN, ":encoding(utf8)");
binmode(STDOUT, ":encoding(utf8)");

# run() is called, when this script is used as standalone script.
# Otherwise the methods are available from the package.
__PACKAGE__->run(@ARGV) unless caller();

#--- Define the Global Variables --------------------------------------------------
#our $SPM=1;#SpaltenMemo - damit Automatik bei TagGesamtTabellen(=1spaltig) und zurücksetzen funzt!27.11.2008
#our %TTKEY=();#TagTabellenSpalten-Hash init -> GesamtArtikelTabelle 26.11.2008
#our $TTKAP="";#Kapitelspeicher-> Tabellenplot nach Kapitelwechsel! 26.11.2008
#our $TABTXTFLG=1;#ArtikelTagFlag-> 2=komplett 1=NUR InfoKopftabelle(ohne Textanhang 0=ABSCHALTEN(komplett ausblenden->man.Übersichtstabellen einfügen möglich!26.11.2008
our $ITZ=0;#Latex\item-Zähler
our $ITS="";# letztes Metazeichen - wird in testit() ggf. mit ausgegeben, Beispielwert ist \item
#our $TAGM=0;#WochentagsSpeicher->Hirachie->Thema(Kapitel)->Tag(falls Nr=1-7)->Titel
our @TXZ=undef;#globaler Textzeilenspeicher
#our $Iformat="|p{10mm}||p{42mm}|";#InfoTabellenformat->Artikelheader (falls gewünscht ! - unterbinden: 1.Zeile = >*
#our $Bpfad="bilder";#Bilder-Pfad -> *.jpg-Archiv
our $Bpfad="/home/aachen/cgi-bin/brg/br/bilder";#Bilder-Pfad -> *.jpg-Archiv
our $Logopfad="/home/aachen/cgi-bin/brg/br/icons";#Bilder-Pfad -> *.jpg-Archiv
our $SCALE=1.57;#Skalierung festlegen, z.B. bei Tabellen
our $ISSUENUMBER=undef;#Fortlaufende Nummerierung der Gemeindeinformationen
our $ISSUEYEAR=undef;
our $AUSGABEZEITRAUM=undef;#Text der Ausgabe mit Erscheinungsjahr/Erscheinungsmonat; wird im PDF Inhaltsverzeichnis verwendent
our $AUSGABE=undef;#Text mit $AUSGABEZEITRAUM und fortlaufender Nummerierung; Unterschrift der Titelseite
our $AUFLAGE=undef;#Auflagenhöhe
our $Rende=undef;#Datum des Redaktionsschlusses
our $RENDE=undef;#Text zum Redaktionsschluss
#-----SchriftgroessenDef />sg#N#
our $SGO=4;# Standardschriftgröße
our $SGOF=1;#SchriftgroessenOffset
#-----Zeilenabstandsdichte />sg#N#
our $ZDM=1.0;# Standard-Zeilendichte, d.h. bei >zd#0 wird ZDM verwendet.
our $ZDI=0.2;# StandardZeilendichte =0.5ex Items

our @stack = "";# stack holding the closing name of a list - triggered by >*
our $ActualColumsNo = "1";# actual number of columns
our $OUT = undef;# Handle to the resulting output file

#--- Initialize the Global Variables --------------------------------------------------
INIT {
    $ITZ=0;
    $ITS="";
    # TODO: remove path and use TEXINPUTS or use relative path
    $Bpfad="/home/aachen/cgi-bin/brg/br/bilder";
    $Logopfad="/home/aachen/cgi-bin/brg/br/icons";
    $SCALE=1.57;
    $SGO=4;
    $SGOF=1;
    $ZDM=1.0;
    $ZDI=0.2;

    @stack = "";
    $ActualColumsNo = "1";
}

#** @function
#-----Start (Main)-----------
#*    
sub run
{
    my $inp = "";# Filename for the input
    my $OUPTEX = "";# Filename for the output
    
    $inp = $ARGV[0];
    if (!$inp) { $inp="feginfo.csv"; }
    $inp = abs_path($inp);
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
    $OUPTEX = abs_path($OUPTEX);
    die "Fehler: Input- ($inp) und Outputdatei ($OUPTEX) dürfen nicht gleich sein!" if ($OUPTEX eq $inp);      
    #my $OUT=IO::File->new(">$OUPTEX");
    open($OUT, ">:encoding(utf8)", $OUPTEX) or die "Die Ausgabedatei $OUPTEX kann nicht geöffnet werden.";

    print_version($inp, $OUPTEX);
    my %idx = load_database($inp);
    create_tex_file($OUPTEX, \%idx);
}

#** @function
# Prints the Version into the TeX file and on standard output.
# @param $inputfilename the file used as input database.
# @param $outputfilename the generated TeX file.
#*
sub print_version
{
    my($inputfilename, $outputfilename) = @_;
    my $msg = 'Programm: '.abs_path($0).", $VERSION (Perl $]), DB($inputfilename) => LaTeX($outputfilename) [".scalar localtime()."]\n";
    print $OUT '%'." $msg";
    print "$msg";
}

#** @function
# Loading and parsing the input database. Store the articles for further processing into an hast.
# Articles with negative numbers are ignored.
# @params $inp the file used as input database.
# @retval hash with the content used for further processing.  
#*
sub load_database
{
     my($inp) = @_;
    my (@f,$k,$s,$PIN);
    my %idx = ();
    my $LIM="\x09";
    open($PIN, "<:encoding(utf8)", $inp);   
    if(defined $PIN) {;} else {die  "Fehler beim Öffnen von $inp!";}
    flock($PIN, LOCK_SH) || die("\nFehler: Konnte die Datei $inp nicht zum Lesen sperren (load_database)!\n");
    print "\nDie Datenbank [$inp] wird eingelesen...\n";
    while (<$PIN>)
    {
        chompx(\$_);#UniversalChomp-call by Reference
        @f=split(/$LIM/,$_);
        next if ($f[2] !~ /^[0-9-+]*$/ || $f[2]<0);# Texte mit Nr.<0 oder keiner Zahl direkt ausblenden!
        $k=$f[1].$LIM.$f[2].$LIM.$f[3].$LIM.$f[0];# Sort by Key=chapter+number+title+articleindex
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
    flock($PIN, LOCK_UN) || print "\nFehler: Konnte die Lesesperre der Datei $inp nicht entfernen (load_database).\n";
    $PIN->close();
    return %idx;
}

#** @function
# Returns a string with the content of the TeX document. The output is generated 
# from the given hash with the content. This is the same as when writing to file.
# @params idx with the content to return as TeX document.
# @retvals the TeX document that appears normally in the TeX file.
#*
sub get_tex_content
{
    my %idx = %{shift()};
    my $result = '';
    open($OUT, ">:encoding(utf8)", \$result) or die 'Die Ausgabe in eine temporäre Variable konnte nicht geöffnet werden (get_tex_content).';
    create_tex_file('Temporäre Variable', \%idx);
    $OUT->close();
    $OUT = undef;
    return $result;
}

#** @function
# Generates the TeX file from the given hash with the content.
# @params idx with content to write into the TeX file.
#*
sub create_tex_file
{
    my $OUPTEX = shift();
    my %idx = %{shift()}; 	
  	if(!defined $OUT) { die "Fehler: Die Ausgabedatei '$OUPTEX' wurde nicht geöffnet (create_tex_file)."; }
  	
    my ($k,$kap,$tnr,$titel,$typ,$text);
    my $LIM="\x09";
    my $KAPM = $LIM;# initialize with an invalid value # "Kapitel";#Kapitelspeicher->Hirachie->Thema(Kapitel)->Tag(falls Nr=1-7)->Titel
    $ActualColumsNo = 1;
    my $zz = 0;
    my $lines = 0;
    #my @WTG= qw(nix Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);#-----WochentagDef s. INFOLISTE TODO remove
    print  "\nDas TeX-Dokument [$OUPTEX] wird erzeugt ...\n";
    foreach $k (sort keys %idx)
    {
        ($kap,$tnr,$titel,$typ,$text)=split(/$LIM/,$idx{$k});
        @TXZ=split(/<br>/,$text);# Textblock in Zeilenspeicher!
        my ($nix0,$nix1,$nix2,$ai)=split(/$LIM/,$k);
        $zz++;
        
        $lines = 1 + $#TXZ;
        print "$zz\t[AI:$ai]\t$kap ($tnr)\t$titel\t$typ\t$lines\n";
        # todo: hier verweis auf den artikel ausgeben - besser in maker link ergänzen
        # print_article_content();

        #if ($typ eq "A") # Artikel->Hierachie-Management.............Kapitel,Wochentag,Titel    
        if ($typ =~ /[AF][123]?/)
        {
            if (length($typ) > 1)
            {
                print_columns(substr($typ, 1, 1));
            }
            if($KAPM ne $kap)# start new chapter?
            {
                $KAPM=$kap;
                print $OUT "% Neues Kapitel: $KAPM\n";
                my ($x,$ueber)=split(/\:/, $kap, 2);
                if (!defined($ueber)) { $ueber = $x; }
                testit(">1#".$ueber."#x");#section generieren
            }
            if(length($titel)>=2){ testit(">2#".$titel."#x"); }#subsection generieren
#           shift(@TXZ);# 1. Dummyzeile entfernen!
        }
        # Resttextzeilen interpretieren/generieren
        my $s = '';
        while(0 <= $#TXZ)
        {
            $s=shift(@TXZ);
            testit($s);
        }
    }
    print_columns('1');# ensure \end{multicols} if necessary.    
}

# #TODO entfernen:
# #-----------------------------------------------------
# sub create_infotab  #...Artikel-Kopftabelle generieren!
# #-----------------------------------------------------
#     {
#     my ($hl,@f,$s,$format);
#     $format=$Iformat;
#     if($SCALE){$format=~ s/([0-9.]+)/sprintf("%1.1f",$1 * $SCALE) /ge; }# TabellenSpaltenSkalierung!
#     $hl="";
#     if($format=~/\|/)# Vertikallinien im TabFormat?->Horizontallinie
#           {
#           $hl="\\cline{1-2}\n";
#           }
#     print $OUT " \\begin{tabular}{$format}$hl";
#     while($#TXZ>=0)
#         {
#         $s=shift(@TXZ);# leeren des Zeilenspeichers
#         last if $s=~/^\>\*/;# falls >* folgt abbruch!
#         $s=~ s/Tel.:|Tel:/\\ding\{37\}/g; #falls Tel.?-> Telefonsymbolersatz
#         $s=~ s/e-mail:|email:|mail:/\\ding\{41\}/ig; #falls email.?-> Briefsymbolersatz
#         @f=split(/#/,$s);
#         my $fx=$f[0];
#         if($fx=~s/^\-//g)# falls 1.Zeichen in 1.Spalte ="-" ->Hline unterbinden
#               { print $OUT "$fx&$f[1]\\\\\n";}
#         else {print $OUT "$fx&$f[1]\\\\$hl\n";}
#         }
#     print $OUT "\\end{tabular} \\\\ [1.5ex]\n";
#     }



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
    chop($s);print $OUT "$s \\\\ $lin $lin\n";
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
            { print $OUT "$s \\\\ \n";}
        else{print $OUT "$s \\\\ $lin\n";}
        }
    print $OUT "\\end{tabular}\n";
    }


#-----------------------------------------------------
sub print_list  #...z.B.Terminliste bis >* erzeugen
#-----------------------------------------------------
{
    my ($nix,$fixedsize)=split(/#/,$_);
    my($d,$t,$s);
    if (defined $fixedsize)
    {
        print $OUT "\\hspace*{1.4cm}\\begin{minipage}{0.83\\linewidth}\%\n"; # TODO diese minipage sollte gar nicht notwendig sein! warum wird diese print_list verschoben!?       
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
    #original: if ($kom){print $OUT "\\centerline{\\emph{".$kom."}}\\\\"."[3ex]\n";}
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

#** @function
# Evaluate and execute the PeX commands. They are all starting with a greater sign ('>').
#*
sub evaluate_commands
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
        #StandardZeilendiche 1=Normal! - falls 0->auf $ZDM setzen
        my $ZD0;
        if($f[1]>0){$ZD0=$f[1];}else{$ZD0=$ZDM;}
        print $OUT "\\normalbaselines\\linespread{$ZD0}\\selectfont\n";return;
    }
    if($f[0] eq "tsx")
    {
        report_warning('Schalter tsx ist obsolete, da Textanhang nicht mehr unterstützt wird.');
        return;
    }
    if($f[0] eq "bsx")
    {
        report_warning('Bildschalter bsx ist obsolete, da PeX prüft, ob Bild da ist oder nicht. Ansonsten Option draft im Kopf von Dokumentenvorlage verwenden.');
        return; 
    }
    if($f[0] eq "zdm") {$ZDM=$f[1]; return;} #StandardZeilendichte-Memo->wird bei zd#0 als Rücksetzwert genommen!
    if($f[0] eq "zdi") {$ZDI=$f[1]; return;} #StandardZeilendicheItems 0.5(ex)=Normal!
    if($f[0] eq "zdt") {print $OUT "\\extrarowheight $f[1]\n"; return;} #ExtraZeilenSpace bei Tabellen 2pt
    if($f[0] eq "sdt") {print $OUT "\\setlength{\\tabcolsep}{$f[1]}\n"; return;} #ExtraSpaltenSpace bei Tabellen z.B. 2pt
    if($f[0] eq "sg") #Schriftgroessen 0..9/ 4=Normal!
    {
        if ($f[1] =~ /^[0-9]$/ )
        {
            $SGO=$f[1]+$SGOF; 
            print $OUT get_fontsize($SGO)."\n";
        }
        else
        {
            report_warning("sg ignoriert (Schriftgröße 0..9): $f[1]");
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
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\section{$u}", $f[2]);return; }
    }
    if($f[0] eq "2")
    {
        if ($f[1] =~/^-/) { print $OUT "% subsection ignoriert (wg. -): $f[1]\n";return; }
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\subsection{$u}", $f[2]);return;}
    }
    if($f[0] eq "3")
    {
        if ($f[1] =~/^-/) { print $OUT "% subsubsection ignoriert (wg. -): $f[1]\n";return; }
        else { $u=add_hierachical_caption($f[1]);print_alignment("\\subsubsection{$u}",$f[2]);return;}
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
		my $Monat=undef;#Erscheinungsmonat
        ($nix,$Monat,$ISSUEYEAR,$AUFLAGE,$Rende)=split(/#/,$s);#globale Daten
        initialize_issue_information($Monat,$ISSUEYEAR);
        return;
    }
    if($f[0] =~/SPALTEN/i) { print_columns($f[1], join('#', @f[2..$#f])); return; }
    if($f[0] =~/NUM/i){print_enumeration();return;}
    if($f[0] =~/PUN/i) {print_itemize();return;}
    if($f[0] =~/SYMBOL/i) {print_dinglist($f[1]);return;}
    #if($f[0] =~/INFOTAB/i) {$Iformat=$f[1];return;}# InfoTab-Tabellenformat ->ArtikelHeader
    if($f[0] =~/LISTE/i) {print_list();return;}
    if($f[0] =~/TABELLE/i) {print_table();return;}
# TODO entfernen:
#    if($f[0] =~/TAGTAB/i && $TABTXTFLG==0) {print_table_for_day_init($f[1]);return;}
    if($f[0] =~/TAGTAB/i) { report_warning('>TAGTAB wird nicht mehr unterstützt.');return;}
    if($f[0] =~/BILDNACHWEIS/i) { print_picturecredits(); return; }
    if($f[0] =~/BILD/i) {print_image_jpg();return;}   
    if($f[0] =~/HBILD/i) {print_background_image_jpg();return;}
    if($f[0] =~/INHALT/i) 
    {  
        # falls 2. Parameter diesen als Inhaltsüberschrift verwenden
        if($f[1]){print $OUT "\\def\\contentsname{{\\Large $f[1]}}\\tableofcontents\n\\clearpage";return;}
        else{print $OUT "\\def\\contentsname{\\Large Inhalt\\large\\dotfill $ISSUENUMBER/$ISSUEYEAR}\\tableofcontents\n\\clearpage";return;}
    }
    if($f[0] =~/AUFLAGE/i) {print $OUT "Auflage: $AUFLAGE\n";return;}
    # AUSGABEZEITRAUM mus vor AUSGABE stehen, damit es zuerst passt
    if($f[0] =~/AUSGABEZEITRAUM/i) {print $OUT "$AUSGABEZEITRAUM"; if (defined $f[1]) {print $OUT $f[1];} return;}
    if($f[0] =~/AUSGABE/i) {print $OUT "{\\Large $AUSGABE}";return;}
    if($f[0] =~/RENDE/i) {print $OUT "$RENDE";return;}
}

#** @function 
# Initialize some values regarding the issue, e.g. the number of the issue.
#*
sub initialize_issue_information
{
    my $Monat=shift;
    my $Jahr=shift;    	
    my @m=qw(null Januar Februar März April Mai Juni Juli August September Oktober November Dezember Januar);
    my $memo;
    my $nj=$Jahr+1;
    $ISSUENUMBER=($Jahr-1972)*6+($Monat+1)/2-3;# AusgabenNummernberechnung
    $AUSGABEZEITRAUM=$m[$Monat]."/".$m[$Monat+1]." $Jahr";
    $AUSGABE=$AUSGABEZEITRAUM."\\hfill$ISSUENUMBER\n\n";
    $memo=$m[$Monat+1]." ".$Jahr;
    $RENDE='Redaktionsschluss für die nächste Ausgabe: \textbf{'."$Rende. $memo}\\\\";
    print "Ausgabe: $AUSGABE\t$Jahr\t\t$ISSUENUMBER\n$RENDE\n";
}

# # TODO entfernen
# #-----------------------------------------------------
# sub print_table_for_day # eine Zeile der Tagesartikel-Gesamttabelle  ausgeben
# #-----------------------------------------------------
#     {
#     my $titel=shift;
#     my (@f,$s,$k,$w,@tab,$l);
#     foreach $s (%TTKEY) { if (defined $TTKEY{$s}) {$tab[$TTKEY{$s}]=" ";}}#vorbelegen
#     $tab[0]=$titel;
#     while($#TXZ>=0)
#         {
#         $s=shift(@TXZ);# leeren des Zeilenspeichers
#         last if $s=~/^\>\*/;# falls >* folgt Abbruch!
#         $s=replace_characters($s);
#         @f=split(/#/,$s);# 2spaltige Kopftabelle Feld und Inhalt auslesen
#         if (defined $f[0])
#             {
#             $f[0]=~s/ |\-//g;#leerzeichen und - eleminieren!
#             if(!$f[0])# falls Feld leer letzem Feld zuordnen
#                 {$f[0]=$l;} else {$l=$f[0];}
#             $tab[$TTKEY{$f[0]}].=" ".$f[1] if (defined($TTKEY{$f[0]}));
#             }
#         }
#     print $OUT ''.join('&',@tab).'\\\\ \hline'."\n";
#     }

# # TODO entfernen
# #-----------------------------------------------------
# sub print_table_for_day_init # initialisieren der Tagesartikel-Gesamttabelle
# #-----------------------------------------------------
#     {
#     my $s=shift;
#     my @f=split(/,/,$s);
#     my $k=0;
#     my ($e,$sn,$br);
#     my $format='|';
#     my $u;
#     $TTKAP=$KAPM; # akt. Kapitel merken
#     # my $titel=shift(@f);
#     foreach $s (@f)
#         {
#         $s=~s/ //g;#leerzeiche raus
#         if($s){
#         ($sn,$br)=split(/=/,$s);#Spaltenname, Spaltenbreite filtern 27.11.2008
#         $TTKEY{$sn}=$k;
#         $k++;$format.='L{'.$br.'}|';$u.='\emph{'.$sn.'}&';} #Spaltenreihenfolge im Hash festlegen
#         }
#     print $OUT "\\begin{tabular}{$format}".'\hline'."\n";
#     chop($u);
#     print $OUT ''.$u.' \\\\ \hline \hline'."\n";
#     }

#** @function
# Changing the number of columns. Output is only generated when the number is 
# different from the actually used number of columns.
# @params the number of desired columns.
# @params further parameter output as comment
#*
sub print_columns
{
    my ($colums, $pexcomment) = @_;
    if (!defined($colums) || ('' eq $colums)) 
    {
        report_warning('Nur 1, 2 oder 3 Spalten sind erlaubt. Die Anweisung wird ignoriert, da die Spaltenanzahl fehlt (print_columns 1).');
        return;
    }   
    chompx(\$colums);
    #TODO rmove print $OUT '%print_columns: '.$colums."\n";
    my ($cols, $percentcomment) = split(/\\\%|\%/, $colums, 2);
    $cols = trim($cols);
    if (('1' eq $cols) || ('2' eq $cols) || ('3' eq $cols))
    {
        if ($cols ne $ActualColumsNo)
        {
            if (!defined($pexcomment)) { $pexcomment = ''; } 
            if (!defined($percentcomment)) { $percentcomment = ''; }
            if (('' ne $pexcomment) && ('' ne $percentcomment)) { $pexcomment = '#'.$pexcomment; }
            if ('1' ne $ActualColumsNo) 
            {
                print $OUT '\end{multicols}%'.$percentcomment.$pexcomment."\n"; 
            }
            if ('1' ne $cols) 
            { 
                print $OUT '\begin{multicols}{'.$cols.'}%'.$percentcomment.$pexcomment."\n"; 
            }
            $ActualColumsNo = $cols;
        }
    }
    else
    {
        if ('' eq $cols) 
        {
            report_warning('Nur 1, 2 oder 3 Spalten sind erlaubt. Die Anweisung wird ignoriert, da die Spaltenanzahl fehlt (print_columns 2).');
        }
        else
        {
            report_warning('Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'$cols'".' Spalten wird ignoriert (print_columns).');
        }
    }
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

    # TODO: make the following static!? and l18n
    my %symbole=();#Symbolhash aus pifont
    $symbole{"brief"}=41;
    $symbole{"telefon"}=37;
    $symbole{"blume"}=96;
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

#** @function
# Determines the name of the numeric font size.
# @param font size 0..9 
# @retvals the name of the numeric font size.
sub get_fontsize
{
    my $x=shift;
    if (!defined($x) || (0 > $x)) { $x=0; }
    my @SG=qw(\\tiny \\scriptsize \\footnotesize \\small \\normalsize \\large \\Large \\LARGE \\huge \\Huge);
    if ($#SG < $x) { $x = $#SG; }
    return $SG[$x];    
}

#-----------------------------------------------------
sub add_bold #...Zeile hervorheben
#----------------------------------------------------
    {
    my $s=shift;
    return('\textbf{'.$s."\n".'}');
    }
#-----------------------------------------------------
sub add_italic #...Zeile in Kursiv
#----------------------------------------------------
    {
    my $s=shift;
    my $x=get_fontsize($SGO);
    return('\textit{'.$x.' '.$s."\n".'}');
    }
    
#** @function
# Author of article. Implement command >i#.
#*
sub add_author
{
    my $s=shift;
    if (!defined($s)) { $s=''; report_warning('Autor fehlt.'); }# TODO add line number or other context
    my $x=get_fontsize($SGO-1);
    return('\textit{'.$x.' '.$s."\n".'}'."\n"."\\bigskip");
}

#-----------------------------------------------------
sub add_caption #...Ueberschrift erzeugen
#----------------------------------------------------
    {
    my $s=shift;
    $s=~ s/^ +//g;#remove leading space
    # set in bold letter and add some space:
    return('\textbf{~\\\\'."\n".$s."\n".'}'."\n".'\vspace{.5\baselineskip plus 1ex minus 0.5ex}');# TODO \\ wieder entfernen, da nicht robust und nicht variabel.
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
    #print $OUT "% - testit()=> $s\n";
    if($s =~ /^;/) #1.Zeichen ;=Kommentar->bergehen!
       {return("");}
#    if($s !~ /^>/)
#        {  # suchen/ersetzen TextMakros 23.10.2010
#        while($s =~/(::.)/)
#            {
#            if($s=~s/(::.)>/$1\{/g){$s.='}';} #::.>  falls Befehl f. ganze restzeile gelten soll einbinden {}
#            $s=~s/(::.)/$BEF{$1}/g;
#            }
#        }
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

#** @function 
# Removes any line feed and carriage return character.
# This avoids problems with TeX later on.
#*
sub chompx
{
    my $s=shift;
    $$s=~s/\x0a|\x0d//g;
}

#** @function 
# Removes white space from the beginning and end of the given string.
# @param string to trim
# @retvals the input string without white space at the beginning or end. 
#*
sub trim 
{
    (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;        
}


#sub print_article_content
#    {
#    my($a,$z);
#    foreach $a (@TXZ){$z++;print "$z\t$a\n";}
#    <stdin>;
#    }

#** @function 
# Reports a warning message to stdout and to the TeX file.
# @params msg Message that send to stdout and to the TeX file.
#*
sub report_warning
{
    my $msg=shift;
    print $OUT '% '.$msg."\n";
    print "* $msg\n";
}

1;

__END__
