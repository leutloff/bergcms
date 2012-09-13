{{%AUTOESCAPE context="HTML"}}
{{! shared_header_and_footer.tpl - This Template is NOT loaded by any berg program.
    The purpose is to document the shared page content in a single place.

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
{{! ---------------   BEGIN shared Berg header   --------------- }}
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
<header>
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <h1>{{SYSTEM_TITLE}}</h1>
        </div>
    </div>
</header>
<nav id="nav">
    <div class="ym-wrapper">

        <div class="ym-hlist">
            <ul>
                <li class="active"><strong>Archiv</strong></li>
                <li><a href="#">Aktuelle Ausgabe</a></li>
            </ul>
            <!--
            <form class="ym-searchform">
                <input class="ym-searchfield" type="search" placeholder="Search..." />
                <input class="ym-searchbutton" type="submit" value="Search" />
            </form>
            -->
        </div>
    </div>
</nav>
{{! ---------------   END shared Berg header   --------------- }}
<div id="main">
    <div class="ym-wrapper">

    {{! ---------------   page specific content   --------------- }}

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
