# 🚀 Starship Prompt Configuration

A comprehensive, informative, and color-coded Starship prompt configuration that works across **bash**, **fish**, and **zsh** shells with nerd font support.

## ✨ Features

### 🎨 **Visual Elements**
- **Nerd Font Icons**: Beautiful symbols for git status, programming languages, and system info
- **Color Coding**: Consistent color scheme across all modules
- **Unicode Symbols**: Modern symbols like ❯, ✗, ⚡, 🔋, 🕙

### 📊 **Information Display**
- **User & Host**: Username and hostname with SSH detection
- **Directory**: Current path with smart truncation
- **Git Status**: Branch, status, ahead/behind, conflicts, stashes
- **Programming Languages**: Python, Node.js, Rust, Go versions
- **DevOps Tools**: Docker, Kubernetes, AWS, Terraform contexts
- **System Info**: Memory usage, battery status, CPU architecture
- **Time & Jobs**: Current time and background job count
- **Command Duration**: Execution time for long-running commands

### 🔧 **Shell Support**
- **Bash**: Full configuration with aliases and functions
- **Fish**: Fish-specific syntax and abbreviations
- **Zsh**: Enhanced completion and key bindings

## 🚀 Quick Setup

### Option 1: Automated Setup (Recommended)
```bash
./setup_starship.sh
```

### Option 2: Manual Setup
1. **Install Starship**:
   ```bash
   curl -sS https://starship.rs/install.sh | sh
   ```

2. **Copy Configuration**:
   ```bash
   mkdir -p ~/.config
   cp config/starship.toml ~/.config/starship.toml
   ```

3. **Configure Your Shell**:
   - **Bash**: Add `source /path/to/config/bashrc` to `~/.bashrc`
   - **Fish**: Add `source /path/to/config/config.fish` to `~/.config/fish/config.fish`
   - **Zsh**: Add `source /path/to/config/zshrc` to `~/.zshrc`

## 📁 File Structure

```
config/
├── starship.toml          # Main Starship configuration
├── bashrc                 # Bash-specific configuration
├── config.fish            # Fish-specific configuration
└── zshrc                  # Zsh-specific configuration
setup_starship.sh          # Automated setup script
README.md                  # This file
```

## 🎯 Configuration Details

### **Prompt Layout**
The prompt shows information in this order:
1. Username and hostname
2. Current directory
3. Git branch and status
4. Programming language versions
5. DevOps tool contexts
6. System information
7. Time and jobs
8. Command prompt character

### **Color Scheme**
- **Green**: Success states, usernames
- **Blue**: Directories, jobs
- **Purple**: Git branches, Kubernetes
- **Yellow**: Python, AWS, time
- **Red**: Errors, git conflicts
- **Cyan**: Go, system info
- **Magenta**: Package managers

### **Nerd Font Icons**
- **❯**: Normal prompt (success)
- **✗**: Error prompt
- **❮**: Vim insert mode
- **⚡**: Git conflicts, charging
- **🔋**: Battery full
- **🕙**: Current time
- **🐍**: Python environments

## 🔧 Customization

### **Adding New Modules**
Edit `~/.config/starship.toml` and add new module configurations:

```toml
[new_module]
symbol = " "
style = "bright-cyan bold"
format = "[$symbol$value]($style) "
```

### **Changing Colors**
Modify the `style` parameter in any module:
- `bold`: Makes text bold
- `bright-*`: Bright color variants
- `dim`: Dimmed text
- Combine styles: `"bright-red bold"`

### **Reordering Modules**
Edit the `format` section in `starship.toml` to change the order of information display.

## 🐛 Troubleshooting

### **Prompt Not Working**
1. Check if Starship is installed: `starship --version`
2. Verify configuration: `starship config --config-file ~/.config/starship.toml`
3. Check shell configuration files for proper sourcing

### **Missing Icons**
1. Install a Nerd Font: https://www.nerdfonts.com/font-downloads
2. Set your terminal to use the Nerd Font
3. Restart your terminal

### **Performance Issues**
1. Increase `scan_timeout` in `starship.toml`
2. Disable unused modules by setting `disabled = true`
3. Check for slow git repositories

## 📚 Additional Resources

- **Starship Documentation**: https://starship.rs/
- **Nerd Fonts**: https://www.nerdfonts.com/
- **Configuration Examples**: https://starship.rs/presets/

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the MIT License.

---

**Enjoy your new informative and beautiful prompt! ✨**
