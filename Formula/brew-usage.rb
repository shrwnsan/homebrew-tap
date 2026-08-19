class BrewUsage < Formula
  desc "Homebrew Disk Usage Analyzer - Shows disk usage information for installed Homebrew packages"
  homepage "https://github.com/shrwnsan/brew-usage#readme"
  url "https://github.com/shrwnsan/brew-usage/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "78311d06c2b65c44618e447d69d22840a296da3af8f54f8dbf69da03570e5bff"
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
