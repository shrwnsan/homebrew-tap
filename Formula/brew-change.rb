class BrewChange < Formula
  desc "Make informed updates - see what changed in your Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-change"
  url "https://github.com/shrwnsan/brew-change/archive/refs/tags/v1.11.5.tar.gz"
  sha256 "a428169bcf0d1765ac937e2cd410c36d34db84bd60d0d9d115acfaaac7d2f67f"
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
