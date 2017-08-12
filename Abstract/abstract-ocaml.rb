# Mostly from homebrew-core/Formula/ocaml.rb
require "formula"

class AbstractOCaml < Formula
  def self.init
    desc "General purpose programming language in the ML family"
    homepage "https://ocaml.org/"
    head "https://github.com/ocaml/ocaml.git"

    pour_bottle? do
      # The ocaml compilers embed prefix information in weird ways that the default
      # brew detection doesn't find, and so needs to be explicitly blacklisted.
      reason "The bottle needs to be installed into /usr/local."
      satisfy { HOMEBREW_PREFIX.to_s == "/usr/local" }
    end

    bottle do
      cellar :any_skip_relocation
      sha256 "0aa92cba5d37a2dd0625b0210a09f12218443c9c806ee04a9988a1041a54b5bc" => :sierra
      sha256 "58675349ab224e93c8f9470e98277526b2aafd3721f684ac451a3a1e187ec9f7" => :el_capitan
      sha256 "a8b02428804a20627265ba737aca7800eb565907c1d07bc8bbcf68afedb97cb1" => :yosemite
    end

    option "with-x11", "Install with the Graphics module"
    option "with-flambda", "Install with flambda support"

    depends_on :x11 => :optional

    test do
      output = shell_output("echo 'let x = 1 ;;' | #{bin}/ocaml 2>&1")
      assert_match "val x : int = 1", output
      assert_match HOMEBREW_PREFIX.to_s, shell_output("#{bin}/ocamlc -where")
    end
  end
  
  def install
    ENV.deparallelize # Builds are not parallel-safe, esp. with many cores

    # the ./configure in this package is NOT a GNU autoconf script!
    args = ["-prefix", HOMEBREW_PREFIX.to_s, "-with-debug-runtime", "-mandir", man]
    args << "-no-graph" if build.without? "x11"
    args << "-flambda" if build.with? "flambda"
    system "./configure", *args

    system "make", "world.opt"
    system "make", "install", "PREFIX=#{prefix}"
  end

end