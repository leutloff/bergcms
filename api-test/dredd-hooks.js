
const hooks = require('hooks');
const http = require('http');

// Select article database before Dredd starts testing
hooks.beforeAll((transactions, done) => {
  http.get('http://bergcms.local/cgi-bin/brg/testcase.pl?TC=api', (res) => {
    console.log(`Got response: ${res.statusCode}`);
    // consume response body
    res.resume();
    done();
  }).on('error', (e) => {
    console.log(`Got error: ${e.message}`);
  });
});

// Called after Dredd finishes testing
//hooks.afterAll((transactions, done) => {
//  done();
//});


// After each test clear contents of the database (we want isolated tests)
//hooks.afterEach((transaction, done) => {
//  done();
//});


//hooks.before('Gist > Edit a Gist', (transaction, done) => {
//});
