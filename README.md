# inmacs

inmacs is a [Nix](https://nixos.org)configuration for quickly configuring my personal Intel Mac setup.

## Usage

### Installing Nix

To install Nix, simply run this command:
```shell
sh <(curl -L https://nixos.org/nix/install)
```

After running the above command, you can check the Nix installation by using `nix --version` command.

### Clone The Repository

I recommend you to clone the repository in your home directory (`/Users/<your-username>` or `~`), so `cd` there if you are not already and then clone this repository.

```shell
cd ~
git clone https://github.com/risangbaskoro/inmacs.git
```

Now you should have `inmacs` directory in your home directory.

### Let It Work

To configure your Mac like mine, you can rebuild it using `darwin-rebuild` command and type your password if requested:

```shell
darwin-rebuild switch --flake ~/inmacs#laptop
```

Now, your Mac setup is complete. It does a few things, namely install a few CLI tools that I use, some Apps, and configuring your OS config, like hiding the docs.

### Dotfiles

For configuring your terminal or other configurations that uses dotfiles (files that name started with a `.`), please visit https://github.com/risangbaskoro/dotfiles.

## More Information

For more information about Nix, see the Nix website at https://nixos.org and the documentation at https://nix.dev.