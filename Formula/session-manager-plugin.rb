# A clone of https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/session-manager-plugin.rb
# implemented here so it can be used as a dependency for other Formulae.
# This formula only installs the client.
SESSION_MANAGER_PLUGIN_VERSION = '1.2.295.0'
class SessionManagerPlugin < Formula
  version SESSION_MANAGER_PLUGIN_VERSION
  desc 'Plugin for AWS CLI to start and end sessions that connect to managed instances'
  homepage 'https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html'

  on_macos do
    sha256 'acec1d7dcddb81c6eb1bd29eb137609e9bb2421196f27b1aa3a800fc48277da2'
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/#{version}/mac/sessionmanager-bundle.zip",
        verified: 's3.amazonaws.com/session-manager-downloads/'
  end

  on_linux do 
    sha256 '12bcbec7d394275c2085d610fdbd53171c9083b3abf332d90baf3bcc3e730d2c'
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/#{version}/ubuntu_64bit/session-manager-plugin.deb",
        verified: 's3.amazonaws.com/session-manager-downloads/'
  end

  livecheck do
    url :homepage
    regex(%r{<td>\s*v?(\d+(?:\.\d+)+)\s*</td>}i)
  end

  def plugin_path
    '/usr/local/sessionmanagerplugin'
  end

  def symlink_path
    '/usr/local/bin/session-manager-plugin'
  end

  def fail_if_already_installed
    if Dir.exist?(self.plugin_path) || File.exist?(self.symlink_path)
      error_message = [
        "Existing installation found in #{self.plugin_path}. Run the following and try the installation again:",
        "  sudo rm -rf #{self.plugin_path} #{self.symlink_path}"
      ]
      odie(error_message.join("\n"))
    end
  end

  def install
    self.fail_if_already_installed

    on_macos do
      bin.install "bin/session-manager-plugin"
      prefix.install %w[LICENSE VERSION]
    end

    on_linux do
      system 'ar', 'vx', 'session-manager-plugin.deb'
      system 'tar', 'xvf', 'control.tar.gz'
      system 'tar', 'xvf', 'data.tar.gz'
    end

    prefix.install Dir[".#{self.plugin_path}/*"]
  end

  test do
    assert_match SESSION_MANAGER_PLUGIN_VERSION, shell_output('session-manager-plugin --version').strip
  end
end
