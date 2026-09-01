class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "2fc84df3cddbbe14497617d6c48988317b9e88dcac331af52c1baa465c03e115"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "curl"
  depends_on "tailscale"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.1/tailroute-proxy-darwin-arm64"
        sha256 "ac28c118a00a0de2cb83cf6c255b7c7c31919dccfc5e58a0ca874524d80878d5"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.1/tailroute-proxy-darwin-amd64"
        sha256 "d9a485de7194a3f9fe6a72618b650cb67c9123e5c7d7259e3a583ba3c5e87df7"
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

      Browser tunnels (v0.7.0): `tailroute tunnel add <peer>` publishes a
      peer's Tailscale Serve endpoint at https://<peer>.ts.net:<port> with
      TLS verified against the peer's hostname, in any browser, while the
      VPN stays connected. `tunnel open <peer>` opens the URL; status
      reports per-forward health with repair commands.
    EOS
  end

  test do
    system "#{bin}/tailroute", "--version"
    system "#{bin}/tailroute", "--help"
  end
end
