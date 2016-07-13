/*!
 * Berg CMS JavaScript
 *
 * Copyright 2013, 2014 Christian Leutloff
 * Released under the MIT license
 * https://github.com/leutloff/berg/blob/master/LICENSES/MIT-LICENSE.txt
 */
var $ = require('jquery');
var brg = {
    // function should be called on document ready. Adds version information to HTML page.
    onLoadCommon: function (){
        if (console) { console.log("brgOnLoadCommon called."); }
        $("#brg-version").append(" (berg js v0.2, jQuery v" + $().jquery + ")");

    },

    // adds a short reference for the Berg CMS commands.
    onLoadShortReference: function(){
        if (console) { console.log("brgOnLoadShortReference called."); }
        var shortref="";
        shortref += "Kurzreferenz anzeigen oder verbergen: ";
        shortref += "    <a href=\"javascript:;\" id=\"refall\">alles<\/a>,";
        shortref += "    <a href=\"javascript:;\" id=\"refwords\">Worte<\/a>,";
        shortref += "    <a href=\"javascript:;\" id=\"refpara\">Absätze<\/a>,";
        shortref += "    <a href=\"javascript:;\" id=\"refregions\">Bereiche<\/a>    ";
        shortref += "    <\/p>";
        shortref += "    <p id=\"contentwords\">";
        shortref += "    \\textbf{<strong>fett<\/strong>}<br \/>";
        shortref += "    \\mbox{nicht umbrechen}<br \/>";
        shortref += "    &gt;BILD#Titel#c#Datei#b:160mm#Fotograf<br \/>";
        shortref += "    \\url{http:\/\/feg.de}, \\href{mailto:redaktion@bergcms.local}{redaktion@bergcms.local}, oder \\href{mailto:termine@bergcms.local}{\\protect\\nolinkurl{termine@bergcms.local} }<br \/>";
        shortref += "    &gt;i#Autor<br \/>";
        shortref += "    <\/p>";
        shortref += "    <p id=\"contentpara\">";
        shortref += "    &gt;sg#4 Standardschriftgröße 0..9<br \/>";
        shortref += "    &gt;zd#0 oder &gt;zd#1.0 Standardzeilenabstand<br \/>";
        shortref += "    \\newline<br \/>";
        shortref += "    <br \/>";
        shortref += "    dehnbaren Abstand einfügen, z.B. zwischen Monaten in der Terminliste oder bei Adressänderungen:<br \/>";
        shortref += "    \\vspace{2ex plus 1ex minus 1ex}";
        shortref += "    <\/p>";
        shortref += "    <p id=\"contentregions\">";
        shortref += "    &gt;1#Bereichsüberschrift, wie Einladungen oder Rückblick<br \/>";
        shortref += "    &gt;2#Artikelüberschrift<br \/>";
        shortref += "    &gt;3#Zwischenüberschriften in einem Artikel (fett und Abstand)<br \/>";
        shortref += "    <br \/>";
        shortref += "    &gt;!# Neue Spalte beginnen<br \/>";
        shortref += "    &gt;+# Neue Seite beginnen<br \/>";
        shortref += "    &gt;SPALTEN#1# ab hier einspaltig<br \/>";
        shortref += "    &gt;SPALTEN#2# ab hier zweispaltig<br \/>";
        shortref += "    <\/p>";
        shortref += "";

        $("#brg-short-reference").replaceWith(shortref);
        
        // show/hide parts of the short reference
        $("#contentwords").hide();
        $("#contentpara").hide();
        $("#contentregions").hide();
        $("#refall").click(function() {
            if ($("#contentwords").is(":visible") ||
                $("#contentpara").is(":visible") ||
                $("#contentregions").is(":visible"))
            {
                $("#contentwords").hide();
                $("#contentpara").hide();
                $("#contentregions").hide();
            }
            else    
            {
                $("#contentwords").show();
                $("#contentpara").show();
                $("#contentregions").show();
            }
        });
        $("#refwords").click(function() {
            $("#contentwords").toggle();
        });
        $("#refpara").click(function() {
            $("#contentpara").toggle();
        });
        $("#refregions").click(function() {
            $("#contentregions").toggle();
        });
    }
};
