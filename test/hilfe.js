// Testing the static german help page.
//
// Call this script:
// mocha hilfe.js

'use strict';

var assert = require("assert"),
    webdriver = require('selenium-webdriver');

var test = require('selenium-webdriver/lib/test'),
    Browser = test.Browser;

test.suite(function(env) {
    var browsers = env.browsers,
    waitForTitleToBe = env.waitForTitleToBe;
    
    var driver;
    beforeEach(function() { driver = env.driver; });
    
    describe('Testing the static german help page.', function() {
        
        test.it('Load static page and check title', function() {
            //console.log('http://aachen.local/brg/hilfe.html');
            driver.get('http://aachen.local/brg/hilfe.html');
            
            driver.getTitle().then(function(title) {
                assert.equal(title, 'Dokumentation - Gemeindezeitungs-Generator');
            });                
            //driver.findElement(webdriver.By.id('linkId')).click();
            //waitForTitleToBe('Dokumentation - Gemeindezeitungs-Generator');
        });        
        
    });
});
