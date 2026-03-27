class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.5.0-beta.1.tar.gz"
  sha256 "0fc4550bf15100c7b41414717c3805b5615e6b95816a3e7159a987521609cf29"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "tailscale"
  depends_on "curl"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.5.0-beta.1/tailroute-proxy-darwin-arm64"
        sha256 "afac361dc49b421e106196f8e128b2eb2b397de01c74ecfc837cc5169c63f6cc"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.5.0-beta.1/tailroute-proxy-darwin-amd64"
        sha256 "1e7b0b6a4190dc56bf865ec2b258d291054bb870366aa1607f9dba7d6931ce0f"
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
