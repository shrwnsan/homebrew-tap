class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "3d8f5ff92f6feb9360f0f5e93871905b9f0b96d617a4c2e8259eac49f5df4ac3"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "curl"
  depends_on "tailscale"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.0/tailroute-proxy-darwin-arm64"
        sha256 "2f0fed0a1f9f5163f81c79a78b4bed4a684b10a0aed0e6d23501178308f09e07"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.0/tailroute-proxy-darwin-amd64"
        sha256 "2f7c0eafac4b714c922176726e88dac467d0d12839e1938b654fd0c7ed74d717"
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
