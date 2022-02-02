module DebugTools
  def setup_debug_tools
    Homebrew.install_gem_setup_path! 'pry-byebug', executable: 'pry'
    Homebrew.install_gem_setup_path! 'pry-rescue', executable: 'pry'
  end
end
