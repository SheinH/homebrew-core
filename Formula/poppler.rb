class Poppler < Formula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "https://poppler.freedesktop.org/"
  url "https://poppler.freedesktop.org/poppler-0.73.0.tar.xz"
  sha256 "e44b5543903128884ba4538c2a97d3bcc8889e97ffacc4636112101f0238db03"
  head "https://anongit.freedesktop.org/git/poppler/poppler.git"

  bottle do
    rebuild 1
    sha256 "a93b5680cc8364b828e6d40e41f0f164eea9b99bd75eaa77ac76a53c0623c6e6" => :mojave
    sha256 "582e88e9d6f621b917b9921af5670ffc309ffa8cb491ae67c5a5440bea3185b9" => :high_sierra
    sha256 "f534c06582c5d85a2784694ac96d1ccae486c8f6d65f593ad4a94a38bc01a1da" => :sierra
    sha256 "c313d23d13579179a7f11773a1b253f6684c0e6dd7654c5746d01514c7464492" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "nss"
  depends_on "openjpeg"
  depends_on "qt"
  depends_on "curl" unless OS.mac?

  conflicts_with "pdftohtml", "pdf2image", "xpdf",
    :because => "poppler, pdftohtml, pdf2image, and xpdf install conflicting executables"

  resource "font-data" do
    url "https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz"
    sha256 "1f9c7e7de9ecd0db6ab287349e31bf815ca108a5a175cf906a90163bdbe32012"
  end

  def install
    ENV.cxx11

    args = std_cmake_args + %w[
      -DBUILD_GTK_TESTS=OFF
      -DENABLE_CMS=lcms2
      -DENABLE_GLIB=ON
      -DENABLE_QT5=ON
      -DENABLE_UNSTABLE_API_ABI_HEADERS=ON
      -DWITH_GObjectIntrospection=ON
    ]

    system "cmake", ".", *args
    system "make", "install"
    system "make", "clean"
    system "cmake", ".", "-DBUILD_SHARED_LIBS=OFF", *args
    system "make"
    lib.install "libpoppler.a"
    lib.install "cpp/libpoppler-cpp.a"
    lib.install "glib/libpoppler-glib.a"
    resource("font-data").stage do
      system "make", "install", "prefix=#{prefix}"
    end

    if OS.mac?
      libpoppler = (lib/"libpoppler.dylib").readlink
      [
        "#{lib}/libpoppler-cpp.dylib",
        "#{lib}/libpoppler-glib.dylib",
        "#{lib}/libpoppler-qt5.dylib",
        *Dir["#{bin}/*"],
      ].each do |f|
        macho = MachO.open(f)
        macho.change_dylib("@rpath/#{libpoppler}", "#{lib}/#{libpoppler}")
        macho.write!
      end
    end

    # fix gobject-introspection support
    # issue reported upstream as https://gitlab.freedesktop.org/poppler/poppler/issues/18
    # patch attached there does not work though...
    inreplace share/"gir-1.0/Poppler-0.18.gir", "@rpath", lib.to_s if OS.mac?
    system "g-ir-compiler", "--output=#{lib}/girepository-1.0/Poppler-0.18.typelib", share/"gir-1.0/Poppler-0.18.gir"
  end

  test do
    system "#{bin}/pdfinfo", test_fixtures("test.pdf")
  end
end
