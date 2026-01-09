class BrewChange < Formula
  desc "Make informed updates - see what changed in your Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-change"
  url "https://github.com/shrwnsan/brew-change/archive/refs/tags/v1.5.6.tar.gz"
  sha256 "bfe642896543e20a0b4853afbb66e93d3e2cabd8965050b3e94b2cb972e1cd0d"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/brew-change.git", branch: "main"

  depends_on "curl"
  depends_on "jq"

  def install
    bin.install "brew-change"
    lib.install Dir["lib/*"]
  end

  test do
    # Test that the script runs and shows help
    system "#{bin}/brew-change", "--help"

    # Test that dependencies are available
    system "jq", "--version"
    system "curl", "--version"
  end
end
