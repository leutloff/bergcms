// Testing the maker program.

'use strict';

var assert = require('chai').assert;


suite('Testing the maker program.', function() {
    
    test('Load page and check result', function() {
        browser.url('http://aachen.local/cgi-bin/brg/maker');
        
        var title = browser.getTitle();
        assert.equal(title, 'Gemeindeinformation - Generator - FeG Aachen');
        
        var resultText = browser.getText('#processing-result');
        assert.equal(resultText, 'Keine Fehler.');
    });        
    
});
