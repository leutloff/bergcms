var username = process.env.SAUCE_USERNAME || "SAUCE_USERNAME";
var accessKey = process.env.SAUCE_ACCESS_KEY || "SAUCE_ACCESS_KEY";

var webdriver = require('wd')
  , assert = require('assert');

var browser = webdriver.remote(
  "ondemand.saucelabs.com"
  , 80
  , username
  , accessKey
);

browser.on('status', function(info){
  console.log('\x1b[36m%s\x1b[0m', info);
});

browser.on('command', function(meth, path){
    console.log(' > \x1b[33m%s\x1b[0m: %s', meth, path|| '');
});

var desired = {
    platform: 'LINUX',
    tags: ["maker"],
    name: "Testing the processing result of maker."
};

// var desired = {
//   browserName: 'iphone'
//   , version: '5.0'
//   , platform: 'Mac 10.6'
//   , tags: ["examples"]
//   , name: "This is an example test"
// }
// caps = {browserName: 'internet explorer'};
// caps.platform = 'Windows 8.1';
// caps.version = '11';

// caps = {browserName: 'chrome'};
// caps.platform = 'Windows 7';
// caps.version = '31';

// caps = {browserName: 'firefox'};
// caps.platform = 'Windows 7';
// caps.version = '25';

// caps = {browserName: 'firefox'};
// caps.platform = 'Linux';
// caps.version = '25';

// caps = {browserName: 'android'};
// caps.platform = 'Linux';
// caps.version = '4.0';
// caps['device-type'] = 'tablet';
// caps['device-orientation'] = 'portrait';

// browser.init(desired, function() {
//   browser.get("http://saucelabs.com/test/guinea-pig", function() {
//     browser.title(function(err, title) {
//       assert.ok(~title.indexOf('I am a page title - Sauce Labs'), 'Wrong title!');
//       browser.elementById('submit', function(err, el) {
//         browser.clickElement(el, function() {
//           browser.eval("window.location.href", function(err, href) {
//             assert.ok(~href.indexOf('guinea'), 'Wrong URL!');
//             browser.quit()
//           })
//         })
//       })
//     })
//   })
// })

browser.init(desired, function() {
    browser.get("http://aachen.local/cgi-bin/brg/maker", function() {
        browser.title(function(err, title) {
            assert.ok(~title.indexOf('Generator'), 'Wrong title - does not contain Generator!');
            browser.elementById('processing-result', function(err, el) {
                assert.ok(~text.indexOf('Keine Fehler.'), 'Maker has failed!');
                browser.quit()
            })
        })
    })
})
