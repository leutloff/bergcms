// Testing the classic main entry page.

'use strict';

var assert = require('chai').assert;


suite('Test the modules accessing the actual issue.', function () {

    setup(function () {
        console.log('Selecting the second test case: /cgi-bin/brg/testcase.pl?TC=2');
        browser.url('http://aachen.local/cgi-bin/brg/testcase.pl?TC=2');
        var opresult = browser.getText('#opresult');
        assert.equal(opresult, 'Result: ok.');
    });


    test('Actual issue - validate the contents of the main page', function () {
        browser.url('http://aachen.local/cgi-bin/brg/berg.pl');

        var title = browser.getTitle();
        assert.equal(title, 'Gemeindezeitungs-Generator');

        // <table border="0" class="suche" width="100%"><tr><th colspan="5">Gemeindezeitungs-Generator</th>
        var resultText = browser.getText('table.suche tr th');
        assert.equal(resultText[0], 'Gemeindezeitungs-Generator');

        // TODO check more of the content
        //browser.getTextContent()
    });

});
