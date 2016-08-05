class Taudem < Formula
  homepage "http://hydrology.usu.edu/taudem/taudem5/"
  url "https://github.com/dtarb/TauDEM/archive/v5.3.5.tar.gz"
  sha256 "816ef7797a60dd8f33539f2b854c276921991477a16da35404434ea4921f18b8"

  depends_on "cmake" => :build
  depends_on :mpi => [:cc, :cx]

  # Use CMakeLists.txt that understands shapelib
  patch :DATA

  def install
    cd "src"

    inreplace %W[commonLib.h linearpart.h] do |s|
      s.gsub! '"mpi.h"', "<mpi.h>"
    end

    inreplace "Node.cpp",'"stdlib.h"', "<stdlib.h>"
    inreplace "PeukerDouglas.cpp", '"ctime"', "<ctime>"

    args = std_cmake_args
#    mpi = Formula["open-mpi"]
#    args << "-DCMAKE_CXX_FLAGS=-I#{mpi.opt_prefix}/include"
#    args << "-DCMAKE_EXE_LINKER_FLAGS=-L#{mpi.opt_prefix}/lib -lmpi -lmpi_cxx"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end
end

__END__
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 41f484f..a13a235 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -1,28 +1,7 @@
-#  This file used for make on the CSDMS system
-#
-cmake_minimum_required(VERSION 2.6)
+cmake_minimum_required(VERSION 2.8.9)
+project(TauDEM)
 
-set (BUILD_SHARED_LIBS OFF)
-
-#SHAPEFILES includes all files in the shapefile library
-#These should be compiled using the makefile in the shape directory
-set (shape_srcs
-     shape/cell.cpp
-     shape/dbf.cpp
-     shape/exception.cpp
-     shape/field.cpp
-     shape/item.cpp
-     shape/point.cpp
-     shape/record.cpp
-     shape/shape.cpp
-     shape/shapefile.cpp
-     shape/shapemain.cpp
-     shape/shp_point.cpp
-     shape/shp_polygon.cpp
-     shape/shp_polyline.cpp
-     shape/ReadOutlets.cpp)
-
-#OBJFILES includes classes, structures, and constants common to all files
+set (shape_srcs ReadOutlets.cpp)
 set (common_srcs commonLib.cpp tiffIO.cpp)
 
 set (D8FILES aread8mn.cpp aread8.cpp ${common_srcs} ${shape_srcs})
@@ -59,8 +38,17 @@ set (SLOPEAVEDOWN SlopeAveDown.cpp SlopeAveDownmn.cpp ${common_srcs})
 set (STREAMNET streamnetmn.cpp streamnet.cpp
      ${common_srcs} ${shape_srcs})
 set (THRESHOLD Threshold.cpp Thresholdmn.cpp ${common_srcs})
-#set (READTIFFILES ReadTif.cpp ReadTifmn.cpp ${common_srcs})
+set (GAGEWATERSHED gagewatershedmn.cpp gagewatershed.cpp ${common_srcs} ${shape_srcs})
+
+# MPI is required
+find_package(MPI REQUIRED)
+include_directories(${MPI_INCLUDE_PATH})
+set(CMAKE_CXX_FLAG ${CMAKE_CXX_FLAG} ${MPI_COMPILE_FLAGS})
+set(CMAKE_CXX_LINK_FLAGS ${CMAKE_CXX_LINK_FLAGS} ${MPI_LINK_FLAGS})
 
+# GDAL is required
+find_package(GDAL REQUIRED)
+include_directories(${GDAL_INCLUDE_DIR})
 
 add_executable (aread8 ${D8FILES})
 add_executable (areadinf ${DINFFILES})
@@ -87,11 +75,9 @@ add_executable (slopearearatio ${SLOPEAREARATIO})
 add_executable (slopeavedown ${SLOPEAVEDOWN})
 add_executable (streamnet ${STREAMNET})
 add_executable (threshold ${THRESHOLD})
-#add_executable (ReadTif ${READTIFFILES})
-#add_executable (compare ${OBJFILES} compare.cpp)
-#add_executable (extract ${OBJFILES} extract.cpp)
+add_executable (gagewatershed ${GAGEWATERSHED})
 
-install(TARGETS aread8 
+set (MY_TARGETS aread8 
                 areadinf
                 d8flowdir
                 d8flowpathextremeup
@@ -116,5 +102,9 @@ install(TARGETS aread8
                 slopeavedown
                 streamnet
                 threshold
-        DESTINATION bin)
+		gagewatershed)
 
+foreach( c_target ${MY_TARGETS} )
+    target_link_libraries(${c_target} ${MPI_LIBRARIES} ${GDAL_LIBRARY})
+    install(TARGETS ${c_target} DESTINATION bin)
+endforeach( c_target ${MY_TARGETS} )
