require 'rake'
require 'fileutils'

$is_macos = RUBY_PLATFORM.downcase.include?("darwin")

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodule_init, :submodules] do
  puts
  puts "======================================================"
  puts "Welcome to YADR Installation."
  puts "======================================================"
  puts

  install_homebrew

  # this has all the runcoms from this directory.
  install_files(Dir.glob('git/*')) if want_to_install?('git configs (color, aliases)')
  install_files(Dir.glob('ruby/*')) if want_to_install?('rubygems config (faster/no docs)')
  install_files(Dir.glob('ctags/*')) if want_to_install?('ctags config (better js/ruby support)')
  install_files(Dir.glob('tmux/*')) if want_to_install?('tmux config')
  install_files(Dir.glob('vimify/*')) if want_to_install?('vimification of command line tools')
  install_files(Dir.glob('{vim,vimrc}'))
  install_files(Dir.glob('zsh/zshrc'))

  run %{ ln -nfs ~/.yadr/nvim ~/.config/nvim }

  run %{ mkdir -p ~/.config/ranger }
  run %{ ln -nfs ~/.yadr/ranger ~/.config/ranger }

  run %{ touch ~/.hushlogin }

  Rake::Task["install_prezto"].execute

  install_fonts

  if $is_macos
    run %{ ~/.yadr/iTerm2/bootstrap-iterm2.sh }
  end

  success_msg("installed")
end

task :install_prezto do
  if want_to_install?('zsh enhancements & prezto')
    install_prezto
  end
end

desc 'Updates the installation'
task :update do
  Rake::Task["install"].execute
  #TODO: for now, we do the same as install. But it would be nice
  #not to clobber zsh files
end

task :submodule_init do
  unless ENV["SKIP_SUBMODULES"]
    run %{ git submodule update --init --recursive }
  end
end

desc "Init and update submodules."
task :submodules do
  unless ENV["SKIP_SUBMODULES"]
    puts "======================================================"
    puts "Downloading YADR submodules...please wait"
    puts "======================================================"

    run %{
      cd $HOME/.yadr
      git submodule update --recursive
      git clean -df
    }
    puts
  end
end

task :default => 'install'

private
def run(cmd)
  puts "[Running] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
end

def number_of_cores
  if $is_macos
    cores = run %{ sysctl -n hw.ncpu }
  else
    cores = run %{ nproc }
  end
  puts
  cores.to_i
end


def linux_variant
  r = { :distro => nil, :family => nil }

  if File.exists?('/etc/lsb-release')
    File.open('/etc/lsb-release', 'r').read.each_line do |line|
      r = { :distro => $1 } if line =~ /^DISTRIB_ID=(.*)/
    end
  end

  if File.exists?('/etc/debian_version')
    r[:distro] = 'Debian' if r[:distro].nil?
    r[:family] = 'Debian' if r[:variant].nil?
  elsif File.exists?('/etc/redhat-release') or File.exists?('/etc/centos-release')
    r[:family] = 'RedHat' if r[:family].nil?
    r[:distro] = 'CentOS' if File.exists?('/etc/centos-release')
  elsif File.exists?('/etc/SuSE-release')
    r[:distro] = 'SLES' if r[:distro].nil?
  end

  return r
end

