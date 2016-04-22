// Testing the maker program.

'use strict';

var assert = require('chai').assert;


suite('Testing the maker program.', function () {

    setup(function () {
        console.log('Selecting the second test case: /cgi-bin/brg/testcase.pl?TC=2');
        browser.url('http://bergcms.local/cgi-bin/brg/testcase.pl?TC=2');
        var opresult = browser.getText('#opresult');
        assert.equal(opresult, 'Result: ok.');
    });


    test('Execute maker and check the displayed result', function () {
        browser.url('http://bergcms.local/cgi-bin/brg/maker');

        var title = browser.getTitle();
        assert.equal(title, 'Gemeindeinformation - Generator - FeG Aachen');

        var resultText = browser.getText('#processing-result');
        assert.equal(resultText, 'Keine Fehler.');
        //assert.equal(resultText, '1 Fehler! Hinweise zu den Ursachen sollten sich weiter oben finden lassen.');
    });

});
