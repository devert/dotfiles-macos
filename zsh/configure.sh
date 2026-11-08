#!/usr/bin/env zsh

# Oh My Zsh only exports these when sourced interactively; running this as a
# script leaves them empty, so fall back to the standard OMZ defaults. Without
# this, $ZSH_CUSTOM is blank and paths resolve to the read-only filesystem root.
ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# Put Zsh configuration in place
echo "Configuring Zsh Profile..."

ln -sfn ~/.dotfiles/zsh/.zprofile ~/.zprofile
ln -sfn ~/.dotfiles/zsh/.zshrc ~/.zshrc
touch ~/.hushlogin

# Install custom Zsh plugins (skip if already cloned)
echo "Installing Custom Zsh Plugins..."
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
[ -d "$ZSH_CUSTOM/plugins/zsh-uv-env" ] || git clone https://github.com/matthiasha/zsh-uv-env $ZSH_CUSTOM/plugins/zsh-uv-env

# Install custom Zsh theme (skip if already cloned)
echo "Installing Custom Zsh Theme..."
[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
ln -sfn ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh

# Install custom configuration files
echo "Installing Custom Zsh Configuration Files..."
ln -sfn ~/.dotfiles/zsh/aliases.zsh $ZSH_CUSTOM/aliases.zsh
ln -sfn ~/.dotfiles/zsh/functions.zsh $ZSH_CUSTOM/functions.zsh
ln -sfn ~/.dotfiles/zsh/exports.zsh $ZSH_CUSTOM/exports.zsh

echo "Zsh Configuration Complete!"
