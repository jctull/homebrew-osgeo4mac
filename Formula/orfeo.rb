class Orfeo < Formula
  desc "Library of image processing algorithms"
  homepage "https://www.orfeo-toolbox.org/otb/"
  url "https://git.orfeo-toolbox.org/otb.git/snapshot/6eb64b681b2ad044cbc106f0fd17265d0665fb10.tar.gz"
  sha256 "a7867abdad8a8044c10839c1d954e7800cb2ecb71ce9f9850f38d97bb71e0f16"

  depends_on "cmake" => :build
  depends_on :python => :optional
  depends_on "fltk"
  depends_on "jctull/osgeo4mac/gdal"
  depends_on "qt"
  depends_on "insighttoolkit"
  depends_on "open-scene-graph"
  depends_on "tinyxml"
  depends_on "glew"
  depends_on "curl"
  depends_on "opencv"
  depends_on "glfw3"

  option "examples", "Compile and install various examples"
  option "java", "Enable Java support"
  option "patented", "Enable patented algorithms"

  def install
    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DOTB_USE_EXTERNAL_FLTK=ON
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_BUILD_TYPE=Release
      -DOTB_WRAP_QT=ON
      -DOSSIM_LIBRARY=/usr/local/Cellar/ossim/1.9.0/Frameworks/ossim.framework/ossim
      -DOTB_BUILD_DEFAULT_MODULES=ON
      -DOTB_USE_QT4=ON
      -DOTB_USE_GLFW=ON
      -DOTB_USE_GLEW=ON
      -DOTB_USE_CURL=ON
      -DOTB_USE_OPENCV=ON
      -DOTB_USE_OPENGL=ON
    ]

    args << "-DBUILD_EXAMPLES=" + ((build.include? "examples") ? "ON" : "OFF")
    args << "-DOTB_WRAP_JAVA=" + ((build.include? "java") ? "ON" : "OFF")
    args << "-DOTB_USE_PATENTED=" + ((build.include? "patented") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if ((build.without? "python") ? "ON" : "OFF")
    
    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end
end
