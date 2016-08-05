class Monteverdi2 < Formula
  ORFEO = "jctull/osgeo4mac/orfeo"
  OREFO_F = Formula[ORFEO]
  ORFEO_OPTS = Tab.for_formula(OREFO_F).used_options

  homepage "http://orfeo-toolbox.org/otb/monteverdi.html"
  url "https://git.orfeo-toolbox.org/monteverdi2.git/snapshot/8498ac0acf4a30bc033fe73ad0d4a469735a1a3c.tar.gz"
  sha256 "e5e6eebaa99bb323c6384febd4fbdeaaa7897e1f2103cecd1799cf91b697922d"
  version "3.4.0"

  depends_on "cmake" => :build
  depends_on "jctull/osgeo4mac/orfeo"
  depends_on "qt"
  depends_on "glew"
  depends_on "insighttoolkit"

  resource "qwt5" do
    # http://qwt.sourceforge.net/
    url "http://sourceforge.net/projects/qwt/files/qwt/5.2.3/qwt-5.2.3.tar.bz2"
    sha256 "37feaf306753230b0d8538b4ff9b255c6fddaa3d6609ec5a5cc39a5a4d020ab7"
  end

  def install
    # locally vendor older qwt 5.2.3
    qwt5 = libexec/"qwt5"
    qwt5.mkpath
    resource("qwt5").stage do
      inreplace "qwtconfig.pri" do |s|
        s.sub! "/usr/local/qwt-$$VERSION", qwt5
        s.sub! /(doc.path)/, "#\\1"
        s.sub! /\+(=\s*QwtDesigner)/, "-\\1"
      end
      system "qmake", "-config", "release"
      system "make", "install"
      system "install_name_tool", "-id",
             "#{qwt5}/lib/libqwt.5.dylib",
             "#{qwt5}/lib/libqwt.5.dylib"
    end

    args = std_cmake_args + %W[
      -DCMAKE_PREFIX_PATH=#{qwt5}
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # make command line utility launcher script
    envars = {
        :GDAL_DATA => "#{HOMEBREW_PREFIX}/share/gdal",
        :ITK_AUTOLOAD_PATH => "#{HOMEBREW_PREFIX}/lib/otb/applications"
    }
    # FIXME: the About... and Preferences... dialogs do not show up. Why?
    bin.env_script_all_files(libexec/"bin", envars)

    # Clean up library paths. There is probably a better way to do this...
    system "chmod", "+w", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_ApplicationsWrapper.3.2.0.dylib"
    system "install_name_tool", "-id", "@rpath/lib/otb/libMonteverdi_ApplicationsWrapper.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_ApplicationsWrapper.3.2.0.dylib"
    system "install_name_tool", "-add_rpath", "@loader_path/../..", "/usr/local/Cellar/monteverdi2/3.4.0/libexec/bin/monteverdi"
    system "install_name_tool", "-change", "@rpath/libMonteverdi_ApplicationsWrapper.3.2.dylib", "@rpath/lib/otb/libMonteverdi_ApplicationsWrapper.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/libexec/bin/monteverdi"
    system "chmod", "+w", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_Gui.3.2.0.dylib"
    system "install_name_tool", "-id", "@rpath/lib/otb/libMonteverdi_Gui.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_Gui.3.2.0.dylib"
    system "install_name_tool", "-change", "@rpath/libMonteverdi_Gui.3.2.dylib", "@rpath/lib/otb/libMonteverdi_Gui.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/libexec/bin/monteverdi"
    system "chmod", "+w", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_Core.3.2.0.dylib"
    system "install_name_tool", "-id", "@rpath/lib/otb/libMonteverdi_Core.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_Core.3.2.0.dylib"
    system "install_name_tool", "-change", "@rpath/libMonteverdi_Core.3.2.dylib", "@rpath/lib/otb/libMonteverdi_Core.3.2.0.dylib", "/usr/local/Cellar/monteverdi2/3.4.0/libexec/bin/monteverdi"
    system "install_name_tool", "-add_rpath", "@loader_path/.", "/usr/local/Cellar/monteverdi2/3.4.0/lib/otb/libMonteverdi_ApplicationsWrapper.3.2.0.dylib"
  end

  def caveats; <<-EOS.undent
      The default geoid to use in elevation calculations is available in the
      associated `orfeo` package install location:

        #{OREFO_F.opt_libexec}/default_geoid/egm96.grd

      The command line launch script launches the GUI, but some dialogs do not
      work correctly, e.g. About.. and Prefrences...; use the application bundle
      instead, e.g. Monteverdi2-x.x.app.

    EOS
  end
end
