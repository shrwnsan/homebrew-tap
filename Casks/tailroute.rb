cask "tailroute" do
  version "0.8.19"
  sha256 "33933c5a04d6eb69770949261f2c74b4da28c7c4a425e1531d68711c435001a9"

  url "https://github.com/shrwnsan/tailroute-cli/releases/download/app-v#{version}/Tailroute-#{version}.dmg"
  name "Tailroute"
  desc "Automatic Tailscale + VPN coexistence tool"
  homepage "https://github.com/shrwnsan/tailroute-cli"

  livecheck do
    url "https://github.com/shrwnsan/tailroute-cli/releases"
    strategy :github_releases # scan all releases: the repo's *latest* is usually the CLI's, never the app's
    regex(/app-v(\d+(?:\.\d+)+)/i) # app-v tags only: plain v* tags are the CLI, not this cask
  end

  depends_on macos: :monterey # matches the bundle's LSMinimumSystemVersion (12.0)

  app "Tailroute.app"

  uninstall quit: "com.shrwnsan.tailroute"

  # No `auto_updates true`: the app cannot self-update yet. Flip it when
  # Sparkle lands (post Developer-ID cert, PRD-005 D9) so brew stops nagging.
end
