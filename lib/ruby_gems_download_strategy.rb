# frozen_string_literal: true

require_relative './debug_tools'

require 'yaml'
require 'download_strategy'

class RubyGemsDownloadStrategy < AbstractDownloadStrategy
  include DebugTools

  class << self
    def gem_config
      {
        backtrace: false,
        bulk_threshold: 1000,
        sources: [
          "https://x-oauth-basic:#{ENV['HOMEBREW_GITHUB_API_TOKEN']}@rubygems.pkg.github.com/bodyshopbidsdotcom/",
          'http://rubygems.org/'
        ],
        update_sources: true,
        verbose: true
      }
    end

    def gem_config_file(&block)
      file_path = File.join(Dir.tmpdir, '.gemrc')

      open(file_path, 'w') { |file| file.write(YAML.dump(gem_config)) }
      block.call(file_path)
    ensure
      File.unlink(file_path)
    end
  end

  def cached_location
    Pathname.new("#{HOMEBREW_CACHE}/#{name}-#{version}.gem")
  end

  def clear_cache
    cached_location.unlink if cached_location.exist?
  end

  def run_as_user(command_string)
    system(*shell_cmd(command_string))
  end

  def shell_cmd(command_string)
    [ENV['SHELL'], '--login', '-c', command_string]
  end

  def fetch(quiet: nil, verify_download_integrity: true, timeout: nil)
    ohai("Fetching #{name} gem from GitHub packages.")
    setup_debug_tools if Context.current.debug?
    clear_cache
    RubyGemsDownloadStrategy.gem_config_file do |config_path|
      HOMEBREW_CACHE.cd do
        run_as_user("cd #{HOMEBREW_CACHE}; gem fetch #{name} --version #{version} --config-file #{config_path}")
      end
    end
  end
end
