class BrewUsage < Formula
  desc "Homebrew Disk Usage Analyzer - Shows disk usage information for installed Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-usage#readme"
  url "https://github.com/shrwnsan/brew-usage/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "dadaf1c0a433e08b53b745788a77c71c7e87b26562b15dde8f62bac8efb4e4f9"
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
