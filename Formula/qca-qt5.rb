class QcaQt5 < Formula
  homepage "http://qt-project.org/"
  # 15 KB, stripped down archive of just what's needed to compile driver
  url "http://delta.affinix.com/download/qca/2.0/qca-2.1.0.tar.gz"
  sha1 "2b582b3ccc7e6098cd14d6f52a829ae1539e9cc8"

  depends_on "qt5"
  depends_on "cmake" => :build

  patch :DATA

  def install
    ENV.deparallelize

    mkdir "build" do
      args = std_cmake_args
      args << "-D BUILD_TESTS:BOOL=OFF"
      args << "-D QCA_INSTALL_IN_QT_PREFIX:BOOL=ON"
      system "cmake", "..", *args
      #system "bbedit", "CMakeCache.txt"
      #raise
      system "make", "install"
    end
  end
end

__END__
diff --git a/include/QtCrypto/qca_basic.h b/include/QtCrypto/qca_basic.h
index 42808c5..e0c6cbb 100644
--- a/include/QtCrypto/qca_basic.h
+++ b/include/QtCrypto/qca_basic.h
@@ -35,6 +35,8 @@
 
 #include "qca_core.h"
 
+#include <QIODevice>
+
 // Qt5 comes with QStringLiteral for wrapping string literals, which Qt4 does
 // not have. It is needed if the headers are built with QT_NO_CAST_FROM_ASCII.
 // Defining it here as QString::fromUtf8 for convenience.
