class BrewChange < Formula
  desc "Make informed updates - see what changed in your Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-change"
  url "https://github.com/shrwnsan/brew-change/archive/refs/tags/v1.21.0.tar.gz"
  sha256 "c3e1225350ff3e48586154efc34c561a6ba48e26888bf85898ae334ca6cc6245"
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
