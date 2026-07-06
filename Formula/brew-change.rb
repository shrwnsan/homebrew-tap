class BrewChange < Formula
  desc "Make informed updates - see what changed in your Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-change"
  url "https://github.com/shrwnsan/brew-change/archive/refs/tags/v1.10.1.tar.gz"
  sha256 "96e701b1e3c10a8093df4794a88844c99a165af3f12fa3f59c0e2ff853c78cc2"
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
