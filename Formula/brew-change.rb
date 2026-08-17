class BrewChange < Formula
  desc "Make informed updates - see what changed in your Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-change"
  url "https://github.com/shrwnsan/brew-change/archive/refs/tags/v1.12.1.tar.gz"
  sha256 "78e78a14e948c72e3b158d9ac1c5ccfbf4a510755a9c99e340eee6bf3e5b0ad9"
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
