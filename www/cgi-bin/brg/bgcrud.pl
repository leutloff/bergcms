#!/usr/bin/perl
#############################################################################
#
# CRUD companion to berg.pl. CRUD means Create, Reload, Update and
# Delete of the articles in the flat file database (.csv).
#
# (c) 2006-2011 Heiko Decker
# (c) 2011-2014 Christian Leutloff
# 
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
#############################################################################

use strict;
use warnings;

# Pfad mit Modulen ergänzen, z.B. für Algorithm::Merge
use FindBin;                       # locate this script
use lib qw($FindBin::Bin/perl5);   # path to Algorithm::Merge

use CGI qw/:standard :html4/;      # Standard CGI Functions
use CGI::Carp qw(fatalsToBrowser); # Show fatal errors in the browser and not only as Internal Server Error
use Fcntl qw/:flock :seek/;        # define LOCK_EX, SEEK_SET etc. 
use PerlIO::encoding;              # Change character encoding when desired, e.g. when writing back to disk 
use utf8;                          # UTF-8 character encoding is recognize in regular expressions, too.
use Encode;                        # decode von param von CPI.pm (empfohlen von http://search.cpan.org/dist/CGI/lib/CGI.pm)
use Symbol 'qualify_to_ref';       # Übergabe eines Filehandles ermöglichen
use Cwd;
use IO::Compress::Gzip qw/gzip $GzipError/; # Ermöglicht ein komprimiertes Backup 
use IO::File;                      # Dateifunktion, auch für Backup 
use Algorithm::Merge qw(merge);    # Merge von drei Texten

# Standard Input and Standard Output is UTF-8:
binmode(STDIN, ":encoding(utf8)");
binmode(STDOUT, ":encoding(utf8)");


#--- GlobalSet ---
my $VERSION="v2.10, 23.02.2014";
my $Neuflg;# falls  ? in Select-Listen wird Auswahlliste für Neueingabe unterdrückt!
my $Sftz=',';# Select-Listen-Feldtrenner
my $SPATH=defined ($ENV{'SCRIPT_FILENAME'}) ? $ENV{'SCRIPT_FILENAME'} : $ENV{'PATH_TRANSLATED'}.$ENV{'SCRIPT_NAME'};#ScriptPfad - SCRIPT_FILENAME Ersatz bei Mini Java CgiHandler 0.2
$SPATH=~s/bgcrud.pl//g;
my $TIDP=$SPATH."tidx/";#Pfad für Transaktionsdateien (Puffer/Zwischenspeicher) muss angelegt werden!
my $FDaten;#POST-Formulardaten-Speicher!
my $self=$ENV{'REQUEST_URI'} || (defined($ENV{'SCRIPT_NAME'}) ? $ENV{'SCRIPT_NAME'}.'?'.$ENV{'QUERY_STRING'} : undef) || $0;#eigene Adresse - REQUEST_URI wird bei dem Perl-Test-Web-Server nicht gesetzt
my $refer=$ENV{'HTTP_REFERER'};#Aufruf-URL

# Database Format and related:
my $dbfile = "";# Name and Path of the selected DB file
my $lim = "\t";# fields in the Database are separated by a TAB
#             a          b       c      d     e   f        g         h       i
my $felder = "Artikel-ID,Kapitel,Nummer,Titel,Typ,Kopftext,Haupttext,Fußtext,TSID";

my $headline;
my ($LCrud,$Crud,$Aw)=("","1R","");#
my $Secl = "u_ c_ d_<br>F:A<br>M:F(3,w)<br>M:G(10,w,virtual)<br>M:H(3,w)<br>S:C(?,-1=INAKTIV,1=Mo,2=Di,3=Mi,4=Do,5=Fr,6=Sa,7=So)<br>S:E(A=Artikel,F=Fixtext,K=Konfiguration)<br>F:I(?ts / ?id)";
my %Formular=();
my %Formsort=();
#my ($tst,$x,$l);
my $Satz;# enthält die Daten aus dem Formular
my $ai = hidden(
        '-name' => 'AI'
        );#--- FormularSet ---
my %Liste=();
my $REMOTEID=(defined($ENV{'REMOTE_ADDR'})?$ENV{'REMOTE_ADDR'}:'127.0.0.1').':'.(defined($ENV{'REMOTE_PORT'})?$ENV{'REMOTE_PORT'}:'-');# IP:Port des Aufrufers


if (defined param('AW'))
    {
    $Aw = param('AW');
    }

my $TIDX;#TransaktionsID 
if (defined param('TIDX') || defined param('CLR'))
    {
    $TIDX = defined param('TIDX') ? param('TIDX') : param('CLR');
    }
else
    {
    do
    	{
        $TIDX = "X".substr(rand(1),2,15);#TransaktionsID GENERIEREN
    	}
    while -e $TIDP.$TIDX.".txt";     
    }
if (defined param('AI'))
    {
    if (param('AI')!~/\d+/) { print_error_page("Bei Parameter AI sind nur Ziffern erlaubt!"); }    
    }
        
