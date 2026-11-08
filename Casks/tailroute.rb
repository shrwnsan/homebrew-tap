cask "tailroute" do
  version "0.8.21"
  sha256 "194ca02a11bc4dace62d0aa72f0c6551124e525041d0a3841d3a63ae586556db"

  url "https://github.com/shrwnsan/tailroute-cli/releases/download/app-v#{version}/Tailroute-#{version}.dmg"
  name "Tailroute"
  desc "Menu bar app for automatic Tailscale + VPN coexistence on macOS"
  homepage "https://tailroute.app"

  livecheck do
    url "https://github.com/shrwnsan/tailroute-cli/releases"
    strategy :github_releases # scan all releases: the repo's *latest* is usually the CLI's, never the app's
    regex(/app-v(\d+(?:\.\d+)+)/i) # app-v tags only: plain v* tags are the CLI, not this cask
  end

  # macOS 15+ floor (uniform, 2026-10-07). Since app-v0.8.20 the bundle's
  # LSMinimumSystemVersion (15.0) and the SPM manifest agree with this line,
  # so direct DMG downloads and the cask declare the same floor.
  depends_on macos: :sequoia

  app "Tailroute.app"

  caveats <<~EOS
    The app does not self-update yet; upgrades come via `brew upgrade --cask tailroute`.

    The app is not notarized yet, so macOS shows a "Not Opened" dialog the
    first time an installed or upgraded copy launches. Do not choose Move to
    Trash, which deletes the app. Choose Done, then open System Settings >
    Privacy & Security and click Open Anyway. If the app is already gone, run
    `brew reinstall --cask tailroute`.
  EOS

  uninstall quit: "com.shrwnsan.tailroute"

  # No `auto_updates true`: the app cannot self-update yet. Flip it when
  # Sparkle lands (post Developer-ID cert, PRD-005 D9) so brew stops nagging.
end
