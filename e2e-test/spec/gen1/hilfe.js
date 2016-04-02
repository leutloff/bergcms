// Testing the static german help page.

'use strict';

var assert = require('chai').assert;

suite('Testing the static german help page.', function() {
    
    setup(function() {
        //console.log('--setup--');
        //this.timeout(60000); // some time is needed for the browser start up, on my system 3000 should work, too.
        console.log('/hilfe.html');
        browser.url('/hilfe.html')
    });
    
    test('checks the title only', function() {
        var title = browser.getTitle();
        console.log('1 Title was: ' + title);
        assert.strictEqual(title, 'Dokumentation - Gemeindezeitungs-Generator');
    });
    
});