def install_homebrew
  run %{which brew}
  unless $?.success?
    puts "======================================================"
    puts "Installing Homebrew, the OSX package manager...If it's"
    puts "already installed, this will do nothing."
    puts "======================================================"

    if $is_macos
      run %{bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"}
    else
      puts "Running Homebrew 'install.sh' on Linux..."
      if ! File.exists?('/etc/homebrew')
        run %{sudo mkdir -p /home/linuxbrew}
      end

      run %{sudo chmod 777 /home/linuxbrew}
      run %{yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"}

      puts "Configuring 'brew shellenv' on Linux..."
      ENV['HOMEBREW_PREFIX'] = "/home/linuxbrew/.linuxbrew"
      ENV['HOMEBREW_CELLAR'] = "/home/linuxbrew/.linuxbrew/Cellar"
      ENV['HOMEBREW_REPOSITORY'] = "/home/linuxbrew/.linuxbrew/Homebrew"
      ENV['PATH'] = "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:" + ENV['PATH']
      ENV['MANPATH'] = "/home/linuxbrew/.linuxbrew/share/man:" + ENV['MANPATH'].to_s
      ENV['INFOPATH'] ="/home/linuxbrew/.linuxbrew/share/info:" + ENV['INFOPATH'].to_s

      run %{which brew}
      unless $?.success?
        puts "'brew' is NOT in the path!"
        exit 0
      end

      if linux_variant[:distro] == 'Ubuntu' || linux_variant[:distro] == 'Debian'
        # Running on Debian/Ubuntu
        run %{sudo apt-get install build-essential}
      elsif linux_variant[:family] == 'Redhat'
        if linux_variant[:distro] == nil
          # Running on Redhat Linux
        elsif linux_variant[:distro] == 'Centos'
          # Running on Centos Linux
        end
      end
    end
  end

  puts
  puts
  puts "======================================================"
  puts "Updating Homebrew."
  puts "======================================================"
  run %{brew update}
  puts
  puts
  puts "======================================================"
  puts "Installing Homebrew and other packages..."
  puts "======================================================"
  if ENV['CI'] then
    # A minimal Brewfile to speed up CI Builds
    run %{brew bundle install --file=test/Brewfile_ci}
  else
    run %{brew bundle install}
  end
  # run %{pip3 install tmuxp}
  run %{pip3 install --user neovim} # For NeoVim plugins
  run %{pip3 install --user pynvim} # For NeoVim plugins
  run %{gem install neovim} # For NeoVim plugins
  puts
  puts
end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline/Lightline."
  puts "======================================================"
  run %{ cp -f $HOME/.yadr/fonts/* $HOME/Library/Fonts } if $is_macos
  run %{ mkdir -p ~/.fonts && cp ~/.yadr/fonts/* ~/.fonts && fc-cache -vf ~/.fonts } if !$is_macos
  puts
end

def ask(message, values)
  puts message
  while true
    values.each_with_index { |val, idx| puts " #{idx+1}. #{val}" }
    selection = STDIN.gets.chomp
    if (Float(selection)==nil rescue true) || selection.to_i < 0 || selection.to_i > values.size+1
      puts "ERROR: Invalid selection.\n\n"
    else
      break
    end
  end
  selection = selection.to_i-1
  values[selection]
end

def install_prezto
  puts
  puts "Installing Prezto (ZSH Enhancements)..."

  run %{ ln -nfs "$HOME/.yadr/zsh/prezto" "${ZDOTDIR:-$HOME}/.zprezto" }

  # The prezto runcoms are only going to be installed if zprezto has never been installed
  install_files(Dir.glob('zsh/prezto/runcoms/zlogin'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zlogout'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zpreztorc'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zprofile'), :symlink)
  install_files(Dir.glob('zsh/prezto/runcoms/zshenv'), :symlink)

  puts
  puts "Overriding prezto ~/.zpreztorc with YADR's zpreztorc to enable additional modules..."
  run %{ ln -nfs "$HOME/.yadr/zsh/prezto-override/zpreztorc" "${ZDOTDIR:-$HOME}/.zpreztorc" }
  run %{ ln -s ~/.zprezto/modules/prompt/external/powerlevel9k/powerlevel9k.zsh-theme ~/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup }

  puts
  puts "Creating directories for your customizations"
  run %{ mkdir -p $HOME/.zsh.before }
  run %{ mkdir -p $HOME/.zsh.after }
  run %{ mkdir -p $HOME/.zsh.prompts }

  if "#{ENV['SHELL']}".include? 'zsh' then
    puts "Zsh is already configured as your shell of choice. Restart your session to load the new settings"
  else
    puts "Setting zsh as your default shell"
    if File.exists?("/usr/local/bin/zsh")
      if File.readlines("/private/etc/shells").grep("/usr/local/bin/zsh").empty?
        puts "Adding zsh to standard shell list"
        run %{ echo "/usr/local/bin/zsh" | sudo tee -a /private/etc/shells }
      end
      run %{ sudo chsh -s /usr/local/bin/zsh $USER }
    elsif File.exists?("/home/linuxbrew/.linuxbrew/bin/zsh")
      if File.readlines("/etc/shells").grep("/home/linuxbrew/.linuxbrew/bin/zsh").empty?
        puts "Adding zsh to standard shell list"
        run %{ echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells }
      end
      run %{ sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh $USER }
    else
      puts "Falling back to default/system zsh"
      run %{ chsh -s /bin/zsh }
    end
  end
end

def want_to_install? (section)
  if ENV["ASK"]=="true"
    puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
    STDIN.gets.chomp == 'y'
  else
    true
  end
end

def install_files(files, method = :symlink)
  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "======================#{file}=============================="
    puts "Source: #{source}"
    puts "Target: #{target}"

    if File.exists?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
      puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" }
    end

    if method == :symlink
      run %{ ln -nfs "#{source}" "#{target}" }
    else
      run %{ cp -f "#{source}" "#{target}" }
    end

    puts "=========================================================="
    puts
  end
end

def success_msg(action)
  puts ""
  puts "   _     _           _         "
  puts "  | |   | |         | |        "
  puts "  | |___| |_____  __| | ____   "
  puts "  |_____  (____ |/ _  |/ ___)  "
  puts "   _____| / ___ ( (_| | |      "
  puts "  (_______\_____|\____|_|      "
  puts ""
  puts "YADR has been #{action}. Please restart your terminal and vim."
end
