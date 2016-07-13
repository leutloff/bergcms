#!/usr/bin/perl -w
#############################################################################
# Uploader - Resize uploaded images using ImageMagick convert tool.
#
# (c) 2007, 2009, 2010, 2011 Heiko Decker
# (c) 2011, 2012 Christian Leutloff
# 
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
#############################################################################

use strict;
use warnings;

use CGI qw/:standard :html4/;
use CGI::Carp qw(fatalsToBrowser); # show fatal errors in the browser

my $VERSION="v2.06, 28.12.2012";
my $uploadpath='ul';# Zwischenspeicherung des Bildes unmittelbar nach dem Upload
my $finalimagepath='br/bilder';# hier wird das Bild von pex erwartet
my $maxsize=50000;#at maximum accepted image size (KByte)

if (!defined(param("FILE")) && !defined(param("IMAGE")))
{
    show_upload_page();
    exit 0;
}
if (defined(param("IMAGE")))
{
    return_image(param("IMAGE"));
    exit 0;
}

my $fileFromBrowser = param("FILE");# must remain a global variable!
# ensure that the resulting filename matches ^[a-z0-9\-]+\.jpg$
(my $filename, my $ext)=split(/\./, param("FILE"));
$filename = lc($filename);
$ext = '.'.lc($ext);
$filename =~ s/^.*(\\|\/)//g;
$filename =~ s/ +/-/g;
$filename =~ s/_/-/g;
$filename =~ s/\+/-/g;
$filename =~ s/"//g;
$filename =~ s/ü/ue/g;
$filename =~ s/ä/ae/g;
$filename =~ s/ö/oe/g;
#$filename =~ s/Ü/ue/g;
#$filename =~ s/Ä/ae/g;
#$filename =~ s/Ö/oe/g;
$filename =~ s/ß/ss/g;
# remove everything exept letters, digits, minus and a dot
$filename =~ s/[^a-z0-9\-]//g;

my $uploadedfile="$uploadpath/$filename$ext";# hierhin wird das Bild zunächst auf den Server geladen
print_page_head();
if ('.jpg' =~ /$ext/){ uploading(); }
else { print '<h2>Der Dateityp \''.$filename.$ext.'\' darf nicht hochgeladen werden.</h2>'; }
print_page_buttom();
exit 0;

#----------------------------------------------------------------
# Receive the sent file and store it.
#----------------------------------------------------------------
sub uploading
{
    my $file = param("FILE");
    #print p('Die Datei wird nun hochgeladen ...');
    if(open(my $OUTFILE, ">", "$uploadedfile")) 
    {
        while (my $bytesread = read($fileFromBrowser, my $buffer, 1024)) 
        {
            print $OUTFILE $buffer;
        }
        close($OUTFILE);
        if((-s "$uploadedfile") > ($maxsize*1024)) 
        {
            unlink($uploadedfile);
            print p('Die Datei <b>'.$filename.$ext.'</b> konnte nicht abgelegt werden,',
                    ' da die maximale Upload-Dateigroesse von<b> '.$maxsize.' KBytes</b> ueberschritten wurde!');
            return;
        }
        else 
        {
            print p('Die Datei <strong>'.$filename.$ext.'</strong> wurde erfolgreich &uuml;bertragen.');
        }
        scale_uploaded_file();
        unlink($uploadedfile);
    }
    else
    {
        print p('Die Datei '.$uploadedfile.' konnte nicht abgelegt werden!');
    }
}

#----------------------------------------------------------------
# scale the uploaded File
#----------------------------------------------------------------
sub scale_uploaded_file
{    
    my $scale = defined(param('SCALE')) ? param('SCALE') : "600";
    if ( $scale !~ /\d/ ) {  print p("Invalid scale $scale ignored."); $scale = "600"; }
    
    # widthxheight> Shrinks images with dimension(s) larger than the corresponding width and/or height dimension(s).
    #my $bef='convert -verbose -debug -regard-warnings '.$uploadedfile.' -resize x600 '.$finalimagepath.'/'.$filename.$ext;
    #my $bef='/usr/bin/convert '.$uploadedfile.' -resize x600 '.$finalimagepath.'/'.$filename.$ext.' 2>&1';
    my $bef='/usr/bin/convert '.$uploadedfile.' -resize x'.$scale.' '.$finalimagepath.'/'.$filename.$ext.' 2>&1';
    #system('ls -l '.$uploadedfile.' '.$finalimagepath.'/'.$filename.$ext);
    print p("Skalierung der hochgeladenen Datei auf $scale px.");
    print '<p><small><pre>Befehl: '.$bef."\n";
    system($bef);
    my $ret=$?;
    print '</pre></small></p>';
    if ($ret == -1)
    {
        print p("Convert fehlgeschlagen: $!\n"), p("Ausgeführter Befehl: $bef");
    }
    elsif ($ret & 127)
    {
        printf "<p>Convert died with signal %d, %s coredump.</p>\n",
                ($ret & 127), ($ret & 128) ? 'with' : 'without';
    }
    else
    {
        if ($ret)
        {
            printf "<p>Convert fehlgeschlagen mit dem Rückgabewert %d.<p>\n", $? >> 8;
        }
        else
        {
            printf "<p>Convert erfolgreich ausgeführt mit dem Rückgabewert %d.<p>\n", $? >> 8;          
        }
    }
    print '<p>Nach der Konvertierung:'."\n<pre>";
    system('ls -l '.$finalimagepath.'/'.$filename.$ext);
    #system('ls -l '.$uploadedfile.' '.$finalimagepath.'/'.$filename.$ext);
    #system('ls -l /home/bergcms/cgi-bin/brg/'.$uploadedfile.' /home/bergcms/cgi-bin/brg/br/bilder/'.$filename.$ext);
    print '</pre></p>';
    print p('Das Bild ('.$filename.$ext.') ', 
            '<img src="/cgi-bin/brg/bgul.pl?IMAGE='.$filename.$ext.'" width="300">'),
        p(' kann jetzt mit dem folgenden ', b('Befehl'), ' in die Gemeindeinformation eingebunden werden:');
    print p(pre('&gt;bild#Bilduntertitel#b#'.$filename.'#opt#Fotograf'));
}



