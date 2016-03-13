Homebrew-osgeo4mac
==================

_NOTE_: On March 28, 2014, the original repository was moved from [dakcarto's][dakcarto] github 
account to [OSGeo's][osgeo-github]. On March 10, 2016, the OSGeo repo was forked by [me][jctull]
to provide a single repo with a current gdal-20, grass7, qgis-214. This was primarily for
my personal use, but I wanted it to be available for all in the OSGeo community. My ruby 
and homebrew coding is rudimentary at best, so there are some inelegant workarounds to make
my life easier. Please feel free to improve things and provde pull request's against this
repo.

This is a Mac [homebrew][] formula tap for maintaining a STABLE work environment for the
[OSGeo.org][osgeo] geospatial toolset. This includes formulae that may not be specifically
for an OSGeo project, but do extend the toolset's functionality.

These formulae *may* provide multiple versions of existing packages in the
[main homebrew taps][taps]. Such formulae are to temporarily ensure stability for
the toolset, currency in formulae that have languished in the main repo, or to add
extra options not found in the main taps.

How do I install these formulae?
--------------------------------
Just `brew tap jctull/osgeo4mac` and then `brew install <formula>`.

If you have _previously_ tapped the **dakcarto/osgeo4mac** repository  or the
**homebrew/osgeo4mac** repository do:

```
brew untap dakcarto/osgeo4mac
brew untap osgeo/osgeo4mac
brew tap jctull/osgeo4mac
brew tap --repair
```

Further, I wanted my gdal to take precedence over **Homebrew/homebrew/gdal**, but
simply pointing to **jctull/osgeo4mac/gdal-20** in my formulae was not working
because homebrew traverses dependencies and was trying to install gdal from 
core Homebrew that was woefully out of date. To make things work for me, I took
all formulae that use gdal and put them in **jctull/osgeo4mac**, specifically
pointed them at **jctull/osgeo4mac/gdal**, and then pinned my tap so it would
shadow formulae from **Homebrew/homebrew** or elsewhere. You can do this with:

```
brew tap-pin jctull/osgeo4mac
```

You can install formula from the tap explicitly, once tapped, with:

```
brew install jctull/osgeo4mac/<formula>
```

You can also install via URL:

```
brew install https://raw.github.com/jctull/homebrew-osgeo4mac/master/<formula>.rb
```

I want to acknowledge others that are likely much more competent than I am with
ruby coding and more knowledgaeble about the nuances of the [homebrew][] package 
management system. [Larry Shaffer][dakcarto] pioneered the osgeo4mac repo and came up 
with the bulk of the code to make life much simpler for Mac osgeo users. Sadly, his 
presence has diminished of late, thus my undertaking of this fork. [Rainer M. Krug][rkrug]
updated the [grass][] formula, and I tweaked it a tiny bit to suit my needs. 
Similarly, [Matthias Kuhn][m-kuhn] has been updating the [qgis][] packages, and 
I made some minor modifications to those as well.

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[homebrew]:http://brew.sh
[osgeo]:http://osgeo.org
[taps]:https://github.com/Homebrew/homebrew-versions
[wiki]:https://github.com/Homebrew/homebrew/wiki
[grass]:http://grass.osgeo.org
[qgis]:http://qgis.org
[dakcarto]:https://github.com/dakcarto
[jctull]:https://github.com/jctull
[m-kuhn]:https://github.com/m-kuhn
[rkrug]:https://github.com/rkrug
[osgeo-github]:https://github.com/OSGeo
