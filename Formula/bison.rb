class Bison < Formula
  desc "Parser generator"
  homepage "https://www.gnu.org/software/bison/"
  url "https://ftp.gnu.org/gnu/bison/bison-3.3.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/bison/bison-3.3.1.tar.xz"
  sha256 "fd22fc5ed02b42c88fa0efc6d5de3face8dfb5e253bf97e632573413969bc900"

  bottle do
    sha256 "964051f0e9ada5e246ff7d3c9d920d9a7a0dc286e16f99f1274f9e084c0561ca" => :mojave
    sha256 "8fec340fa6ec103065bf955187a61322ee90f12825ce51fd2c1b23bba048fddb" => :high_sierra
    sha256 "96043bb1639a2e8c67ae1f407afc6a96f8929fa8dc188ce644fe51376d282fad" => :sierra
    sha256 "78d79d758c323f15eea646123ceb39a39f5ef664c26c976f537cd9efb6d4c9e8" => :x86_64_linux
  end

  keg_only :provided_by_macos, "some formulae require a newer version of bison"

  depends_on "m4" unless OS.mac?

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.y").write <<~EOS
      %{ #include <iostream>
         using namespace std;
         extern void yyerror (char *s);
         extern int yylex ();
      %}
      %start prog
      %%
      prog:  //  empty
          |  prog expr '\\n' { cout << "pass"; exit(0); }
          ;
      expr: '(' ')'
          | '(' expr ')'
          |  expr expr
          ;
      %%
      char c;
      void yyerror (char *s) { cout << "fail"; exit(0); }
      int yylex () { cin.get(c); return c; }
      int main() { yyparse(); }
    EOS
    system "#{bin}/bison", "test.y"
    system ENV.cxx, "test.tab.c", "-o", "test"
    assert_equal "pass", shell_output("echo \"((()(())))()\" | ./test")
    assert_equal "fail", shell_output("echo \"())\" | ./test")
  end
end
