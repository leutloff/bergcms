Changes
=======

This is a summary of the user visible or otherwise noteworthy changes.

Version 3.3.0
-------------

 - Replacing quotes is now working correctly in more cases.
 - Automatically add required LaTeX commands \documentclass and
   \begin{document} when they are missing.
 - German Umlauts are now correctly shown in the output of pdfLaTeX, too.
   Several changes required to make this finally happen: 
   font encoding in LaTeX, encoding translation within maker and using a 
   proper font for the processed document.
 - Generation of fonts can now be added to maker.
 - Removed LaTeX files that are already part of the texlive packages.
 - Add the existing documentation to the source code and build it during the 
   build process.


Version 3.2.3
--------------
 - Start with releases on GitHub.
 