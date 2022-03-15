require "formula"
require_relative "../lib/sail/private_strategy"

class Sail < Formula
  desc "Lighting-fast cli middleware for Docker containers"
  homepage "https://github.com/raysn0w/sail"
  url "https://github.com/bodyshopbidsdotcom/sail/releases/download/v1.0.0/sail-1.0.0.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "50f22d0c6391ef18ecfa782a1316ba43df99c4fcfb079b4d65a328af569b95c1"
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