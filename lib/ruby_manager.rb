# Module for managing Ruby installations and versions. This module will install an independent
# version of Ruby for every formula that uses it. This ensures that any applications that depend on
# specific Ruby versions won't have those dependencies broke by untracked changes on the system.
#
# Currently uses RVM for the build and installation process.
#
# = Usage
#  class Tinker < Formula
#    include RubyManager
#    
#    # REQUIRED, as +user_home+ will be called from the +RubyManager+ module.
#    def user_home
#      @user_home ||= `eval echo ~$USER`.strip
#    end
#    
#    # REQUIRED, as +ruby_version+ will be called from the +RubyManager+ module.
#    def ruby_version
#      '3.0.1'
#    end
#    
#    def install
#      install_ruby
#    end
#
# Also, see this discussion between the RVM and Homebrew maintainers about integrations between the
# projects:
#   https://github.com/rvm/rvm/issues/1623
module RubyManager
  # Destination path for cloned copy installation of RVM dedicated for this formula.
  #
  # @return [String] Path to the directory containing the RVM installation.
  def rvm_path
    "#{prefix}/.rvm"
  end

  # Directory for the dedicated installation of the Ruby runtime.
  #
  # @return [String] Path to the directory containing the Ruby runtime code.
  def ruby_path
    "#{rvm_path}/rubies/ruby-#{ruby_version}"
  end

  # Directory for the gems associated with the dedicated installation of the Ruby runtime.
  #
  # @return [String] Path to the directory containing gems for the dedicated Ruby installation.
  def gem_path
    "#{rvm_path}/gems/ruby-#{ruby_version}"
  end

  # Clone an existing RVM runtime installation to the formula prefix directory. This is required to
  # build and install dedicated versions of Ruby for the formula.
  #
  # @param [String] source_rvm_path Path to the existing RVM runtime installation.
  # @param [String] destination_rvm_path Path that will be created with a duplicate version of RVM.
  def clone_rvm_directory(source_rvm_path, destination_rvm_path)
    mkdir_names = [
      'archives',
      'environments',
      'gems',
      'log',
      'rubies',
      'src',
      'tmp',
      'user',
      'wrappers'
    ]

    link_names = Dir["#{source_rvm_path}/*"]
      .map { |path| path.split('/').last }
      .select { |path| mkdir_names.exclude?(path) }

    mkdir(destination_rvm_path)

    link_names.each do |name|
      ln_s("#{source_rvm_path}/#{name}", "#{destination_rvm_path}/#{name}")
    end

    mkdir_names.each { |name| mkdir("#{destination_rvm_path}/#{name}") }
  end

  # List the parts of the +$PATH+ that are not shimmed by Homebrew. This is used to avoid build issues
  # where Homebrew-dependencies collide with system-dependencies.
  #
  # @return [Array] An array of Strings representing paths to include in +$PATH+.
  def non_shim_paths
    ENV['PATH'].split(':').select { |path| path.exclude?(HOMEBREW_SHIMS_PATH.to_s) }
  end

  # List the parts of the $PATH+ that are not associated with an installation of Homebrew. This is
  # used to prevent Homebrew operation commands from colliding with application runtime commands.
  #
  # @return [Array] An array of Strings representing paths to include in +$PATH+.
  def non_homebrew_paths
    ENV['PATH'].split(':').select { |path| path.exclude?('Homebrew') }
  end

  # Install the required Ruby version into an isolated directory using RVM.
  #
  # When dependencies are not found, RVM attempts to use Homebrew to install them. This will raise
  # an error, because we are already executing RVM from within the context of a Homebrew formula.
  # To prevent this, we set +autolibs+ to +read-fail+, which will cause RVM to fail if dependencies
  # are not found.
  #
  # We set the +with-gcc+ explicitly to +gcc+ so that it won't attempt to build Ruby with the clang
  # compiler (found on macos).
  #
  # The +--verbose+ and +--debug+ flags are set so we will see detailed logs if an installation
  # fails for whatever reason.
  #
  # @see https://github.com/rvm/rvm/blob/35e894c7070eaabc38d91220f6e26d1585a7098a/help/autolibs.md
  # @see https://github.com/rvm/rvm/issues/1623#issuecomment-14181568
  def install_ruby
    clone_rvm_directory("#{user_home}/.rvm", rvm_path)

    with_env(
      rvm_path: rvm_path,
      PATH: non_shim_paths.join(':')
    ) do
      system(
        "#{rvm_path}/bin/rvm",
        '--autolibs=read-fail',
        '--with-gcc=gcc',
        '--verbose', '--debug',
        'install', ruby_version
      )
    end
  end

  # Get environment variables for executing bin files from the isolated version of Ruby. This is
  # used for building and installing gems. Use this with the +with_env+ Homebrew method to run
  # +system+ commands.
  #
  # = Usage
  #  with_env(ruby_environment) do
  #    system('gem', 'install', 'mygem.gem')
  #  end
  #
  # @see https://rubydoc.brew.sh/Kernel.html#with_env-instance_method
  #
  # @return [Hash] A Hash of environment variables used for executing commands.
  def ruby_environment
    ordered_paths = ["#{ruby_path}/bin", '/usr/local/bin'] + non_homebrew_paths

    @ruby_environment ||= {
        'PATH' => ordered_paths.join(':'),
        'GEM_HOME' => gem_path,
        'GEM_PATH' => gem_path,
        'MY_RUBY_HOME' => ruby_path,
        'IRBRC' => "#{ruby_path}/.irbrc",
        'RUBY_VERSION' => "ruby-#{ruby_version}"
      }
  end
end
