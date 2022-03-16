require "formula"
require_relative "../lib/sail/private_strategy"

class Sail < Formula
  desc "Lighting-fast cli middleware for Docker containers"
  homepage "https://github.com/bodyshopbidsdotcom/sail"
  url "https://github.com/bodyshopbidsdotcom/sail/releases/download/v1.0.3/sail-1.0.3.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "c9700eef7c43c8c15705ab32e178ee6996a0a1e45154f3c4484bb23060aea564"
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