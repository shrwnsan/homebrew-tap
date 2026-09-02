class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.8.6.tar.gz"
  sha256 "41efa4d5cf78d2dc5501c676b103e751214186c61155bcaa2fcec56ed9610967"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "curl"
  depends_on "tailscale"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.8.6/tailroute-proxy-darwin-arm64"
        sha256 "fc3bfd218141e75d9e8d3ef22279c98d34a79ae32e4c7e7a94c338cca3a20b37"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.8.6/tailroute-proxy-darwin-amd64"
        sha256 "195b0c7fd9ea1c0a6c8eaf517c860162c6174e0471a2b25cfbaa2942c0fd8fbe"
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

  # Daemon runs as root (MagicDNS toggles + /etc/hosts edits need it)
  service do
    run [opt_bin/"tailroute", "daemon"]
    run_type :immediate
    keep_alive true
    require_root true
    log_path var/"log/tailroute-daemon.log"
    error_log_path var/"log/tailroute-daemon.log"
  end

  def caveats
    <<~EOS
      To run tailroute as a daemon:

        sudo brew services start tailroute-cli

      Or manually:

        sudo tailroute daemon

      The SOCKS5 proxy (tailroute-proxy) is available at 127.0.0.1:1055
      when Tailscale and VPN are both active.

      The daemon runs as a root launchd service, so Homebrew takes
      root:admin ownership of this formula's Cellar paths. Upgrades and
      uninstall will prompt for sudo and may need those paths removed
      manually (`sudo brew services stop tailroute-cli` first).

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
