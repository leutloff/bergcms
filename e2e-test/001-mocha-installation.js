// simple test - this will succeed for correct mocha installation.

var assert = require("assert")

suite('Show correct mocha installation', function(){
    test('Therefore a simple use of #indexOf()', function(){
        assert.equal(-1, [1,2,3].indexOf(5));
        assert.equal(-1, [1,2,3].indexOf(0));
    });
});
