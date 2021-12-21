# Documentation: https://docs.brew.sh/Formula-Cookbook
#               https://rubydoc.brew.sh/Formula
# Resources: https://github.com/sportngin/brew-gem

require_relative '../lib/ruby_gems_download_strategy'
require 'net/http'
require 'uri'

TINKER_VERSION = '0.2.1'.freeze

class Tinker < Formula
  desc 'Install the Tinker toolset.'
  homepage 'https://github.com/bodyshopbidsdotcom/tinker'
  url('tinker', using: RubyGemsDownloadStrategy)
  sha256 '2475ff57843484fe87d9314e174b92e7ead84033e00e046ec1cefe1bfbc655cc' # .gem
  license 'MIT'
  version TINKER_VERSION

  def setup_debug_tools
    Homebrew.install_gem_setup_path! 'pry'
    Homebrew.install_gem_setup_path! 'pry-byebug', executable: 'pry'
    require 'pry-byebug'
  end

  def install
    if Context.current.debug?
      setup_debug_tools
      @tap = CoreTap.instance unless tap?
    end

    # set GEM_HOME and GEM_PATH to make sure we package all the dependent gems
    # together without accidently picking up other gems on the gem path since
    # they might not be there if, say, we change to a different rvm gemset
    ENV['GEM_HOME'] = prefix.to_s
    ENV['GEM_PATH'] = prefix.to_s

    # Use /usr/local/bin at the front of the path instead of Homebrew shims,
    # which mess with Ruby's own compiler config when building native extensions
    ENV['PATH'] = ENV['PATH'].sub(HOMEBREW_SHIMS_PATH.to_s, '/usr/local/bin') if defined?(HOMEBREW_SHIMS_PATH)

    metadata = YAML.load(`tar -xOf #{name}-#{version}.gem metadata.gz | gzip -dc`)
    ruby_version = metadata.required_ruby_version.to_s.split.last
    ruby_bin = ''

    RubyGemsDownloadStrategy.gem_config_file do |_config_path|
      HOMEBREW_CACHE.cd do
        install_cmd = [
          'gem', 'install', cached_download,
          '--no-document',
          '--no-wrapper',
          '--no-user-install',
          '--install-dir', prefix,
          '--bindir', bin
        ]

        `bash --login -c 'rvm install #{ruby_version}'`
        `bash --login -c 'rvm use #{ruby_version} && #{install_cmd.join(' ')}'`
        ruby_bin = `bash --login -c 'rvm use #{ruby_version} > /dev/null && which ruby'`.strip
      end
    end

    raise "gem install #{name} failed with status #{$?.exitstatus}" unless $?.success?

    bin.rmtree if bin.exist?
    bin.mkpath

    brew_gem_prefix = prefix + "gems/#{name}-#{version}"

    completion_for_bash = Dir[
      "#{brew_gem_prefix}/completion{s,}/#{name}.{bash,sh}",
      "#{brew_gem_prefix}/**/#{name}{_,-}completion{s,}.{bash,sh}"
    ].first

    bash_completion.install completion_for_bash if completion_for_bash

    completion_for_zsh = Dir[
      "#{brew_gem_prefix}/completions/#{name}.zsh",
      "#{brew_gem_prefix}/**/#{name}{_,-}completion{s,}.zsh"
    ].first

    zsh_completion.install completion_for_zsh if completion_for_zsh

    ruby_libs = Dir.glob("#{prefix}/gems/*/lib")

    metadata.executables.each do |exe|
      file = Pathname.new("#{brew_gem_prefix}/#{metadata.bindir}/#{exe}")
      (bin + file.basename).open('w') do |f|
        f << <<~RUBY
          #!#{ruby_bin} --disable-gems
          ENV['GEM_HOME']="#{prefix}"
          ENV['GEM_PATH']="#{prefix}"
          require 'rubygems'
          $:.unshift(#{ruby_libs.map(&:inspect).join(',')})
          load "#{file}"
        RUBY
      end
    end
  end

  test do
    assert_match TINKER_VERSION, shell_output("TINKER_ENV=production tinker --version")
  end
end
