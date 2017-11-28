# Slippers
Ruby utilities in support of Rant!Rave data

So many times I have missed IBM's Interactive System Productivity Facility (ISPF) over the years 
that this is a start on a replacement. Ruby, it seems, is perfect for doing it in. By "it" I mean
critical things like exclude all lines in the source then find all xyz in the excluded lines. Hugely
productive things that IBM is never going to publish and for good reason. ISPF should have been in 
Eclipse years ago.

Good old IBM, here is the documentation:
https://www.ibm.com/support/knowledgecenter/zosbasics/com.ibm.zos.zconcepts/zconcepts_138.htm

Granted, it is laughable in 2018 but at the bottom "exclude" is one true killer feature.

x Exclude a line, of more often a block xx to xx or an amount x999
then do a find all on xyz and you see

    102 lines excluded
    ----5----10----15--
    .....xyz...........
    4 lines excluded
    ----5----10----15--
    ..............xyz..

And so on. Super powerful stuff because it only shows you exactly what you need to see in the source.
