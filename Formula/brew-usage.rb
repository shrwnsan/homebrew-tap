class BrewUsage < Formula
  desc "Homebrew Disk Usage Analyzer - Shows disk usage information for installed Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-usage#readme"
  url "https://github.com/shrwnsan/brew-usage/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "68a6d623744d3ee7712c04fbc4a8c19f89a35a9dafc86fdf4afcf24c07907f0e"
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