#----> Bearbeitung abbrechen---------------------------
# Ersatz für clr.cgi (CLR temp Datei+ anschl. URL Weiterleitung)
if (defined param('CLR')) 
    {
    my $fclr = param('CLR');
    my $tidxpattern = '^X\d{1,15}$';#  prüfen, damit wirklich nur TIDX gelöscht werden
    if ($fclr!~m&$tidxpattern&) { print_error_page("Zu löschende Datei ($fclr) entspricht nicht dem erwarteten Muster ($tidxpattern)! Bitte diesen Fehler berichten."); }
    $fclr = $TIDP.$fclr.".txt";
    unlink($fclr) || warn "$fclr kann nicht entfernt werden!";#löschen tmp-Datei
    print redirect(get_view_link());# Abschluß
    exit 1;
    }



get_db_info($Aw);
if (defined param('LCRUD')) {$Crud=param('LCRUD');}
#print_error_page($refer."...".$self);

if($ENV{'CONTENT_LENGTH'})
    {
    get_form(); #Post-Daten in Formularhash
    }
my $Ok = submit(
        '-name' => 'Submit',
        '-width' => '20',
        '-value' => 'OK!');

#----> Übergabe-Parameter (HauptDatenSatz)---------------------------

if($Crud =~/^1R/)
    {
    get_data($dbfile,$lim,$felder);#Daten werden komplett in den Formular-Hash geladen!
    create_form("",$Ok,$self);#Formular wird aus Hash generiert!
    }
elsif(($Crud =~/^2U/) || ($Crud =~/^3C/) || ($Crud =~/^4D/) || ($Crud =~/^5C/) || ($Crud =~/^6D/))
    {
    put_data($Crud);#Bei einem Konflikt wird hier create_form direkt aufgerufen, um eine Nacharbeit zu ermöglichen
    }

######################################################################
# returns link to the previous view
######################################################################
sub get_view_link
{
    my $viewLink = '/cgi-bin/brg/berg.pl'.'?AW='.(defined param('AW') ? param('AW') : 'berg');
    if(defined param('VFI')){ $viewLink .= '&VFI='.param('VFI');}
    if(defined param('VPI')){ $viewLink .= '&VPI='.param('VPI');}
    if(defined param('FI')) { $viewLink .= '&FI='.param('FI');}
    return replace_umlauts($viewLink);
}

######################################################################
# returns CLR link
######################################################################
sub get_clr_link
{
    my $CLR='/cgi-bin/brg/bgcrud.pl?'.get_view_link()."&CLR=".$TIDX."";# es werden vor Abbruch von bgcrud.pl temp. TID-Datei gelöscht!
    return $CLR;	
}

