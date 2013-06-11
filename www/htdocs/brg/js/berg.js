/*!
 * Berg CMS JavaScript
 *
 * Copyright 2013 Christian Leutloff
 * Released under the MIT license
 * https://github.com/leutloff/berg/blob/master/LICENSES/MIT-LICENSE.txt
 */
var brg = {
    // function should be called on document ready. Adds version information to HTML page.
    onLoadCommon: function (){
        if (console) { console.log("brgOnLoadCommon called."); }
        $("#brg-version").append(" (berg js v0.1, jQuery v" + $().jquery + ")");

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
        shortref += "    <p id=\"contentwords\">\\textbf{fett}";
        shortref += "    <\/p>";
        shortref += "    <p id=\"contentpara\">\\newline";
        shortref += "    <\/p>";
        shortref += "    <p id=\"contentregions\">";
        shortref += "       &gt;spalten#2#zweispaltig<br \/>";
        shortref += "    <\/p>";

        $("#brg-short-reference").replaceWith(shortref);
        
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
