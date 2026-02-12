class Glow < Formula
  desc "Render markdown on the CLI, with pizzazz!"
  homepage "https://github.com/charmbracelet/glow"
  url "https://github.com/shrwnsan/glow/archive/refs/tags/v2.1.2.tar.gz"
  sha256 "adb941ca808a0707797af6a8a0d4d3c81812b7270ccea26e22bd6da652a8c63f"
  license "MIT"

  depends_on "go" => :build

  bottle do
    root_url "https://github.com/shrwnsan/glow/releases/download/v2.1.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "75a8935ff7e94ac46a7b3d389022298b893adc617e889828f29f7859e48cb5fe"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "75a8935ff7e94ac46a7b3d389022298b893adc617e889828f29f7859e48cb5fe"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "75a8935ff7e94ac46a7b3d389022298b893adc617e889828f29f7859e48cb5fe"
    sha256 cellar: :any_skip_relocation, sonoma: "c9ce8439c58e5cd987a82d8f7192a5fda05052467cd6f40c89255b8f4e18bebd"
    sha256 cellar: :any_skip_relocation, ventura:    "c9ce8439c58e5cd987a82d8f7192a5fda05052467cd6f40c89255b8f4e18bebd"
    sha256 cellar: :any_skip_relocation, monterey:   "c9ce8439c58e5cd987a82d8f7192a5fda05052467cd6f40c89255b8f4e18bebd"
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
