class Glow < Formula
  desc "Render markdown on the CLI, with pizzazz!"
  homepage "https://github.com/shrwnsan/glow"
  url "https://github.com/shrwnsan/glow/archive/refs/tags/v2.1.2.tar.gz"
  sha256 "adb941ca808a0707797af6a8a0d4d3c81812b7270ccea26e22bd6da652a8c63f"
  license "MIT"

  depends_on "go" => :build

  bottle do
    root_url "https://github.com/shrwnsan/glow/releases/download/v2.1.2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0836701511d7add7bc91732b73a4e37f0646502e242488e7ea1937043a66a50e"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.Version=#{version}")

    generate_completions_from_executable(bin/"glow", "completion")
  end

  test do
    test_file = testpath/"test.md"
    test_file.write <<~EOS
      # header

        **bold**

        ```
        code
        ```
    EOS

    # failed with Linux CI run, but works with local run
    # https://github.com/charmbracelet/glow/issues/454
    if OS.linux?
      system bin/"glow", test_file
    else
      assert_match "# header", shell_output("#{bin}/glow #{test_file}")
    end
  end
end
