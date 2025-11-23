# iZirc - my custom image based on Zirconium
iZirc is a custom Linux distribution based on Zirconium, designed to provide a lightweight and efficient operating system for everyday use. It includes a curated selection of software and optimizations to enhance performance and user experience.

## Features
- Lightweight and fast
- Custom software selection (currently just zsh added lol)
- Optimized for performance
- User-friendly interface (Niri + DMS)
- No-sudo bootc commands - users in the wheel group can run bootc operations directly without sudo

## Installation
You need to have a Fedora based atomic image, recommend installing Bluefin first and then use bootc to rebase to iZirc.

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/inffy/izirc:latest
```
After switching, reboot your system to start using iZirc.

## Managing Updates
iZirc allows users in the wheel group (administrative users) to manage system updates directly without sudo:

```bash
# Check system status
bootc status

# Update to the latest version
bootc update

# Upgrade to a new version
bootc upgrade
```

These commands can be run directly without `sudo` for users in the wheel group, making system management more convenient while maintaining security.
## Screenshot
<img width="2880" height="1918" alt="image" src="https://github.com/user-attachments/assets/9dae1fcc-e206-4c2f-a105-54638a272451" />
