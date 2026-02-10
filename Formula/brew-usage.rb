class BrewUsage < Formula
  desc "Homebrew Disk Usage Analyzer - Shows disk usage information for installed Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-usage#readme"
  url "https://github.com/shrwnsan/brew-usage/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "93c3abe136a946d8891d8433649cf0fa0082c84de458a41bc06431ac87af811c"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/brew-usage.git", branch: "main"

  def install
    bin.install "brew-usage"
    lib.install Dir["lib/*"]
  end

  test do
    # Test that the script runs and shows help
    system "#{bin}/brew-usage", "--help"
  end
end
