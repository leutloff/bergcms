{{%AUTOESCAPE context="HTML"}}
{{! berg_main.tpl - Template for the main page of the whole system.

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
                    <li class="ym-g20 ym-gl active"><strong><a href="{{BERG_CGI_ROOT}}/berg">Home</a></strong></li>
                    <li class="ym-g20 ym-gl"><a href="{{BERG_CGI_ROOT}}/berg.pl?AW=berg&VPI=!e&VFI=*bcdei">Aktuelle Ausgabe</a></li>
                    <li class="ym-g20 ym-gl"><a href="{{BERG_CGI_ROOT}}/archive">Archiv</a></li>
                    <li class="ym-g20 ym-gr"><a href="{{BERG_CGI_ROOT}}/berg?cntnt=hlp">Dokumentation</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>
<header>
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <h1>{{SYSTEM_TITLE_LONG}}</h1>
        </div>
    </div>
</header>
<div role="navigation" id="main">
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <div class="ym-grid linearize-level-2">
                <div class="ym-g33 ym-gl">
                    <div class="ym-gbox-left">
                        <div class="box info">
                            <h3>Aktuelle Ausgabe</h3>
                            <p>Bearbeitung der nächsten Ausgabe. Hier geht es zur bisherigen Version des Gemeindezeitungsgenerators.<p>
                            <a href="{{BERG_CGI_ROOT}}/berg.pl?AW=berg&VPI=!e&VFI=*bcdei" class="ym-button ym-next">Aktuelle Ausgabe</a>
                        </div>
                    </div>
                </div>
                <div class="ym-g33 ym-gl">
                    <div class="ym-gbox">
                        <h3>Archiv</h3>
                        <p>Texte von bereits veröffentlichten Ausgaben. Es sind nur die Artikel mit den positiven Nummern verfügbar.</p>
                        <a href="{{BERG_CGI_ROOT}}/archive" class="ym-button ym-next">Archiv</a>
                    </div>
                </div>
                <div class="ym-g33 ym-gr">
                    <div class="ym-gbox">
                        <h3>Dokumentation</h3>
                        <p>Links zum Download der Dokumentation.</p>
                        <a href="{{BERG_CGI_ROOT}}/berg?cntnt=hlp" class="ym-button ym-next">Dokumentation</a>
                    </div>
                </div>
            </div>
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
