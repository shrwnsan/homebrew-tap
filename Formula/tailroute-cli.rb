class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "d9befeb753fdf6a6107ea5928c52e82cfa64d3eba6470f56f44e98f97925aff4"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "tailscale"
  depends_on "curl"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.6.0/tailroute-proxy-darwin-arm64"
        sha256 "0579a3f5a3c0769301a7166d43f376471ed725dd1195a5b8086a6fb4f2d4619c"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.6.0/tailroute-proxy-darwin-amd64"
        sha256 "660b9ca7c207aa080d468497b6cf77489204ef7ab6ef5275afd1839973f1cd81"
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

      Browser tunnels (v0.6.0): `tailroute tunnel add <peer>` publishes a
      peer's Tailscale Serve endpoint at https://<peer>.ts.net:<port> with
      valid TLS, in any browser, while the VPN stays connected.
    EOS
  end

  test do
    system "#{bin}/tailroute", "--version"
    system "#{bin}/tailroute", "--help"
  end
end
