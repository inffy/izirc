# Copilot Instructions for iZirc

## Repository Overview

This repository builds a custom bootc (Boot Container) image based on [Zirconium](https://github.com/zirconium-dev/zirconium), which is part of the Universal Blue ecosystem. The project creates a customized immutable Linux OS image that can be deployed to bare metal or virtual machines.

## Technology Stack

- **Container Technology**: Podman/Docker for building OCI images
- **Build System**: Justfile for task automation
- **Base Image**: `ghcr.io/zirconium-dev/zirconium:latest` (pinned by digest in Containerfile)
- **Package Manager**: DNF5 (Fedora's next-generation package manager)
- **Boot Technology**: bootc (Boot Container) for creating bootable images
- **CI/CD**: GitHub Actions

## Key Files and Their Purposes

### Core Build Files

- **`Containerfile`**: The main image definition file. Defines the base image and customization steps.
- **`build_files/build.sh`**: The customization script that installs packages, configures services, and modifies system settings.
- **`Justfile`**: Task automation file containing recipes for building, testing, and deploying images.

### Configuration Files

- **`disk_config/disk.toml`**: Configuration for generating QCOW2/RAW disk images.
- **`disk_config/iso-gnome.toml`** and **`disk_config/iso-kde.toml`**: Configuration files for generating ISO installation images with GNOME or KDE desktop environments.
  - **Note**: The Justfile and GitHub workflows reference `disk_config/iso.toml` which doesn't exist. You may need to create a symlink or copy one of the existing ISO configs to `iso.toml`, or update the Justfile and workflows to use the correct file.
- **`build_files/dracut.conf.d/`**: Dracut configuration files for initramfs generation.

### CI/CD

- **`.github/workflows/build.yml`**: Builds and publishes the container image to GHCR.
- **`.github/workflows/build-disk.yml`**: Creates bootable disk images (ISO, QCOW2, RAW).

## Build and Test Instructions

### Building the Container Image

```bash
just build
```

This builds the container image locally using Podman. The image will be tagged as `izirc:latest` by default.

### Building Disk Images

```bash
# Build QCOW2 virtual machine image
just build-qcow2

# Build ISO installation image
just build-iso

# Build RAW disk image
just build-raw
```

### Testing

- **Container Linting**: The Containerfile includes `bootc container lint` at the end to verify the image.
- **VM Testing**: Use `just run-vm-qcow2` or `just spawn-vm` to test the image in a virtual machine.
- **Shell Linting**: Run `just lint` to check all bash scripts with shellcheck.
- **Just Syntax**: Run `just check` to verify Justfile syntax.

## Code Modification Guidelines

### When Modifying the Containerfile

1. Keep the ARG declarations at the top before any FROM statements.
2. Always use the `--mount=type=bind,from=ctx` pattern to access build files without copying them into the final image.
3. Maintain the `bootc container lint` step at the end.
4. Use build caches (`--mount=type=cache`) for `/var/cache` and `/var/log` to speed up builds.

### When Modifying build.sh

1. Always use `set -ouex pipefail` at the start for error handling.
2. Use `dnf5` (not `dnf`) for package management.
3. Enable systemd units with `systemctl enable` rather than modifying unit files.
4. When modifying `/usr/lib/os-release`, ensure all required fields (NAME, PRETTY_NAME, ID) are present.
5. Format bash scripts using `just format` after editing.

### When Modifying the Justfile

1. Use `export` for environment variables that recipes should inherit.
2. Group related recipes using the `[group('Name')]` attribute.
3. Mark private/internal recipes with `[private]`.
4. Always include error handling (`set -euo pipefail`) in bash recipe bodies.
5. Check syntax with `just check` and auto-format with `just fix`.

## Project-Specific Conventions

### Package Installation

- **Always use DNF5** (`dnf5 install -y package-name`), not the legacy `dnf` command.
- Install packages in `build_files/build.sh`, not directly in the Containerfile.
- When using COPR repositories, remember to disable them after package installation.

### Systemd Service Configuration

- Enable services using `systemctl enable service-name` in `build.sh`.
- Do not modify service files directly; use systemd drop-ins if configuration changes are needed.

### OS Branding

- The distribution is branded as "iZirc" (capital Z).
- OS identification is customized in `/usr/lib/os-release` (not `/etc/os-release`).
- Repository references should use `${GITHUB_REPOSITORY:-inffy/izirc}`.

### Container Best Practices

- Use multi-stage builds with `FROM scratch AS ctx` to keep build artifacts out of the final image.
- Leverage build caches to improve build times.
- Always test changes with `bootc container lint`.

## Common Tasks

### Adding a New Package

1. Edit `build_files/build.sh`.
2. Add the package to the appropriate `dnf5 install` command.
3. Rebuild the image with `just build`.
4. Test the image locally or in a VM.

### Enabling a New Service

1. Install the service's package in `build_files/build.sh`.
2. Add `systemctl enable service-name` in the same file.
3. Rebuild and test.

### Modifying Disk Image Configuration

1. Edit the appropriate configuration file:
   - `disk_config/disk.toml` for QCOW2/RAW images
   - `disk_config/iso-gnome.toml` or `disk_config/iso-kde.toml` for ISO images
   - **Important**: The build scripts expect `disk_config/iso.toml` to exist. Consider creating it as a symlink to your preferred desktop environment config (e.g., `cd disk_config && ln -s iso-gnome.toml iso.toml`).
2. Rebuild the disk image with `just rebuild-qcow2`, `just rebuild-iso`, etc.
3. Test with `just run-vm-qcow2` or `just spawn-vm`.

## Important Notes

- **Immutability**: This is an immutable OS image. User modifications at runtime will be lost on updates. System modifications should be made in the build files.
- **Updates**: Users update by pulling a new container image with `bootc upgrade` or `bootc switch`.
- **The /opt directory**: Be aware that some Universal Blue images symlink `/opt` to `/var/opt`. If packages write to `/opt`, consider uncommenting the line in the Containerfile that makes `/opt` immutable.
- **Container Signing**: The repository uses cosign for container signing. The signing key (`cosign.key`) must never be committed to the repository.

## Testing Changes

Before submitting changes:

1. **Lint bash scripts**: `just lint`
2. **Format bash scripts**: `just format`
3. **Check Justfile syntax**: `just check`
4. **Build the image**: `just build`
5. **Test in a VM** (if significant changes): `just run-vm-qcow2` or `just spawn-vm`

## Architecture Notes

- This is a **bootc-based** image, not a traditional Fedora system.
- The root filesystem is **immutable** (read-only).
- System changes are made by building a new image, not by modifying the running system.
- User data and configuration persist in `/home`, `/etc`, and `/var`.
