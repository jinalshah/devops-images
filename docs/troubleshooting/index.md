# Known Issues and Troubleshooting

## Known Issues

### Issue with `source ~/.zshrc` on builds

If you run the command `source ~/.zshrc` within the Dockerfile it fails.

This is due to the build/shell throwing an error when one "source" command calls another "source" (i.e. a nested source) within a file.

#### Workaround examples

##### Temporarily Disable and Re-enable `$ZSH/oh-my-zsh.sh` from `~/.zshrc`

Comment Source Lines in `~/.zshrc`:

```bash
sed -i 's/# source $ZSH\/oh-my-zsh.sh/source $ZSH\/oh-my-zsh.sh/g' ~/.zshrc
```

Uncomment Source Lines in `~/.zshrc` on all stage builds:

```bash
sed -i 's/# source <(kubectl completion zsh)/source <(kubectl completion zsh)/g' ~/.zshrc && \
  sed -i 's/# source <(kubectl completion zsh)/source <(kubectl completion zsh)/g' ~/.bashrc && \
  sed -i 's/# source $ZSH\/oh-my-zsh.sh/source $ZSH\/oh-my-zsh.sh/g' ~/.zshrc
```

---

### Common Docker Build Issues

- **Permission denied errors:**
  - Ensure you have the correct permissions on files and directories being copied into the image.
  - Use `chmod` or `chown` as needed in your Dockerfile.
- **Network issues during build:**
  - Retry the build; sometimes network hiccups cause package install failures.
  - Check your internet connection or proxy settings.
- **Build cache not updating:**
  - Use `--no-cache` with `docker build` to force a fresh build.

---

## Need More Help?

If you encounter an issue not listed here, please open an issue on the repository with details and steps to reproduce.
