class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://github.com/shrwnsan/tailroute-cli"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.7.7.tar.gz"
  sha256 "1ae696c0477fcc444285e25fb083313155255d1bb5347844a6f4fe6c5c00b996"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on "curl"
  depends_on "tailscale"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.7/tailroute-proxy-darwin-arm64"
        sha256 "2b6a083a388ee7b37183f71f7edc72bc0965bbee609026b2d29a703a3fb2e2d0"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.7.7/tailroute-proxy-darwin-amd64"
        sha256 "7b981ae6f88d5840c04c81ef3771527de95a47823c525ccd5d204324d881522d"
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