#----------------------------------------------------------------
# print the beginning of the page
#----------------------------------------------------------------
sub print_page_head
{
    print header('-charset' => 'utf-8');
    print start_html('-title'     => 'Bilder hochladen',
                     '-style'     => {'src'=>"/brg/css/bgcrud.css"},
                     '-encoding'  => 'utf-8',
                     '-lang'      => 'de');
    print '<h1>Bilder f&uuml;r die Gemeindeinformation hochladen</h1>';   
}

#----------------------------------------------------------------
# print the end of the page 
#----------------------------------------------------------------
sub print_page_buttom
{
    print p('<a href="/cgi-bin/brg/berg.pl?AW=berg&VPI=!e&VFI=*bcdei">',
          '<img src="/brg/bgico/berg-32.png" width="32" height="32" border="0"> Gemeindezeitungs-Generator</a>',
          ' oder ', '<a href="/cgi-bin/brg/bgul.pl">ein Bild hochladen</a>?');
    print_html_version();
    print end_html();   
}

#----------------------------------------------------------------
# Show the page for the upload.
#----------------------------------------------------------------
sub show_upload_page
{
    # Image size calculation for 600 dpi
    #  2.54 cm -  600 px
    #  4.00 cm -  945 px
    #  6.00 cm - 1417 px
    #  6.50 cm - 1535 px (row width)
    #  9.00 cm - 2126 px
    # 13.50 cm - 3189 px (title page - line width)
    print_page_head();
    print p('<FORM METHOD="POST" ACTION="/cgi-bin/brg/bgul.pl" ENCTYPE="multipart/form-data">',
        '<table border="0">',
        '<tr><td>Datei ausw&auml;hlen: </td><td><INPUT TYPE="FILE" NAME="FILE" size="60"></td></tr>',
        '<tr><td>Größe festlegen: </td><td><select name="SCALE" size="1">',
            '<option value="300" > 1,27 cm,  300 px</option>',
            '<option value="600" > 2,54 cm,  600 px, wie bisher</option>',
            '<option value="945" > 4    cm,  945 px</option>',
            '<option value="1417" selected> 6    cm, 1417 px, fast eine Spaltenbreite (opt)</option>',
            '<option value="1535"> 6,50 cm, 1535 px, eine Spaltenbreite </option>',
            '<option value="2126"> 9    cm,  2126 px</option>',
            '<option value="3189">13,50 cm, 3189 px, zwei Spaltenbreiten/Titelseite</option>',
        '</select></td></tr>',
        '<tr><td></td><td align="right"><INPUT TYPE="SUBMIT" VALUE="Datei hochladen"></td></tr>',
        '</table>',
        '</FORM>');  
    print_page_buttom();
}

#----------------------------------------------------------------
# Return an uploaded and scaled image.
#----------------------------------------------------------------
sub return_image
{
    my $image = shift;
    my $imagepath = $finalimagepath.'/'.$image;
    if($image !~ /^[a-z0-9\-]+\.jpg$/ || !-e $imagepath)
    {
        print_page_head();
        print p('Dateityp wird nicht unterstützt oder die Datei '.$image.' existiert nicht. (Pfad: '.$imagepath.')');
        print_page_buttom();
    }
    else
    {
        my ($IMAGEFILE, $readimage, $buff);
        open $IMAGEFILE, "<", "$imagepath";
        while(read $IMAGEFILE, $buff, 1024)
        {
            $readimage .= $buff;
        }
        close $IMAGEFILE;
        binmode STDOUT;
        print header("image/jpeg");
        print $readimage;
    }
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
