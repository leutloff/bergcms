{{%AUTOESCAPE context="HTML"}}
{{! berg_archive_all_articles.tpl - Template for all the articles of a single archive.

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
                    <li class="active"><strong>Artikelübersicht</strong></li>
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
            <h3>Artikel der Gemeindeinformation {{ARCHIVE_ISSUE}} ({{ARCHIVE_NUMBER}})</h3>
            <table class="ym-grid">
                <th>
                    <td>AI</td>
                    <td>Kapitel</a></td>
                    <td>Titel</a></td>
                    <td>Prio</a></td>
                    <td>Typ</a></td>
                </th>
                {{#ARTICLE_LIST}}
                <tr>
                    {{! ARTICLE_ID, ARTICLE_CHAPTER, ARTICLE_PRIORITY, ARTICLE_TITLE, ARTICLE_TYPE,
                        ARTICLE_HEADER, ARTICLE_BODY, ARTICLE_FOOTER, ARTICLE_LASTCHANGED }}
                    <td><a href="{{ARTICLE_REFERENCE}}" class="ym-button ym-next">{{ARTICLE_ID}}</a></td>
                    <td><a href="{{ARTICLE_REFERENCE}}">{{ARTICLE_CHAPTER}}</a></td>
                    <td><a href="{{ARTICLE_REFERENCE}}">{{ARTICLE_TITLE}}</a></td>
                    <td><a href="{{ARTICLE_REFERENCE}}">{{ARTICLE_PRIORITY}}</a></td>
                    <td><a href="{{ARTICLE_REFERENCE}}">{{ARTICLE_TYPE}}</a></td>
                </tr>
                {{/ARTICLE_LIST}}
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
    