######################################################################
sub create_form          # Formular aus Basis- und Quell-Tabellendaten generieren
######################################################################
    {
    my ($msg,$Ok,$aktion) = @_;
    my ($feld,$fwert,$wert,$fx,$ftype,$xtype,$nix,$fdefault,@fx,$sela,$tlg,$rows,@rw,$rwflg,@dl);
    my $fz=0;#Feldzähler für Feldsperre
    my $czchr;#FeldCopyFeldzuASCI-Code - C: analog zu F: - jedoch OHNE Feldsperre 17.6.2010
    my $fzchr;#FeldsperreFeldzuASCI-Code
    my $szchr;#SelectionFeldzuASCI-Code
    my $mzchr;#MultilineFeldzuASCI-Code
    my $wrap="virtual";
    my $maxtxt=100;#max.Anzeige-TextFeldbreite
    print header('-charset' => 'utf-8'), 
          start_html('-title'     => $headline, 
                     '-style'     => {'src'=>"/brg/css/bgcrud.css"},
                     '-encoding'  => 'utf-8',
                     '-lang'      => 'de');
    #if ($msg=~/(fehler:|ok!)/i) {print h3($msg), '<a href="'.$home.'">weiter...</a><p></p>';return;}
    print  h4($msg);
    print '<form name="editArticle" action="'.$aktion.'" method=post'.">\n";
    print '<h3>'.$headline.'</h3>'.'<table>'."\n";
    #print "<th><b>$title</b></th><td>$LCrud $Ok $pmemo</td></tr>\n";
    #print "<tr><th><b>$headline</b></th></tr>\n";
    foreach $fx (sort keys %Formsort)
        {
        $feld=$Formsort{$fx};
        $fwert=$Formular{$feld};#akt. Feldwert merken 26.5.2009
        $fz++;
        $sela="";
        $czchr="C:".chr($fz+64);#Copy Felder ermitteln 17.6.2010
        $fzchr="F:".chr($fz+64);#gesperrte Felder ermitteln
        $szchr="S:".chr($fz+64);#Selection-Felder emitteln (Auswahl nach Vorgaben)
        $mzchr="M:".chr($fz+64);#Multiline-Felder emitteln (Auswahl nach Vorgaben)
        if($Secl=~/$fzchr/||$Secl=~/$czchr/||$LCrud=~/00/)#Feldsperre/copy und/oder Defaultwert?
            {
            $ftype="readonly=\"readonly\"";
            if($Secl=~/$czchr/){$ftype="";$fzchr=$czchr;}#falls Copy=>Nurlesestatus aufheben! 17.6.2010
            ($nix,$nix)=split(/$fzchr\(/,$Secl);#falls Default-Feldwert(...)
            if($nix){($fdefault)=split(/\)/,$nix); $Formular{$feld}=$fdefault;}
            }
        else{$ftype="";}
        $rows=1;
        if($Secl=~/$mzchr/)#MultilineFeld?
            {
            ($nix,$nix)=split(/$mzchr\(/,$Secl);#Anzahl Zeilen(N)
            if($nix){($nix)=split(/\)/,$nix);}
            $wrap="off";
            ($rows,$rwflg,$wrap)=split(/,/,$nix);#Zeilen,Readonly(Gesperrt='r') oder Schreibbar('w'),wrap-Modus=off,virtual,physical?
            if (!defined($wrap)) {$wrap='virtual';}
            #if($wrap!~/virtual|physical/i){$wrap="off";}
            if($rwflg=~/r/||$LCrud=~/00/){$ftype="readonly=\"readonly\"";}     else{$ftype="";}
            }
        if($Secl=~/$szchr/)#Selektionsfeld (Vorbelegung/Auswahl)?
            {
            ($nix,$nix)=split(/$szchr\(/,$Secl);#Plausibereich(...)
            ($fdefault)=split(/\)/,$nix);
            @dl=split(/$Sftz/,$fdefault);
            if($dl[0] eq "?")# globales Flag auf Neu setzen - >hebelt Auswahlliste aus! 26.5.2009
                {
                $Neuflg=" neu!";
                shift(@dl);
                }  else {$Neuflg="";}
            if($fdefault=~/!d/) # Select mit Datumliste  füllen 12.9.2008
                {
                $fdefault=get_date_list($dl[1],$dl[2],$dl[3],$fwert);  # Modus 1-4, Azahl(ab heute), Feltrenner
                }
            if($fdefault=~/!z/) # Select mit Ziffernliste füllen 12.9.2008
                {
                $fdefault=get_number_list($dl[1],$dl[2],$dl[3],$dl[4],$fwert);  # Breite,Start,Ende,INC
                }
            if($fdefault=~/!f/) # Select mit UniqueFeldInhaltsliste(DB)  füllen 15.5.2009
                {
                $fdefault=get_field_list($fz,$fwert);
                }
            $sela=get_select($fx,$fdefault,$Formular{$feld});
            }
##############################################
        $wert=$Formular{$feld};
        if(!$wert){$wert=" ";}# Falls LEER->1xSpace, da sonst Lawine von Warnungen im error.log(apache) wegen uninitialized
        $wert=~s/\<br\>/\x0a/g;#LF aus <br> erzeugen
        $wert=escapeHTML($wert);# obige Umsetzungen ersetzt, z.B. wird aus '<' '&lt;'
        $wert=check_value($wert);
        if($wert=~/\x0a/||$rows>1)# LF ?->Mehrzeilenfeld!
            {
            @rw=split(/\x0a/,$wert);# LF?
            if($rows<$#rw){$rows=$#rw+2;}#Anzahl LFs + 2
            print "<tr><th> ".replace_umlauts($feld)." </th><td><textarea".' cols="'.$maxtxt.'"'.' rows="'.$rows.'" '.$ftype.' name="'.$feld.'" wrap="'.$wrap.'">'.replace_umlauts($wert)."</textarea></td><th> ".chr($fz+64)."</th></tr>\n";
            next;
            }
######################################################
        if($sela=~/select/i){print "<tr><th> ".replace_umlauts($feld)." </th><td> $sela </td><th> ".chr($fz+64)."</th></tr>\n";next;}
        # in der folgenden Zeile $ftitel. herausgenommen, das der Text mitten im Input stand und sowieso nicht sichtbar war
        print "<tr><th> ".replace_umlauts($feld)." </th><td>".' <input size="'.$maxtxt.'" '.$ftype.' name="'.$feld.'" value="'.$wert.'"'." /></td><th> ".chr($fz+64)."</th></tr>\n";next;
        }
    # Bearbeitungs/Modus-Wahl - ab 3.6.2009 hier zum Ende(vorher am Anfang)
    print "<tr><th> <br>".' <a href="'.get_clr_link().'"> <img src="/brg/bgico/abort-22.png" width="22" height="22" border="0" alt="ABBRUCH - zur&uuml;ck zur Daten&uuml;bersicht" title="ABBRUCH - zur&uuml;ck zur Daten&uuml;bersicht"> </a>'.
          " </th><td><br><b><i> Bitte Bearbeitungsart w&auml;hlen: </i></b>"
    .replace_umlauts($LCrud)." $Ok";#." $pmemo";
    if (param('AI')) { print " $ai"; }
    if (param('AW')) { print (hidden('AW', $Aw)); }
    print (hidden('TIDX', $TIDX));
    if (param('VFI')) { print (hidden('VFI', param('VFI'))); }
    if (param('VPI')) { print (hidden('VPI', param('VPI'))); }
    if (param('FI'))  { print (hidden('FI',  param('FI'))); }
    # Attention: add new param values to the get_from exclude list, too!
    print "</td></tr>\n";

    print"</table></form>\n";
    print_html_version();
    print end_html(); # HTML-Ende
    }
    
######################################################################
sub    get_form #Daten werden aus Formular(self) in den FormularHash(POST) geladen
######################################################################
    {
    my ($feld,$lnx,$wert,@fa);
    my $lnr=1;
    $Satz="";
    foreach $feld (param())
        {
        next if $feld=~/submit|lcrud|pmemo|AI|VFI|FI|AW|VPI|CLR|TIDX/i;#NUR Datenfelder in Formularhash!
        $lnx=sprintf("% 3d",$lnr++);
        $Formsort{$lnx}=$feld;
        @fa=decode utf8=>param($feld);
        if ($#fa>0) # prüfen, ob MEHRFACH-WERTE in Array (z.B. Multiple bei Select-Feldern...2.4.2008)
            {
            $wert=join('<br>',@fa);
            }
        else {$wert=decode utf8=>param($feld);}
        $wert=~s/\xa/\<br\>/g;#LF in <br> wandeln! 14.5.2007
        $wert=~s/$lim/ \&bull; /g;#FeldTrennzzeichen innerhalb von Felder verhindern - ersetzen durch HTML-PUNKT -30.7.2010
        $wert=check_value($wert);
        $Formular{$feld}=$wert;
        $Satz.=$wert.$lim;
        }
    chop($Satz);
    $Satz=~s/\x0d//g;#CR entfernen!
    $Satz=~s/\%21/\"/g;#demask
    $Satz=~s/\(_/\</g;#demask
    $Satz=~s/_\)/\>/g;#demask
    $Satz=replace_html_umlauts($Satz);# hier wieder replace_umlauts zurückverwandeln
    $Satz.="\n";
    #print_error_page($Satz);
    }
######################################################################
sub    crud_ctrl#CRUD-Controler
######################################################################
    {
    my $set='1R';
    my $lz=0;
    %Liste=();
    if ($dbfile=~/\.bup$/i)
        {
        $set='5C';
        if($Secl=~/c_/) {$lz++; $Liste{'5C'}="WIEDERHERSTELLEN";}
        if($Secl=~/d_/) {$lz++; $Liste{'6D'}="LÖSCHEN";}
        }
    else
        {
        if($Secl=~/c_/) {$lz++; $Liste{'3C'}="N E U  anlegen "; if($Secl=~/^c/) {$set='3C';}}
        if($Secl=~/r_/) {$lz++; $Liste{'1R'}="Anzeigen"; if($Secl=~/^r/) {$set='1R';}}
        if($Secl=~/u_/) {$lz++; $Liste{'2U'}="ÄNDERN"; if($Secl=~/^u/) {$set='2U';}}
        if($Secl=~/d_/) {$lz++; $Liste{'4D'}="LÖSCHEN"; if($Secl=~/^d/) {$set='4D';}}
        if($lz==0){$Liste{'00'}="Kein Zugriff: Bearbeiten nicht m&ouml;glich!";$set='00';}
        }
    return popup_menu(
        '-name'    => 'LCRUD',
        '-size'    => '1',
        '-values'  => [(map {$_} sort keys %Liste)],
        '-default' => $set,
        '-labels'  => \%Liste);
    }

######################################################################
sub    check_value #Aliasse und Sonderzeichenumwandlung 15.9.2008
######################################################################
    {
    my $wert=shift;
    #.......Sonderparameter ?t, ?id ->NUR falls Quelle NICHT 'berg' enthält
    if($dbfile=~/berg/i){;}else
        {
        my $Ts0=get_single_date();
        $wert=~s/\?ts/$Ts0/g;#mask - TimeStamp
        $wert=~s/\?id/$REMOTEID/g;#mask
        }
    return $wert;
    }

#----------------------------------------------------------------
#
#----------------------------------------------------------------
######################################################################
sub get_db_info  #
######################################################################
    {
    my $auswahl=shift;
    my $memo = '';
    if ($auswahl=~/berg/)
    {
        $memo = 'Gemeindezeitungs-Generator#br/feginfo.csv';
    }
    elsif ($auswahl=~/bbup/)
    {
        $memo = 'Backup:Gemeindezeitungs-Backup-Datenbank#br/feginfo.bup';
    }
    else
    {
        print_error_page("Index-Zugriff"."<<<$auswahl>>>"." verweigert bzw. NICHT möglich!");
    }
    my ($id);
    ($headline, $dbfile)=split(/#/, $memo);
    $LCrud=crud_ctrl();
    $headline="Bearbeiten: $headline";
    #print_error_page("SUB: get_db_info=$_ $Secl");
    }

######################################################################
sub get_data#Daten werden komplett in den Formular-Hash geladen!
######################################################################
    {
    my ($dbfile,$lim,$felder)=@_;
    my @f=split(/,/,$felder);
    my (@fw,$fn,$fnx,$fv,$articleData,$lnx);
    my $lnr=1;
    $articleData=get_data_articleid($dbfile, param('AI'));
    chomp($articleData);
    put_msatz($articleData);
    @fw=split(/$lim/,$articleData);
    #Satzdaten- dynamisch
    foreach $fn (@f)
        {
        $lnx=sprintf("% 3d",$lnr++);$Formsort{$lnx}=$fn;
        $Formular{$fn}=shift(@fw);
        }
    #print_error_page("SUB: get_data=lnx=$lnx");
    }

######################################################################
sub get_data_articleid#Datensatz mit articleid holen
######################################################################
    {
    my ($dbfile,$articleid)=@_;
    my $match="^$articleid$lim";
    my $readSingleLine = '';
    open(INPF, "<:encoding(utf8)", "$dbfile") || return $readSingleLine;# print_error_page("Fehler: Konnte die Datei $dbfile nicht öffnen! (Interner Fehler: ".$!.")");
    flock(INPF, LOCK_SH) || print_error_page("Fehler: Konnte die Datei $dbfile nicht zum Lesen sperren (get_data_articleid - ".$!.")!");
    while($readSingleLine=<INPF>)
        {
        last if $readSingleLine=~/$match/;
        }
    flock(INPF, LOCK_UN) || print_error_page("Fehler: Konnte zum Lesen gesperrte Datei $dbfile nicht freigeben (get_data_articleid - ".$!.")!");
    close(INPF);
    return $readSingleLine;
    }

######################################################################
sub get_data_merge#Daten werden nach dem Merge in den Formular-Hash geladen!
######################################################################
    {
    my ($felder,$s,@mergeResult)=@_;
    my @f=split(/,/,$felder);
    my $lnr=1;
    put_msatz($s);
    #Satzdaten- dynamisch
    foreach my $fn (@f)
        {
        my $lnx=sprintf("% 3d",$lnr++);$Formsort{$lnx}=$fn;
        $Formular{$fn}=shift(@mergeResult);
        }
    }

######################################################################
sub next_id(*) # hole die nächste ID->nur Sinnvoll bei nummerischen IDs im 1.FELD!->max+1
######################################################################
    {
    my $nidx=qualify_to_ref(shift, caller);        
    my @f;
    my $nid=10;# let the first numbers free
    seek($nidx, 0, SEEK_SET);
    while(<$nidx>)
        {
        chomp;
        @f=split(/$lim/,$_);
        if ($f[0]>$nid){$nid=$f[0];}
        }
    return($nid+1);
    }

######################################################################
# DB Backup erzeugen
######################################################################
sub make_db_backup(*)    
    {
    my $unmodified=qualify_to_ref(shift, caller);
    my ($ss,$mm,$hh,$d,$m,$y)=(gmtime())[0..5];
    $y+=1900;
    $m++;
    #my $timestr='20110403211';
    my $timestr=sprintf("%04d%02d%02d%02d%d0",$y,$m,$d,$hh,$mm/10);
    my $backupname = $SPATH.'gi_backup/feginfo_'.$timestr.'.csv.gz';
    return if (-r $backupname);# wenn die Datei schon existiert, nicht nochmal anlegen        
    seek($unmodified, 0, SEEK_SET);
    gzip $unmodified => $backupname or die print_error_page("Fehler: Konnte komprimiertes Backup der Datenbank nicht erstellen (make_db_backup - ".$GzipError.")!");;
    }


######################################################################
sub put_data                # Datenauswahlsatz ->ändern,neu,löschen!
######################################################################
    {
    my $cmd=shift;
    my ($buf1,$buf2,$dataset,$nid);
    open(FILE, "+<:encoding(utf8)", "$dbfile") || print_error_page("Fehler: Datei ($dbfile) existiert nicht! (Interner Fehler: ".$!.")");# Input öffnen, auch zum Schreiben.
    flock(FILE, LOCK_EX) || print_error_page("Fehler: Konnte die Datei $dbfile nicht zum Schreiben sperren (put_data - ".$!.")!");# die gesamte Operation gegen parallele Zugriffe sichern
    make_db_backup(FILE);# Erst mal ne Kopie anlegen
    seek(FILE, 0, SEEK_SET);
        my $articleid=param('AI');
        my $match="^$articleid$lim";
        $buf1=$buf2='';    
        while(<FILE>)
            {
            if (/$match/) { $dataset=$_; last; }
            $buf1.=$_;
            }
        while(<FILE>)
            {
            $buf2.=$_;
            }
        my $msatz=get_msatz();
        my @f_orig=split(/$lim/,$msatz);
        my @f_other=split(/$lim/,$dataset);
        my @f_my=split(/$lim/,$Satz);
        my $tsid=0;
        foreach my $f (split(/,/,$felder)) { 
            last if ($f=~/TSID/i);
             $tsid++; }
        $f_orig[$tsid]=$f_other[$tsid]=$f_my[$tsid];# Allen Datensätzen die gleiche TSID verpassen
        my $conflict=0;
        my @mergeResult = ();
        for (my $i=0; $i < scalar(@f_my); $i++)# hier wird nun jedes Feld in Einzelzeilen zerlegt und diese werden mit einem 3-Wege-Merge behandelt
            {
            my $innerlim = "<br>";    
            my @orig = split($innerlim,$f_orig[$i]);
            my @other = split($innerlim,$f_other[$i]);
            my @myText = split($innerlim,$f_my[$i]);     
            my $mergeAlgo = Algorithm::Merge::merge(\@orig, \@other, \@myText, { 
                CONFLICT => sub ($$)
                    { 
                    $conflict=1; 
                    (
                    q{<<<<<<<< START CONFLICT (ihre Version) <<<<<<<}, 
                    @{$_[0]},
                    q{----------------------------------------------}, 
                    @{$_[1]}, 
                    q{>>>>>>>> END CONFLICT (meine Version) >>>>>>>>}
                    )
                    } 
                });
            $mergeResult[$i] = join ($innerlim,@{$mergeAlgo});     
            }
        if ($conflict)# create form, um den Konflikt auflösen zu lassen
            {
            get_data_merge($felder,$dataset,@mergeResult);# beinhaltet put_msatz($dataset);
            create_form(replace_umlauts("An dem Artikel wurden während der Bearbeitung Veränderungen vorgenommen. Der Bereich ist mit Kleiner- und Größerzeichen gekennzeichnet. Bitte eine Variante sowie die Kleiner- und Größerzeichen löschen und wieder speichern."),$Ok,$self);#Formular wird aus Hash generiert!
            flock(FILE, LOCK_UN) || print_error_page("Fehler: Konnte zum Schreiben gesperrte Datei $dbfile nicht freigeben - Merge erforderlich (put_data - ".$!.")!");
            close(FILE);
            return;# nicht speichern
            }
        else 
            {
            $Satz=join($lim, @mergeResult);# den erfolgreich zusammengeführten Artikel speichern. 
            }
    if ($cmd=~/^3C/ || $cmd=~/^5C/) #autoID holen falls ?next oder 1.Feld=ID=Nummerisch
        {
        $nid=next_id(FILE);
	    if($Satz=~/\?next/) 
	        {
	    	$Satz=~s/\?next/$nid/g;
	        }
	    else
	        {
            $Satz=~s/^\d+/$nid/;
	        }
	    #create_db();# DB erzeugen falls noch nicht vorhanden 22.2.2008
	    }
	seek(FILE, 0, SEEK_SET);
	if ($cmd=~/^3C/) {print FILE $buf1.$dataset.$Satz.$buf2;}
	elsif ($cmd=~/^2U/) {truncate(FILE, 0); print FILE $buf1.$Satz.$buf2;}# truncate: Dateiinhalt löschen, damit auch weniger Infos gespeichert werden können
	elsif ($cmd=~/^(4D|5C|6D)/) {truncate(FILE, 0); print FILE $buf1.$buf2;}
	else {print_error_page("Fehler: Unbekanntes Kommando (put_data)!");}
	flock(FILE, LOCK_UN) || print_error_page("Fehler: Konnte zum Schreiben gesperrte Datei $dbfile nicht freigeben (put_data - ".$!.")!");
	close(FILE);
    put_msatz_backup($cmd, $dbfile, $dataset);# Backup erst nach Freigabe des Locks, um ein Deadlock zu vermeiden. Beim Backup muß die DB auch gelockt werden.
	#befx(); #Nachverarbeitung wird zur Zeit nicht genutzt, aber die Weiterleitung auf berg.pl erfolgt dort auch.
	print redirect(get_view_link());
    }

#######################################################################
## TODO wirklich eine leereDB anlegen und nicht nur bei berg.idx - dafür mit erster Seite!
#######################################################################
#sub create_db# erzeuge Datenquelle, falls diese noch nicht existiert!
#    {
#    my $db=$Formular{"DBTabelle"};# DB-Quelle in berg.idx="DBTabelle"=Systemvariable ab 22.2.2008->aus Formularhash holen!
#    if($dbfile=~/berg.idx/i)
#        {
#        #print_error_page("Hallo die DB=$db ...korrekt?");
#        open(CIDX, "<:encoding(utf8)", "$db") || new_db($db);
#        close(CIDX);
#        }
#    }

######################################################################
sub new_db# erzeuge NEUE Datenquelle
######################################################################
    {
    my $db=shift;
    open(COIDX, ">:encoding(utf8)", "$db") || print_error_page("konnte $db nicht öffnen! (Interner Fehler: ".$!.")");
    print COIDX "DB initialisiert am ".get_single_date()."\n";
    close(COIDX);
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

######################################################################
sub set_href # Mail- o. Internetadressenkürzel ins htmlformat wandeln
######################################################################
    {
    my ($s,$m)=@_;
    my @f=split(/<br>+/,$s);
    my (%href,$e,$x);
    $href{"ma="}='<a href=mailto:xXx>xXx</a>';
    $href{"ia="}='<a href=xXx><img src=/brg/bgico/help-22.png width="22" height="22"></a>';
    $href{"um="}='<img src="xXx" width="300">';
    $href{"im="}='<img src="xXx" width="100">';
    $s="";
    foreach $e (@f)
        {
        if($e=~/$m/)
            {
            ($x,$x)=split(/$m/,$e);
            $e=$href{$m};
            $e=~s/xXx/$x/g;
            }
        $s.=$e."<br>";
        }
    return($x,$s);
    }

######################################################################
sub put_msatz#aktuellen Satzinhalt merken -> Transaktionsdatei speichern!
######################################################################
    {
    my $singleDataset=shift;
    my $TIDIO=$TIDP.$TIDX.".txt";
    open(TIDO, ">:encoding(utf8)", "$TIDIO") || print_error_page("konnte $TIDIO nicht öffnen! (Interner Fehler: ".$!.")");
    print TIDO $singleDataset;
    close(TIDO);
    chmod 0666,$TIDIO;#Löschrechte explizit vergeben! 6.9.2007
    #print_error_page("$Seek<br>$s<br>");
    }

######################################################################
sub put_msatz_backup#RAID1-BackupMirror simmulieren (Backupautomatik NUR bei DB-Dateien mit *.csv Endung!!!)
######################################################################
    {
    my $aktion=shift;
    my $qbup=shift;#Raid-Backup-WechselZiel: falls Quelle *.csv wird Datensatz an *.bup angehängt sonst umgekehrt!
    my $s=shift;
    if ($qbup=~/(\.csv$|\.bup$)/i)
        {
        if ($qbup=~s/\.csv/\.bup/gi) {;} else {$qbup=~s/\.bup/\.csv/gi;}
        open(BUP, "+>>:encoding(utf8)", "$qbup") || print_error_page("Fehler: Konnte die Datei für das Backup $qbup nicht öffnen! (Interner Fehler: ".$!.")");
        flock(BUP, LOCK_EX) || print_error_page("Fehler: Konnte die Datei $qbup nicht zum Schreiben sperren (put_msatz_backup - ".$!.")!");       
        my $nid=next_id(BUP);
        $s=~s/^\d+$lim/$nid$lim/;# neue ID einsetzen
        seek(BUP, 0, SEEK_END);# ans Ende springen
        if($aktion=~/^(2U|3C|5C)/) {print BUP $s;}#Backup-Satz anhängen bei NEU/Ändern
        if($qbup=~/\.bup/i && $aktion=~/^4D/) {print BUP $s;}#Backup-Satz NUR anhängen wenn Löschen und NICHT .bup
        # $aktion=~/^6D/ kein Backup, da im Backup ja gelöscht werden soll
        flock(BUP, LOCK_UN) || print_error_page("Fehler: Konnte die zum Schreiben gesperrte Datei $qbup nicht freigeben (put_msatz_backup - ".$!.")!");
        close(BUP) || print_error_page("Fehler: Konnte die Datei $qbup nicht nicht wieder schließen (put_msatz_backup - ".$!.")!");
        }
    }

######################################################################
sub get_msatz# Ursprungssatz aus dem TIDX-Verzeichnis laden
######################################################################
    {
    my $msatz;
    my $TIDIO=$TIDP.$TIDX.".txt";
    open(TIDI, "<:encoding(utf8)", "$TIDIO") || print_error_page("Konnte die Datei mit dem unveränderten Artikel $TIDIO nicht öffnen (get_msatz - ".$!.")!");
    $msatz=<TIDI>;
    close(TIDI);
    unlink($TIDIO);#Msatz löschen
    return $msatz;
    }

######################################################################
sub get_select# Generiere Auswahl-(Selection)Feld 17.4.2007.
# falls ? als 1. Eintrag->Selection NUR->falls Wert in Liste 8.6.2007
######################################################################
    {
    my ($fn,$liste,$sel)=@_;
    my @le=split(/$Sftz/,$liste);
    my ($v,$n,$s,$o,$e,@mfn,$lflg,$sflg);
    if ($sel=~/ neu!/){return($sel);}# neueingaben erlauben falls (neu)=Listenelement 26.5.2009
    if ($le[0] eq "?" && $liste!~$sel){return($sel);}# Falls ? und Element nicht in Liste ->freie Wertzuweisung erlauben 5.6.2009
    if($le[0]eq "?") {shift(@le);$lflg=1;}
    if($le[0]eq "sort!") {shift(@le);$sflg=1;}
    if($le[0]eq "*") # mehrfachselektion? 28.3.2008
        {
        shift(@le);
        #$le[0]=$sel;
        $s='<select name="'.$fn.'" size="'.$#le.'" multiple>';
        }
    else
        {
        $s='<select name="'.$fn.'" size="1">';
        }
    if($lflg && $Neuflg){@le=($Neuflg,@le);} # falls fixListe zzgl. Neueingabe? 26.5.2009

    if($sflg)
        {
        foreach $e (sort @le)        # Liste sortiert 27.5.2009
	        {
	        if($e=~/=/)#Wertzuweisung:anderer Wert als Listeneintrag
	            {($v,$n)=split(/=/, $e);}
	        else {$v=$e;$n=$e;}
	        if($sel eq $v){$o='<option selected ';} else {$o='<option ';}
	        $s.=$o.' value="'.$v.'">'.$n.'</option>'."\n";
	        }
        }
    else  
        {
        foreach $e (@le)        # Liste wie Definition 27.5.2009
            {
            if($e=~/=/)#Wertzuweisung:anderer Wert als Listeneintrag
                {($v,$n)=split(/=/, $e);}
            else {$v=$e;$n=$e;}
            if($sel eq $v){$o='<option selected ';} else {$o='<option ';}
            $s.=$o.' value="'.$v.'">'.$n.'</option>'."\n";
            }
        }
    return($s.'</select>');
    }


sub get_date_list    # generiere Komma-Datumsliste ->anzahl=tage ab heute!     12.9.2008
{
    my ($mod,$anz,$jx,$fwert)=@_;# Parameter= Modus s.u., Anzahl Tage ab heute, Feldtrennzeichen, nur dieses Jahr(jx) in Liste anzeigen  ->bgcrud->select ...KOMMA
    my $s;
    my ($t,$m,$j,$wt,$jt)=(localtime())[3..7];
    my @md = (0,31,28,31,30,31,30,31,31,30,31,30,31);
    my @mn = qw(nix Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez);
    my @wd = qw(So Mo Di Mi Do Fr Sa);
    $m++;$j+=1900;$jt++;
    my $kw=$jt/7+1;
    $s=$fwert.$Sftz;
    if(!$jx){$jx=$j;}# falls Zieljahr=0=>akt. Jahr 2.9.2010
    if($Neuflg){$s.=$Neuflg.$Sftz;}#neueingaben gewünscht? 26.5.2009
    while($anz)
        {
        $wt=$wt%7;
        $kw=$jt/7+1;
        if($t > $md[$m])
            {
            $t=1;
            $m+=1;
            if($m > 12)
                {
                $m=1;
                $j+=1;
                $jt=1;
                # Falls Schaltjahr -> Feb=29Tage
                if(($j%4)==0) {$md[2]=29;} else {$md[2]=28;}
                }
            if ($jx && $jx ne $j){$t++;$wt++,$jt++;next;}# Nur Zieljahr listen 18.11.2008
            $s.="$Sftz  $Sftz * $mn[$m] $j * $Sftz ";
            }
        if ($jx && $j >  $jx){$anz=0;next;}# Nur Zieljahr listen 18.11.2008
        if ($jx && $jx ne $j){$t++;$wt++,$jt++;next;}# Nur Zieljahr listen 18.11.2008
        if ($mod == 1){    $s.=sprintf("$Sftz%02d.%02d.%04d",$t,$m,$j);}
        elsif ($mod == 2){$s.=sprintf("$Sftz%02d.%02d.%04d - %s",$t,$m,$j,$wd[$wt]);}
        elsif ($mod == 3){$s.=sprintf("$Sftz%02d.%02d.%04d - %s (%02d)",$t,$m,$j,$wd[$wt],$kw);}
        elsif ($mod == 4){$s.=sprintf("$Sftz%02d.%02d.%04d - %s (%03d / Kw%02d)",$t,$m,$j,$wd[$wt],$jt,$kw);}
        $anz--;
        $t++;$wt++,$jt++;
        }
    return("$s\n");
}

sub get_number_list    # generiere Komma-Ziffernliste ->breite,start,ende,inc     12.9.2008
    {
    my ($breite,$anf,$end,$inc,$fwert)=@_;
    my ($s,$fm);
    $s=$fwert.$Sftz;
    if($Neuflg){$s.=$Neuflg.$Sftz;}#neueingaben gewünscht? 26.5.2009
    $fm='%0'.$breite.'d'.$Sftz;
    while($anf<=$end)
        {
        $s.=sprintf($fm,$anf);
        $anf+=abs($inc);
        }
    chop($s);
    return("$s");
    }

sub get_field_list    # generiere UniqueFeldInhaltsliste s.a. 1SpaltenModus in berg.pl     15.5.2009
    {
    my ($fnr,$fwert)=@_;
    $fnr--;
    my %fh;#FeldInhaltHash
    my $file = "<" . $dbfile;
    my (@f,$s,$k);
    if($Neuflg){$s.=$Neuflg.$Sftz;}#neueingaben gewünscht? 26.5.2009
    open(INPF, "<:encoding(utf8)", "$file") || print_error_page("Konnte $dbfile nicht öffnen!");
    while(<INPF>)
        {
        chomp;
        @f=split(/$lim/,$_);
        $fh{$f[$fnr]}=1;#hash aufbauen
        }
    foreach $k (sort keys %fh)
        {
        $s.=$k.$Sftz;# füllen der Selectionsliste sortiert!
        }
    chop($s);
    close(INPF);
    return("$s");
    }


#############################################################################
# The following functions are shared between the perl scripts.
# Synchronization ensured the last time on: 2012-08-12
#############################################################################

#----------------------------------------------------------------------------
# Replace german Umlauts with their HTML entity.
# replace_umlauts and replace_html_umlauts must match!
#----------------------------------------------------------------------------
sub replace_umlauts
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
sub replace_html_umlauts
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
sub print_error_page
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
sub print_html_version
{
    print "\n";
    print '<p class="version">Version: '.$VERSION." (Perl $])</p>\n";
}    

;
