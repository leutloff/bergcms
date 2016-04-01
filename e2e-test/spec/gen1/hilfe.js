// Testing the static german help page.
//
// Call this script:
// mocha test/hilfe.js

'use strict';

var chai = require('chai');
var assert = chai.assert, // TDD
expect = chai.expect, // BDD
webdriverio = require('webdriverio');

process.on('uncaughtException', function(e) {
    console.log(require('util').inspect(e, {showHidden:true}));
});

var options = {};

process.on('uncaughtException', function(e) {
    console.log(require('util').inspect(e, {showHidden:true}));
});

if ((process.env.TRAVIS === 'true') && (process.env.TEST_RUN_LOCAL !== 'true')) {
    var BROWSERNAME = (process.env._BROWSER || process.env.BROWSER || 'chrome').replace(/_/g,' ');
    var BROWSERVERSION = process.env._VERSION || process.env.VERSION || '*';
    var BROWSERPLATFORM = (process.env._PLATFORM || process.env.PLATFORM || 'Linux').replace(/_/g,' ');
    var BUILDID = process.env.TRAVIS_BUILD_ID || 'unknown-buildid';
    var TUNNELIDENTIFIER = process.env.TRAVIS_JOB_NUMBER || 'unknown-jobnumber';
    // select selenium version - for available versions see https://saucelabs.com/docs/additional-config#selenium-version
    var SELENIUMVERSION = '2.50.1';
    
    //    console.log('BROWSERNAME: ' + BROWSERNAME);
    //    console.log('BROWSERVERSION: ' + BROWSERVERSION);
    //    console.log('BROWSERPLATFORM: ' + BROWSERPLATFORM);
    //    console.log('BUILDID: ' + BUILDID);
    //    console.log('TUNNELIDENTIFIER: ' + TUNNELIDENTIFIER);
    
    var options = { desiredCapabilities: {
        browserName: BROWSERNAME,
        version: BROWSERVERSION,
        platform: BROWSERPLATFORM,
        tags: ['examples'],
        name: 'Run web app \'page test\' using webdriverio/Selenium.',
        build: BUILDID,
        'tunnel-identifier': TUNNELIDENTIFIER,
        'selenium-version': SELENIUMVERSION
    },
    // for w/o sauce connect
    //      host: 'ondemand.saucelabs.com',
    //      port: 80,
    // use with sauce connect:
    host: 'localhost',
    port: 4445,
    user: process.env.SAUCE_USERNAME,
    key: process.env.SAUCE_ACCESS_KEY,
    logLevel: 'verbose'
    };
}
else
{
    options = {
        desiredCapabilities: {
            browserName: 'chrome'
        }
    };
}


describe('Testing the static german help page.', function() {
    
    var client = {};
    
    before(function(done) {
        // console.log('--before--');
        this.timeout(60000);
        
        client = webdriverio.remote(options);
        
        // start the session
        client.init()
        .call(done);
    });
    
    after(function(done) {
        //console.log('--after--');
        client.end()
        .call(done);
    });
    
    beforeEach(function(done) {
        //console.log('--beforeEach--');
        this.timeout(60000); // some time is needed for the browser start up, on my system 3000 should work, too.
        // Navigate to the URL for each test
        console.log('http://aachen.local/brg/hilfe.html');
        client.url('http://aachen.local/brg/hilfe.html')
        .call(done);
    });
    
    it('checks the title only', function(done) {
        client.getTitle().then(function(title) {
            console.log('1 Title was: ' + title);
            assert.strictEqual(title, 'Dokumentation - Gemeindezeitungs-Generator');
        })
        .call(done);
    });
    
});
  