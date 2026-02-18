class Tailroute < Formula
  desc "Automatic Tailscale + VPN coexistence on macOS"
  homepage "https://github.com/shrwnsan/tailroute"
  url "https://github.com/shrwnsan/tailroute/releases/download/v0.2.0/Tailroute-0.2.0.dmg"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "Apache-2.0"

  livecheck do
    url :homepage
    regex(/^v?(\d+(?:\.\d+)*)$/i)
  end

  app "Tailroute"

  def post_install
    # Register launchd plist for background operation
    plist_path = "/Library/LaunchDaemons/com.shrwnsan.tailroute.plist"
    
    unless File.exist?(plist_path)
      # LaunchDaemon plist for v0.2.0
      plist_content = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.shrwnsan.tailroute</string>
            <key>ProgramArguments</key>
            <array>
                <string>#{opt_prefix}/Tailroute.app/Contents/MacOS/tailroute</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
            <key>StandardOutPath</key>
            <string>/var/log/tailroute.out</string>
            <key>StandardErrorPath</key>
            <string>/var/log/tailroute.err</string>
            <key>UserName</key>
            <string>root</string>
        </dict>
        </plist>
      PLIST
      
      File.write(plist_path, plist_content)
      system("launchctl", "load", plist_path)
    end
  end

  def post_uninstall
    # Clean up launchd plist
    plist_path = "/Library/LaunchDaemons/com.shrwnsan.tailroute.plist"
    if File.exist?(plist_path)
      system("launchctl", "unload", plist_path)
      File.delete(plist_path)
    end
  end

  test do
    assert_predicate app/"Contents/MacOS/tailroute", :exist?
    assert_predicate app/"Contents/Info.plist", :exist?
  end
end
