Homebrew-osgeo4mac
==================

_NOTE_: On March 28, 2014, the original repository was moved from dakcarto's github 
account to OSGeo's. On March 10, 2016, the OSGeo repo was forked to provide a
repo to provide a single repo for gdal-20, grass7, qgis-214. This was primarily for
my (jctull) personal use. My ruby and homebrew coding is rudimentary, so there are
some inelegant workarounds to make my life easier. Please feel free to improve things.

Mac [homebrew][] formula tap for maintaining a STABLE work environment for the
OSGeo.org geospatial toolset. This includes formulae that may not be specifically
for an OSGeo project, but do extend the toolset's functionality.

These formulae *may* provide multiple versions of existing packages in the
[main homebrew taps][taps]. Such formulae are to temporarily ensure stability for
the toolset, or to add extra options not found in the main taps. After such
formulae are field-tested with the OSGeo toolset, pull requests will be
created at the relevant upstream taps (when appropriate); then, if the requests
are committed, the formulae removed from this tap.

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

````
brew tap-pin jctull/osgeo4mac
````

You can install formula from the tap explicitly, once tapped, with:

```
brew install jctull/osgeo4mac/<formula>
```

You can also install via URL:

```
brew install https://raw.github.com/jctull/homebrew-osgeo4mac/master/<formula>.rb
```

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[homebrew]:http://brew.sh
[taps]:https://github.com/Homebrew/homebrew-versions
[wiki]:https://github.com/Homebrew/homebrew/wiki
