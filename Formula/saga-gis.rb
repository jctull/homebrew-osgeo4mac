class SagaGis < Formula
  homepage "http://saga-gis.org"
  url "https://sourceforge.net/projects/saga-gis/files/SAGA%20-%202.3/SAGA%202.3.1/saga_2.3.1.tar.gz"
  sha256 "58f5c183f839ef753261a7a83c902ba9d67f814c5f21172aae02fcd4a29b9fc0"
  
  head "svn://svn.code.sf.net/p/saga-gis/code-0/trunk/saga-gis"

  option "with-app", "Build SAGA.app Package"

  depends_on :automake
  depends_on :autoconf
  depends_on :libtool
  depends_on "jctull/osgeo4mac/gdal"
  depends_on "jasper"
  depends_on "proj"
  depends_on "wxmac"
  depends_on "unixodbc" => :recommended
  depends_on "libharu" => :recommended
  # Vigra support builds, but dylib in saga shows 'failed' when loaded
  # Also, using --with-python will trigger vigra to be built with it, which
  # triggers a source (re)build of boost --with-python
  depends_on "vigra" => :optional
  depends_on "postgresql" => :optional
  depends_on :python => :optional
  depends_on "libgeotiff" if build.with? "liblas"

  def install
    args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-openmp
    ]

    args << "--disable-odbc" if build.without? "unixodbc"
    args << "--with-postgresql" if build.with? "postgresql"
    args << "--with-python" if build.with? "python"

    system "autoreconf", "-i"
    system "./configure", *args
    system "make", "install"

    if build.with? "app"
      # Based on original script by Phil Hess
      # http://web.fastermac.net/~MacPgmr/
      mkdir_p "#{buildpath}/SAGA.app/Contents/MacOS"
      mkdir_p "#{buildpath}/SAGA.app/Contents/Resources"

      (buildpath/"SAGA.app/Contents/PkgInfo").write "APPLSAGA"
      cp "#{buildpath}/saga_gui.icns", "#{buildpath}/SAGA.app/Contents/Resources/"
      ln_s "#{bin}/saga_gui", "#{buildpath}/SAGA.app/Contents/MacOS/saga_gui"

      config = <<-EOS.undent
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>English</string>
          <key>CFBundleExecutable</key>
          <string>saga_gui</string>
          <key>CFBundleIconFile</key>
          <string>saga_gui.icns</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundleName</key>
          <string>SAGA</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleSignature</key>
          <string>SAGA</string>
          <key>CFBundleVersion</key>
          <string>1.0</string>
          <key>CSResourcesFileMapped</key>
          <true/>
        </dict>
        </plist>
      EOS

      (buildpath/"SAGA.app/Contents/Info.plist").write config
      prefix.install "SAGA.app"

    end
  end

  def caveats
    if build.with? "app"
      <<-EOS.undent
      SAGA.app was installed in:
        #{prefix}

      Note that the SAGA GUI does not work very well yet.
      It has problems with creating a preferences file in the correct location and sometimes won't shut down (use Activity Monitor to force quit if necessary).
      EOS
    end
  end
end

