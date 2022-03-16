require "formula"
require_relative "../lib/sail/private_strategy"

class Sail < Formula
  desc "Lighting-fast cli middleware for Docker containers"
  homepage "https://github.com/bodyshopbidsdotcom/sail"
  url "https://github.com/bodyshopbidsdotcom/sail/releases/download/v1.0.4/sail-1.0.4.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "93c6481b648535a7f21fec14c06f47c57e2e4a82087266113782d10ed2b64461"
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