{{! berg_error_page.tpl - Template for an error page.

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
<html lang="de">
{{! TODO: include >BERG_HEAD aka berg_html_head.tpl }}
<head>
    <meta charset="utf-8"/>
    <title>{{TITLE}}</title>

    <!-- Mobile viewport optimisation -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- (en) Add your meta data here -->
    <!-- (de) Fuegen Sie hier ihre Meta-Daten ein -->

    <link href="/brg/css/flexible-grids.css" rel="stylesheet" type="text/css"/>
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
            <h1>Berg CMS</h1>
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
<div id="main">
    <div class="ym-wrapper">
        <h4>Verfügbare Ausgaben der Gemeindeinformation</h4>
        <ul>
        {{#ARCHIVE_LIST}}
        <li><a href="{{#ARCHIVE_REFERENCE}}">{{#ARCHIVE_NAME}}</a></li>
        {{/ARCHIVE_LIST}}
        </ul>
    </div>
</div>


<footer>
    <div class="ym-wrapper">
        <div class="ym-wbox">
            <p>© Christian Leutloff 2012 &ndash; Layout based on <a href="http://www.yaml.de">YAML</a></p>
        </div>
    </div>
</footer>

{{! full skip link functionality in webkit browsers }}
<script src="/brg/css/yaml/core/js/yaml-focusfix.js"></script>

</body>
</html>



</body>
</html>