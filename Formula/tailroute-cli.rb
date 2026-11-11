class TailrouteCli < Formula
  desc "Automatic Tailscale + VPN coexistence for macOS"
  homepage "https://tailroute.app"
  url "https://github.com/shrwnsan/tailroute-cli/archive/refs/tags/v0.9.5.tar.gz"
  sha256 "d2cfe7a0964751e20f6d5e659fb42c127cb9d05beb931927f96e38b0b109f7f1"
  license "Apache-2.0"
  head "https://github.com/shrwnsan/tailroute-cli.git", branch: "main"

  depends_on macos: :sequoia # uniform floor, 2026-10-07 (supersedes the CLI-12+/app-15+ split)
  depends_on "curl"
  depends_on "tailscale"

  resource "proxy" do
    on_macos do
      on_arm do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.9.5/tailroute-proxy-darwin-arm64"
        sha256 "61313135011724f98b31fd4e45c4313a9efc87bc63699a7ab6f161e88bbd3ce4"
      end
      on_intel do
        url "https://github.com/shrwnsan/tailroute-cli/releases/download/v0.9.5/tailroute-proxy-darwin-amd64"
        sha256 "42ad19b66f8910bf2e4f1d3a4256b3c60e20856a09437033b861c64951a7ec18"
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

    # Install log rotation config (the daemon stages it into /etc/newsyslog.d
    # at startup; without this line in the prefix the staging silently no-ops)
    (prefix/"etc/newsyslog.d").install "etc/newsyslog.d/tailroute.conf"
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
