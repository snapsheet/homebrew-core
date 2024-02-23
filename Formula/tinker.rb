# Documentation: https://docs.brew.sh/Formula-Cookbook
#               https://rubydoc.brew.sh/Formula
# Resources: https://github.com/sportngin/brew-gem

require_relative '../lib/ruby_gems_download_strategy'
require_relative '../lib/ruby_manager'
require_relative '../lib/debug_tools'
require 'net/http'
require 'uri'

TINKER_VERSION = '1.0.1'.freeze

class Tinker < Formula
  include RubyManager
  include DebugTools

  desc 'Install the Tinker toolset.'
  homepage 'https://github.com/bodyshopbidsdotcom/tinker'
  url('tinker', using: RubyGemsDownloadStrategy)
  sha256 '18a9a4c47545a00060a586e2354c4a2f03836b9c7bf10a540787be3d2bf7bf2f' # .gem
  license 'MIT'
  version TINKER_VERSION

  # Build dependencies that will be used by RVM.
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "coreutils" => :build
  depends_on "libksba" => :build
  depends_on "libtool" => :build
  depends_on "libyaml" => :build
  depends_on "openssl@1.1" => :build
  depends_on "pkg-config" => :build
  depends_on "readline" => :build
  depends_on "zlib" => :build

  # Build dependencies that will be used by Rugged
  depends_on "cmake" => :build
  
  # Runtime dependencies that will be used by Tinker.
  depends_on "awscli" => "2"

  # Get the system home directory for the user installing Tinker. Attempting to find the home via
  # +path = `echo $HOME`+ will return the temporary path used while running this formula (same as
  # returned by the +pwd+ method).
  #
  # @return [String] Path to the +$HOME+ of the user running the formula.
  def user_home
    @user_home ||= `eval echo ~$USER`.strip
  end

  # Version of Ruby required to run Tinker. This is required for using the {RubyManager}.
  #
  # @return [String] Semantic version of Ruby runtime (+3.0.1+, etc).
  def ruby_version
    @ruby_version ||= metadata.required_ruby_version.to_s.split.last
  end

  # Metadata associated with the Tinker gem. Used to get dependencies, requirements, etc.
  #
  # @return [Object] Reference to metadata object loaded from a gem.
  def metadata
    @metadata ||= YAML.load(`tar -xOf #{tinker_gem_path} metadata.gz | gzip -dc`, permitted_classes: [Gem::Specification, Gem::Version, Gem::Dependency, Gem::Requirement, Gem::Platform, Time, Symbol])
  end

  # Find the path of the gem that will be installed by this formula.
  #
  # @return [String] Cached path to the installed gem.
  def tinker_gem_path
    @tinker_gem_path ||= HOMEBREW_CACHE.cd { "#{pwd}/#{name}-#{version}.gem" }
  end

  def tinker_env_vars
    ruby_environment.merge(
      'PATH' => "#{ruby_environment['PATH']}:\#{ENV['PATH']}",
      'TINKER_ENV' => 'production'
    )
  end

  # Get the path to installed gems so we can include them in the Tinker runtime before execution.
  #
  # @return [Array] List of paths to the +lib+ directories of installed gem dependencies.
  def installed_gem_lib_paths
    ruby_lib_paths = Dir.glob("#{gem_path}/gems/*/lib")
    # Need to fix the path for concurrent-ruby.
    ccrb = ruby_lib_paths.select { |path| path.include?('concurrent-ruby') }.first
    ruby_lib_paths.select { |path| !path.include?('concurrent-ruby') } + ["#{ccrb}/concurrent-ruby"]
  end

  # Use the methods in the {RubyManager} to create an environment for installing gems specifically
  # for use with this formula.
  def install_tinker_gem
    RubyGemsDownloadStrategy.gem_config_file do |_config_path|
      HOMEBREW_CACHE.cd do
        with_env(ruby_environment) do
          system('gem', 'install', cached_download)
        end
      end

      raise "gem install #{name} failed with status #{$?.exitstatus}" unless $?.success?
    end
  end

  # Create the binary executable entry points for all executables included with the Tinker gem.
  def create_bin_entrypoints
    metadata.executables.each do |exe|
      file = Pathname.new("#{gem_path}/#{metadata.bindir}/#{exe}")
      (bin + file.basename).open('w') do |f|
        f << <<~RUBY
          #!#{ruby_path}/bin/ruby --disable-gems
          #{tinker_env_vars.map { |k, v| "ENV['#{k}'] = \"#{v}\"" }.join("\n")}
          require 'rubygems'
          $:.unshift(#{installed_gem_lib_paths.map(&:inspect).join(',')})
          load "#{file}"
        RUBY
      end
    end
  end

  def install    
    setup_debug_tools if Context.current.debug?
    
    bin.rmtree if bin.exist?
    bin.mkpath

    log_path = if OS.mac?
      "#{user_home}/Library/Logs/Homebrew/tinker"
    elsif OS.linux?
      "#{user_home}/.cache/Homebrew/Logs/tinker"
    end

    ohai("Installing dedicated version of Ruby #{ruby_version}. This will take several minutes.")
    ohai("For detailed progress information, run the following in a new CLI:")
    ohai("  tail -f #{log_path}/01.rvm")
    install_ruby

    ohai("Installing ruby gem for #{name} #{version}.")
    ohai("For detailed progress information, run the following in a new CLI:")
    ohai("  tail -f #{log_path}/02.gem")
    install_tinker_gem

    ohai('Creating Tinker bin entrypoints.')
    create_bin_entrypoints
  end

  test do
    assert_match TINKER_VERSION, shell_output("tinker --version")
  end
end
