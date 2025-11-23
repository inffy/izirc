# iZirc - my custom image based on Zirconium
iZirc is a custom Linux distribution based on Zirconium, designed to provide a lightweight and efficient operating system for everyday use. It includes a curated selection of software and optimizations to enhance performance and user experience.

## Features
- Lightweight and fast
- Custom software selection (currently just zsh added lol)
- Optimized for performance
- User-friendly interface (Niri + DMS)

## Installation
You need to have a Fedora based atomic image, recommend installing Bluefin first and then use bootc to rebase to iZirc.

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/inffy/izirc:latest
```
After switching, reboot your system to start using iZirc.
## Screenshot
<img width="2880" height="1918" alt="image" src="https://github.com/user-attachments/assets/9dae1fcc-e206-4c2f-a105-54638a272451" />
