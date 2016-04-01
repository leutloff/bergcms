// Testing the maker program.
//
// Call this script:
// mocha maker.js

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
    
    describe('Testing the maker program.', function() {
        
        test.it('Load page and check result', function() {
            driver.get('http://aachen.local/cgi-bin/brg/maker');
            
            driver.getTitle().then(function(title) {
                assert.equal(title, 'Gemeindeinformation - Generator - FeG Aachen');
            });                
            driver.findElement(webdriver.By.id('processing-result')).getText().then(function(text) {
                assert.equal(text, 'Keine Fehler.');
            });               
        });        
        
    });
});
