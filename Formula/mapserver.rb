class Mapserver < Formula
  desc "Publish spatial data and interactive mapping apps to the web"
  homepage "http://mapserver.org/"
  url "http://download.osgeo.org/mapserver/mapserver-7.0.1.tar.gz"
  sha256 "2c9567e59ae3ebd99bb645740485be6a25798b8b57f93ca3413a3e0369a1bd8f"

  bottle do
    cellar :any
    sha256 "8bfa96a50ee83117bd929afc4ed1c6ce3e9e82a7e6da6328e4ca500c4fbb096d" => :yosemite
    sha256 "7ed6da72cbb724c1dfe92cc701bf292ddac02788dc7976f7a81e5e367b472262" => :mavericks
    sha256 "28b3fbf520436359a81d6b0a6875c30cb6f8bdb147ebc14f5860f7cf2c61ad47" => :mountain_lion
  end

  option "with-php", "Build PHP MapScript module"
  option "with-postgresql", "Build support for PostgreSQL as a data source"
  option "with-kml", "Build support for kml"
  option "with-python", "Build support for python"
  option "with-cairo", "Build cairo support"

  env :userpaths

  depends_on "cmake" => :build
  depends_on "doxygen"
  depends_on "fcgi"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "fribidi"
  depends_on "swig" => :build
  depends_on "giflib"
  depends_on "gd"
  depends_on "proj"
  depends_on "jctull/osgeo4mac/gdal"
  depends_on "geos"
  depends_on "libpqxx"
  depends_on "harfbuzz"
  depends_on "postgresql" => :optional
  depends_on "cairo" => :optional

  def install
    args = [
      "-DWITH-PROJ=ON",
      "-DWITH-GDAL=ON",
      "-DWITH-OGR=ON",
      "-DWITH-CURL=ON",
      "-DWITH-WFS=ON",
      "-DWITH-GEOS=ON",
      "-DWITH-FASTCGI=ON"
    ]

    args << "-DWITH-PHP=ON" if build.with? "php"
    args << "-DWITH-CAIRO=ON" if build.with? "cairo"
    args << "-DWITH-POSTGIS=ON" if build.with? "postgresql"
    args << "-DWITH-KML=ON" if build.with? "kml"

    mkdir "build" do
      system "cmake","..", *std_cmake_args, *args
      system "make"
      system "make", "install"
   end
  end

  def caveats; <<-EOS.undent
    The Mapserver CGI executable is #{bin}/mapserv

    If you built the PHP option:
      * Add the following line to php.ini:
        extension="#{prefix}/php_mapscript.so"
      * Execute "php -m"
      * You should see MapScript in the module list
    EOS
  end

  test do
    system "#{bin}/mapserver-config", "--version"
  end
end
