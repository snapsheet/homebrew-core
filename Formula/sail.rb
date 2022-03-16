require "formula"
require_relative "../lib/sail/private_strategy"

class Sail < Formula
  desc "Lighting-fast cli middleware for Docker containers"
  homepage "https://github.com/bodyshopbidsdotcom/sail"
  url "https://github.com/bodyshopbidsdotcom/sail/releases/download/v1.0.2/sail-1.0.2.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "81efa1ef7815a6fb9bd7e93df63cc193e6c4024ab334cfabfcd6a3b66b74302b"
  license "MIT"

  depends_on "jq"
  depends_on "coreutils"
  depends_on "python-yq"

  def install
    # Move everything under #{libexec}/
    libexec.install Dir["*"]

    # Then write executables under #{bin}/
    bin.write_exec_script (libexec/"sail")
  end

end