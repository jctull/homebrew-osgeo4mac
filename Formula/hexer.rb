class Hexer < Formula
  homepage "https://github.com/hobu/hexer"
  url "https://github.com/hobu/hexer/archive/1.3.0.tar.gz"
  sha1 "29ba6b94690ec7a2faf425c232bba460b683efcf"

  head "https://github.com/hobu/hexer.git", :branch => "master"

  option "with-drawing", "Build Cairo-based SVG drawing"

  depends_on "cmake" => :build
  depends_on "jctull/osgeo4mac/gdal" => :recommended
  depends_on "cairo" if build.with? "drawing"

  def install
    args = std_cmake_args
    args << "-DWITH_DRAWING=TRUE" if build.with? "drawing"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "curse", "--version"
  end
end
