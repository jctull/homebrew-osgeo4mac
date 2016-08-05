class GdalMrsid < Formula
  homepage "http://www.gdal.org/frmt_mrsid.html"
  url "http://download.osgeo.org/gdal/2.1.1/gdal-2.1.1.tar.gz"
  sha256 "55fc6ffbe76e9d2e7e6cf637010e5d4bba6a966d065f40194ff798544198236b"

  depends_on "jctull/osgeo4mac/mrsid-sdk"
  depends_on "jctull/osgeo4mac/gdal"

  def install
    mrsid_sdk_opt = Formula['mrsid-sdk'].opt_prefix
    (lib/"gdalplugins").mkpath
    plugins = {}
    lidar_args, mrsid_args = [], []

    # source files & cxx/ld flags
    # gdal_MG4Lidar.dylib
    Dir["frmts/mrsid_lidar/*.c*"].each { |src| lidar_args.concat %W[#{src}] }
    lidar_args.concat %W[
      -Iport -Igcore -Ifrmts -Ifrmts/mrsid_lidar
      -I#{mrsid_sdk_opt}/include/mrsid
    ]
    lidar_args.concat %W[-L#{mrsid_sdk_opt}/lib -llti_lidar_dsdk]
    plugins[:gdal_MG4Lidar] = lidar_args

    # gdal_MrSID.dylib
    Dir["frmts/mrsid/*.c*"].each { |src| mrsid_args.concat %W[#{src}] }
    mrsid_args.concat %W[
      -DMRSID_J2K=1
      -Iport -Igcore -Ifrmts -Ifrmts/mrsid
      -I#{mrsid_sdk_opt}/include/mrsid
    ]
    mrsid_args.concat %W[-L#{mrsid_sdk_opt}/lib -lltidsdk]
    plugins[:gdal_MrSID] = mrsid_args

    # plugin dylib
    # TODO: remove cxxstdlib_check, after LizardTech updates binaries for libc++
    #       https://www.lizardtech.com/forums/viewtopic.php?f=6&t=821
    cxxstdlib_check :skip
    plugins.each do |key, args|
      # TODO: can the compatibility_version be 1.10.0?
      args.concat %W[
        -dynamiclib
        -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/#{key.to_s}.dylib
        -current_version #{version}
        -compatibility_version #{version}
        -o #{lib}/gdalplugins/#{key.to_s}.dylib
        -undefined dynamic_lookup
      ]
      # build and install shared plugin
      system ENV.cxx, *args
    end

  end

  def caveats; <<-EOS.undent
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you will need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

      ============================== IMPORTANT ==============================
      If compiled using clang (default) on 10.9+ this plugin links to libc++
      (whereas MrSID libs/binaries link to libstdc++). This may lead to issues
      during usage, including crashes. Please report any issues to:
          https://github.com/osgeo/homebrew-osgeo4mac/issues

    EOS
  end
end
