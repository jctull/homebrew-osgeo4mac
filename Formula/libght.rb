class Libght < Formula
  homepage "https://github.com/pramsey/libght/"
  url "https://github.com/pramsey/libght/archive/v0.1.0.tar.gz"
  sha256 "3af40719bcb59785a2927ff95524ef9c961304c3b6522172036b66a1991164db"

  head "https://github.com/pramsey/libght.git", :branch => "master"

  option "with-tests", "Run unit tests after build, prior to install"

  depends_on "cmake" => :build
  depends_on "proj"
  depends_on "jctull/osgeo4mac/liblas"
  depends_on "cunit"

  def install
    ENV.libxml2
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      puts %x(test/cu_tester) if build.with? "tests"
      system "make", "install"
    end
  end

  test do
    assert_match "version #{version.to_s[0,3]}", %x(#{bin}/"las2ght")
  end
end
