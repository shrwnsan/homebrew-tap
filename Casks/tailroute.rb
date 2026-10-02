cask "tailroute" do
  version "0.8.16"
  sha256 "c98739b39f20e819855a66915b57f847fa2acbc50717b3099398868e855bfe6e"

  url "https://github.com/shrwnsan/tailroute/releases/download/app-v#{version}/Tailroute-#{version}.dmg"
  name "Tailroute"
  desc "Automatic Tailscale + VPN coexistence tool"
  homepage "https://github.com/shrwnsan/tailroute"

  livecheck do
    url "https://github.com/shrwnsan/tailroute/releases"
    regex(%r{/releases/tag/app-v(\d+(?:\.\d+)+)}i) # app-v tags only: plain v* tags are the CLI, not this cask
  end

  depends_on :macos

  app "Tailroute.app"

  uninstall quit: "com.shrwnsan.tailroute"

  # No `auto_updates true`: the app cannot self-update yet. Flip it when
  # Sparkle lands (post Developer-ID cert, PRD-005 D9) so brew stops nagging.
end
