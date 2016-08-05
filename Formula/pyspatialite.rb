require 'formula'

class Pyspatialite < Formula
  homepage 'http://code.google.com/p/pyspatialite/'
  # temporary download of source, prior to pyspatialite move to github
  url 'http://qgis.dakotacarto.com/osgeo4mac/pyspatialite-3.0.1.tar.gz'
  sha256 '81a3e4966fb6348802a985486cbf62e019a0fcb0a1e006b9522e8b02dc08f238'

  head 'https://code.google.com/p/pyspatialite/', :using => :hg

  depends_on :python
  depends_on 'geos'
  depends_on 'proj'
  depends_on 'sqlite'
  depends_on 'libspatialite'

  stable do
    patch do
      # Patch to work with libspatialite 4.x, drop amalgamation support, dynamically
      # link libspatialite and sqlite3, and fix redeclaration build error
      # Reported upstream: http://code.google.com/p/pyspatialite/issues/detail?id=15
      # (not tested/supported with HEAD builds)
      url "https://gist.github.com/dakcarto/7510460/raw/2e56dd217c19d8dd661e4d3ffb2b669f34da580b/pyspatialite-3.0.1-Mac-patch.diff"
      sha256 "8696caaadfc6edf9aa159fe61ed44ce1eac23da2fd68c242148fc2218e6c6901"
    end
  end

  def install
    # write setup.cfg
    (buildpath/'setup.cfg').write <<-EOS.undent
      [build_ext]
      include_dirs=#{HOMEBREW_PREFIX}/include/:#{HOMEBREW_PREFIX}/opt/sqlite/include/
      library_dirs=#{HOMEBREW_PREFIX}/lib:#{HOMEBREW_PREFIX}/opt/sqlite/lib
    EOS

    system 'python', 'setup.py', 'build'
    system 'python', 'setup.py', 'install', "--prefix=#{prefix}"
  end
end
