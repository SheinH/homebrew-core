class Neofetch < Formula
  desc "fast, highly customisable system info script"
  homepage "https://github.com/dylanaraps/neofetch"
  url "https://github.com/dylanaraps/neofetch/archive/2.0.tar.gz"
  sha256 "27c208311d5aef8031987b689e3ba3f7663e5487273fa05698132a10a6ef4a48"
  head "https://github.com/dylanaraps/neofetch.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a72df966e14761f62349c46036ef147d4d3365477155b5c0cf6ff4f48693cc2d" => :sierra
    sha256 "a72df966e14761f62349c46036ef147d4d3365477155b5c0cf6ff4f48693cc2d" => :el_capitan
    sha256 "a72df966e14761f62349c46036ef147d4d3365477155b5c0cf6ff4f48693cc2d" => :yosemite
    sha256 "317676170469df11af58813607e5885249cd3ab6f717c19350a60c664a49502f" => :x86_64_linux
  end

  depends_on "screenresolution" => :recommended if OS.mac?
  depends_on "imagemagick" => :recommended

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/neofetch", "--test", "--config off"
  end
end
