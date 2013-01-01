{{%AUTOESCAPE context="HTML"}}
{{! berg_archive_single_article.tpl - Template for a single article from an archived database.

Copyright 2012 Christian Leutloff <leutloff@sundancer.oche.de>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

}}
{{! ---------------   BEGIN shared Berg header (2012-04-09)   --------------- }}
<!DOCTYPE html>
<html lang="{{BERG_LANG}}">
<head>
    <meta charset="utf-8"/>

    {{! ensure that the page is always loaded from the server }}
    <meta http-equiv="expires" content="0">
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">

    <title>{{HEAD_TITLE}} - {{SYSTEM_TITLE_SHORT_ASCII}}</title>

    {{! Mobile viewport optimisation }}
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    {{! Some more meta data }}
    <meta name="author" content="{{BERG_AUTHOR}}">

    <link href="/brg/css/berg.css" rel="stylesheet" type="text/css"/>
    <!--[if lte IE 7]>
    <link href="/brg/css/iehacks.css" rel="stylesheet" type="text/css" />
    <![endif]-->

    <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
</head>
<body>
<ul class="ym-skiplinks">
    <li><a class="ym-skip" href="#nav">Skip to navigation (Press Enter)</a></li>
    <li><a class="ym-skip" href="#main">Skip to main content (Press Enter)</a></li>
</ul>
<nav id="sitenav" role="navigation">
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <div class="mnav">
                <ul class="ym-grid ym-equalize linearize-level-1">
                    <li class="ym-g25 ym-gl"><a href="{{BERG_CGI_ROOT}}/berg">{{SYSTEM_TITLE}}</a></li>
                    <li class="ym-g25 ym-gl {{ACTIVE_ACTUAL}}"><a href="{{BERG_CGI_ROOT}}/berg.pl?AW=berg&VPI=!e&VFI=*bcdei">Aktuelle Ausgabe</a></li>
                    <li class="ym-g25 ym-gl {{ACTIVE_ARCHIVE}}"><a href="{{BERG_CGI_ROOT}}/archive">Archiv</a></li>
                    <li class="ym-g25 ym-gr {{ACTIVE_DOCUMENTATION}}"><a href="{{BERG_CGI_ROOT}}/berg?cntnt=hlp">Dokumentation</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>
{{! ---------------   END shared Berg header (2012-04-09)   --------------- }}
<nav id="nav" class="fix" role="navigation">
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <div class="ym-hlist">
                <ul class="ym-grid ym-equalize linearize-level-1">
                    <li><a href="{{BERG_CGI_ROOT}}/archive">Archivierte Ausgaben</a></li>
                    <li><a href="{{BERG_CGI_ROOT}}/archive?archive={{ARCHIVE_NAME}}">Artikelübersicht</a></li>
                    <li class="active"><strong>Artikel {{ARTICLE_ID}}</strong></li>
                </ul>
{{!
                <!--
                <form class="ym-searchform">
                    <input class="ym-searchfield" type="search" placeholder="Archiv durchsuchen..." />
                    <input class="ym-searchbutton" type="submit" value="Finden" />
                </form>
                -->
}}
            </div>
        </div>
    </div>
</nav>
<div role="navigation" id="main">
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <h3>{{ARTICLE_TITLE}}</h3>
            <p>Artikel {{ARTICLE_ID}} der Gemeindeinformation {{ARCHIVE_ISSUE}} ({{ARCHIVE_NUMBER}})</p>
            <table class="ym-grid">
                    {{! ARTICLE_ID, ARTICLE_CHAPTER, ARTICLE_PRIORITY, ARTICLE_TITLE, ARTICLE_TYPE,
                        ARTICLE_HEADER, ARTICLE_BODY, ARTICLE_FOOTER, ARTICLE_LASTCHANGED }}
                <tr>
                    <td>ID</td>
                    <td>{{ARTICLE_ID}}</td>
                </tr>
                <tr>
                    <td>Kapitel</td>
                    <td>{{ARTICLE_CHAPTER}}</td>
                </tr>
                <tr>
                    <td>Titel</td>
                    <td>{{ARTICLE_TITLE}}<td>
                </tr>
                <tr>
                    <td>Priorität</td>
                    <td>{{ARTICLE_PRIORITY}}<td>
                </tr>
                <tr>
                    <td>Typ</td>
                    <td>{{ARTICLE_TYPE}}><td>
                </tr>
                <tr>
                    <td>Kopf</td>
                    <td><textarea cols="100" rows="{{ARTICLE_HEADER_LINES}}" name="Kopf">{{ARTICLE_HEADER}}</textarea><td>
                </tr>
                <tr>
                    <td>Haupttext</td>
                    <td><textarea cols="100" rows="{{ARTICLE_BODY_LINES}}" name="Haupttext">{{ARTICLE_BODY}}</textarea><td>
                </tr>
                <tr>
                    <td>Fuss</td>
                    <td><textarea cols="100" rows="{{ARTICLE_FOOTER_LINES}}" name="Fuss">{{ARTICLE_FOOTER}}</textarea><td>
                </tr>
                <tr>
                    <td>Zuletzt bearbeitet</td>
                    <td>{{ARTICLE_LASTCHANGED}}<td>
                </tr>
            </table>
        </div>
    </div>
</div>
{{! ---------------   BEGIN shared Berg footer (2012-04-09)   --------------- }}
<footer>
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <p><a href="{{BERG_CGI_ROOT}}/berg?cntnt=abt">{{BERG_VERSION}}</a>, &copy; {{BERG_COPYRIGHT}} &ndash; Layout basiert auf <a href="http://www.yaml.de">YAML</a></p>
        </div>
    </div>
</footer>

{{! full skip link functionality in webkit browsers }}
<script src="/brg/css/yaml/core/js/yaml-focusfix.js"></script>

</body>
</html>
{{! ---------------   END shared Berg footer (2012-04-09)   --------------- }}
