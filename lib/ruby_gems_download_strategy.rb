# frozen_string_literal: true

require 'yaml'
require 'download_strategy'

class RubyGemsDownloadStrategy < AbstractDownloadStrategy
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

  def setup_debug_tools
    Homebrew.install_gem_setup_path! 'pry'
    Homebrew.install_gem_setup_path! 'pry-byebug', executable: 'pry'
    Homebrew.install_gem_setup_path! 'dotenv'
    # require 'dotenv/load'
    require 'pry-byebug'
  end

  def fetch
    ohai "Fetching #{name} from gem source"
    setup_debug_tools if Context.current.debug?

    clear_cache
    RubyGemsDownloadStrategy.gem_config_file do |config_path|
      HOMEBREW_CACHE.cd do
        system('gem', 'fetch', name, '--version', version, '--config-file', config_path)
        # This is to pull down dependencies which needs HOMEBREW_GITHUB_API_TOKEN value
        File.write('dependencies.bin', Net::HTTP.get(URI.parse("https://x-oauth-basic:#{ENV['HOMEBREW_GITHUB_API_TOKEN']}@rubygems.pkg.github.com/bodyshopbidsdotcom/api/v1/dependencies?gems=tinker")))
      end
    end
  end
end
