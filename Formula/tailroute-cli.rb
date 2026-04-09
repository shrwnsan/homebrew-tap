class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.5.0-beta.2.tar.gz"
  sha256 "324b255a3e92f181168aae5575e63d72b9424a6915378dbb8deda8c97aedfe8f"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "tailscale"
  depends_on "curl"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.5.0-beta.2/tailroute-proxy-darwin-arm64"
        sha256 "3e19f3aaf30906f9eb6f923a70c10d61e09914f7984c90c0a73cccf09173444d"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.5.0-beta.2/tailroute-proxy-darwin-amd64"
        sha256 "601e15185505a1165176442a3aecc43af3a05983a2234a745b2fc14f8f0e021b"
      end
    end
  end

  def install
    # Install main CLI script as 'tailroute'
    bin.install "bin/tailroute.sh" => "tailroute"

    # Install library files
    (prefix/"lib").install Dir["bin/lib-*.sh"]

    # Install proxy binary
    resource("proxy").stage do
      filename = Dir["tailroute-proxy-darwin-*"].first
      bin.install filename => "tailroute-proxy" if filename
    end

    # Install launchd plist
    (prefix/"etc").install "etc/com.tailroute.daemon.plist"
  end

  def caveats
    <<~EOS
      To run tailroute as a daemon:

        sudo brew services start tailroute-cli

      Or manually:

        sudo tailroute daemon

      The SOCKS5 proxy (tailroute-proxy) is available at 127.0.0.1:1055
      when Tailscale and VPN are both active.
    EOS
  end

  test do
    system "#{bin}/tailroute", "--version"
    system "#{bin}/tailroute", "--help"
  end
end
