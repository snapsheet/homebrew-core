require "formula"
require_relative "../lib/sail/private_strategy"

class Sail < Formula
  desc "Lighting-fast cli middleware for Docker containers"
  homepage "https://github.com/bodyshopbidsdotcom/sail"
  url "https://github.com/bodyshopbidsdotcom/sail/releases/download/v1.0.1/sail-1.0.1.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "464c3ccaba19772dad74c6d59a8282a2c6446253a3541909f85581666a12ee58"
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