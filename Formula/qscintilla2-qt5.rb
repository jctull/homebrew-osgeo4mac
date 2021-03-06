class Qscintilla2Qt5 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://downloads.sf.net/project/pyqt/QScintilla2/QScintilla-2.8.4/QScintilla-gpl-2.8.4.tar.gz"
  sha256 "9b7b2d7440cc39736bbe937b853506b3bd218af3b79095d4f710cccb0fabe80f"

  option "without-plugin", "Skip building the Qt Designer plugin"

  depends_on :python => :recommended
  depends_on :python3 => :optional

  if build.with? "python3"
    depends_on "pyqt" => "with-python3"
  else
    depends_on "pyqt"
  end

  def install
    # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      spec = "unsupported/macx-clang-libc++"
    else
      spec = "macx-g++"
    end
    args = %W[-config release -spec #{spec}]

    cd "Qt4Qt5" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", "#{prefix}/trans"
        s.gsub! "$$[QT_INSTALL_DATA]", "#{prefix}/data"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
      end

      system "qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    # Add qscintilla2 features search path, since it is not installed in Qt keg's mkspecs/features/
    ENV["QMAKEFEATURES"] = "#{prefix}/data/mkspecs/features"

    cd "Python" do
      Language::Python.each_python(build) do |python, version|
        (share/"sip").mkpath
        system python, "configure.py", "-o", lib, "-n", include,
                         "--apidir=#{prefix}/qsci",
                         "--destdir=#{lib}/python#{version}/site-packages/PyQt4",
                         "--qsci-sipdir=#{share}/sip",
                         "--pyqt-sipdir=#{HOMEBREW_PREFIX}/share/sip",
                         "--spec=#{spec}"
        system "make"
        system "make", "install"
        system "make", "clean"
      end
    end

    if build.with? "plugin"
      mkpath prefix/"plugins/designer"
      cd "designer-Qt4Qt5" do
        inreplace "designer.pro" do |s|
          s.sub! "$$[QT_INSTALL_PLUGINS]", "#{lib}/qt4/plugins"
          s.sub! "$$[QT_INSTALL_LIBS]", "#{lib}"
        end
        system "qmake", "designer.pro", *args
        system "make"
        system "make", "install"
      end
    end
  end

  test do
    Pathname("test.py").write <<-EOS.undent
      import PyQt4.Qsci
      assert("QsciLexer" in dir(PyQt4.Qsci))
    EOS
    Language::Python.each_python(build) do |python, _version|
      system python, "test.py"
    end
  end
end
