// Testing the classic main entry page.

'use strict';

var assert = require('chai').assert;


suite('Tests related the actual issue string with an empty database.', function () {

    setup(function () {
        console.log('Selecting the second test case: /cgi-bin/brg/testcase.pl?TC=2');
        browser.url('http://bergcms.local/cgi-bin/brg/testcase.pl?TC=emptydb');
        var opresult = browser.getText('#opresult');
        assert.equal(opresult, 'Result: ok.');
    });


    test('Empty db - select and change ToDo', function () {
        browser.url('http://bergcms.local/cgi-bin/brg/berg.pl');

        //clickAndWait 	link=To-Do
        // <tr><td><a href="?AW=berg&VFI=*gf dolist&VPI=!tToDo" title="01) Aufgabenliste des Redaktionsteams" >To-Do</a></td>
        browser.click('=To-Do');

        // clickAndWait 	css=img[alt="Bearbeiten"] 
        browser.click('img[alt="Bearbeiten"]');
        var kopftext = browser.element('textarea[name="Kopftext"]');
        // type 	name=Kopftext 	Change TODO Test Case
        kopftext.setValue('Change TODO Test Case');
        // clickAndWait 	name=Submit
        browser.submitForm('form[name="editArticle"]');

        //verifyTextPresent 	Change TODO Test Case 	

        assert.isNotNull(browser.element('td*=Change TODO Test Case'));
    });

});
