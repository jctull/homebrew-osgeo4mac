class Prepair < Formula
  homepage "https://github.com/tudelft-gist/prepair"
  # head only for gdal-2 support
  head "https://github.com/tudelft3d/prepair.git"

  depends_on "cmake" => :build
  depends_on "cgal"
  depends_on "jctull/osgeo4mac/gdal"

  def install
    libexec.install(%W[data icon.png]) # geojson sample data and project icon

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    mktemp do
      system "#{bin}/prepair", "--shpOut", "--ogr", "#{libexec}/data/CLC2006_180927.geojson"
    end
  end
end
