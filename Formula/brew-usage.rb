class BrewUsage < Formula
  desc "Homebrew Disk Usage Analyzer - Shows disk usage information for installed Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-usage#readme"
  url "https://github.com/shrwnsan/brew-usage/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "c46922f93fa50fdad6159f8bb804b02f2e0af8bffb865f0a642da5772f759811"
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
