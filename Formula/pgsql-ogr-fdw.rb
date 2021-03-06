class PgsqlOgrFdw < Formula
  homepage "https://github.com/pramsey/pgsql-ogr-fdw"
  url "https://github.com/pramsey/pgsql-ogr-fdw.git", :branch => "master",
      :revision => "a0df7d1512b4b94ee26733d85481b69851047a46"
  version "0.0.0"

  def pour_bottle?
    # Postgres extensions must live in the Postgres prefix, which precludes
    # bottling: https://github.com/Homebrew/homebrew/issues/10247
    # Overcoming this will likely require changes in Postgres itself.
    false
  end

  # depends_on "pkg-config" => :build
  depends_on "postgis"
  depends_on "jctull/osgeo4mac/gdal"

  def install
    ENV.deparallelize

    system "make"

    # This includes PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the this formula's keg.
    # Right now, no items installed to Postgres keg need to be installed to `prefix`.
    # In the future, if `make install` installs things that should be in `prefix`
    # consult postgis formula to see how to split it up.
    system "make", "install"

    bin.install "ogr_fdw_info"
    prefix.install "data"
  end

  def caveats;
    pg = Formula["postgresql"].opt_prefix
    <<-EOS.undent
      For info on using extension, read the included REAMDE.md or visit:
        https://github.com/pramsey/pgsql-ogr-fdw

      PostGIS plugin libraries installed to:
        #{pg}/lib
      PostGIS extension modules installed to:
        #{pg}/share/postgresql/extension
    EOS
  end

  test do
    # test the sql generator for the extension
    data_sub = "data".upcase # or brew audit thinks there is a D A T A section
    sql_out = <<-EOS.undent
      CREATE SERVER myserver
        FOREIGN #{data_sub} WRAPPER ogr_fdw
        OPTIONS (
          datasource '#{prefix/"data"}',
          format 'ESRI Shapefile' );

      CREATE FOREIGN TABLE pt_two (
        fid integer,
        geom geometry,
        name varchar,
        age integer,
        height real,
        birthdate date )
        SERVER myserver
        OPTIONS ( layer 'pt_two' );
    EOS

    result = shell_output("ogr_fdw_info -s #{prefix/"data"} -l pt_two")
    assert_equal sql_out.strip, result.strip
  end
end
