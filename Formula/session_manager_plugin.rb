# A clone of https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/session-manager-plugin.rb
# implemented here so it can be used as a dependency.
class SessionManagerPlugin < Formula
  version '1.2.295.0'
  desc 'Plugin for AWS CLI to start and end sessions that connect to managed instances'
  homepage 'https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html'

  on_macos do
    sha256 '67e527dd19b2ae6d5b5de62c75aedb4241f31b2ae177be3e118db8b4d067ad26'
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/#{version}/mac/session-manager-plugin.pkg",
        verified: 's3.amazonaws.com/session-manager-downloads/'
  end

  livecheck do
    url :homepage
    regex(%r{<td>\s*v?(\d+(?:\.\d+)+)\s*</td>}i)
  end

  def install
    on_macos do
      system 'tar', 'xvf', 'session-manager-plugin.pkg'
      system 'tar', 'xvf', 'Payload'
      prefix.install Dir['./usr/local/sessionmanagerplugin/*']
    end
  end
end
