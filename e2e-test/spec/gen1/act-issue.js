// Testing the classic main entry page.

'use strict';

var assert = require('chai').assert;


suite('Test the modules accessing the actual issue.', function () {

    setup(function () {
        console.log('Selecting the second test case: /cgi-bin/brg/testcase.pl?TC=2');
        browser.url('http://bergcms.local/cgi-bin/brg/testcase.pl?TC=2');
        var opresult = browser.getText('#opresult');
        assert.equal(opresult, 'Result: ok.');
    });


    test('Actual issue - validate the contents of the main page', function () {
        browser.url('http://bergcms.local/cgi-bin/brg/berg.pl');

        var title = browser.getTitle();
        assert.equal(title, 'Gemeindezeitungs-Generator');

        // <table border="0" class="suche" width="100%"><tr><th colspan="5">Gemeindezeitungs-Generator</th>
        var resultText = browser.getText('table.suche tr th');
        assert.equal(resultText[0], 'Gemeindezeitungs-Generator');


        // <tr><td><a href="?AW=berg&VFI=*gf dolist&VPI=!tToDo" title="01) Aufgabenliste des Redaktionsteams" >To-Do</a></td>
        var linkTitle = browser.getAttribute('=To-Do', 'title');
        assert.equal(linkTitle, '01) Aufgabenliste des Redaktionsteams');
        // <td><a href="/cgi-bin/brg/bgul.pl?" title="02) Bilder hochladen" >Bilder</a></td>
        var linkTitle = browser.getAttribute('=Bilder', 'title');
        assert.equal(linkTitle, '02) Bilder hochladen');
        // <td><a href="?AW=berg&VFI=*bcdei&VPI=!qbcdi" title="03) Alle Texte der Datenbank" >Alles</a></td>
        var linkTitle = browser.getAttribute('=Alles', 'title');
        assert.equal(linkTitle, '03) Alle Texte der Datenbank');
        // <td><a href="?AW=berg&VFI=!bcdei&VPI=!qi !-!tchanged" title="04) zuletzt ge&auml;nderte Texte" >bearbeitet</a></td>
        var linkTitle = browser.getAttribute('=bearbeitet', 'title');
        assert.equal(linkTitle, '04) zuletzt geänderte Texte');
        // <td><a href="?AW=berg&VFI=!bcdei -\t\-\d{1,3}\t&VPI=!qbcdi !tactive" title="05) nur aktive Texte" >aktiv</a></td>
        var linkTitle = browser.getAttribute('=aktiv', 'title');
        assert.equal(linkTitle, '05) nur aktive Texte');
        // <td><a href="?AW=berg&VFI=!bcdei ^(1|9): -\s-\d&VPI=!qbcdi !tarticles" title="06) Artikelliste" >Artikel</a></td>
        var linkTitle = browser.getAttribute('=Artikel', 'title');
        assert.equal(linkTitle, '06) Artikelliste');
        // <td><a href="?AW=berg&VFI=!bcdei ^2: -\s-\d&VPI=!qbcdi !toffers" title="07) Angebotsliste" >Angebote</a></td>
        var linkTitle = browser.getAttribute('=Angebote', 'title');
        assert.equal(linkTitle, '07) Angebotsliste');
        // <td><a href="?AW=berg&VFI=!bcdei ^3: -\s-\d&VPI=!qbcdi !tgroups" title="08) Hauskreisliste" >HKs</a></td>
        var linkTitle = browser.getAttribute('=HKs', 'title');
        assert.equal(linkTitle, '08) Hauskreisliste');
        // <td><a href="?AW=berg&VFI=!bcdei ^0:\w&VPI=!qbcdi !tconfig" title="09) Einstellungen (Basisdaten und Dokumenteneinstellungen)" >Einst.</a></td>
        var linkTitle = browser.getAttribute('=Einst.', 'title');
        assert.equal(linkTitle, '09) Einstellungen (Basisdaten und Dokumenteneinstellungen)');
        // <td><a href="?AW=bbup&VFI=!bcdei&VPI=!bcdeigx!-!tbackup" title="10) Backup-Archiv" >Backup</a></td>
        var linkTitle = browser.getAttribute('=Backup', 'title');
        assert.equal(linkTitle, '10) Backup-Archiv');
    });

    test('Actual issue - selecting the configaration', function () {
        browser.url('http://aachen.local/cgi-bin/brg/berg.pl');

        var title = browser.getTitle();
        assert.equal(title, 'Gemeindezeitungs-Generator');


        browser.click('=Einst.');// click on link named 'Einst.'


        // TODO verifyTextPresent: Ausgabe festlegen
        // TODO verifyTextPresent: Inhaltsverzeichnis

        // var resultText = browser.getText('table.suche tr th');
        // assert.equal(resultText[0], 'Gemeindezeitungs-Generator');

        // TODO check more of the content
        //browser.getTextContent()
    });

});
