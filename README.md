# bootc starter

Define your OS in a `Containerfile`. Get a bootable disk image. That's it.

## Get started

**1. Use this template**

Click **"Use this template"** at the top of this page to create your repo, then clone it:

```bash
git clone git@github.com:YOUR-USER/YOUR-REPO.git
cd YOUR-REPO
```

**2. Edit the Containerfile and push**

```dockerfile
FROM quay.io/fedora/fedora-bootc:latest

RUN dnf -y install vim-enhanced tmux && dnf clean all

RUN useradd -m -G wheel admin && echo "admin:password" | chpasswd
```

Add whatever packages you want. Push to `main` and GitHub Actions will:
- Build your container image and push it to `ghcr.io`
- Build a `.qcow2` disk image and attach it to a **Release**

**3. Make your package visible**

After the first build, go to your GitHub profile → **Packages** → find your new image → **Package settings** → **Change visibility → Public**.

> This lets your machines pull updates with `bootc upgrade` without any credentials.
>
> If you delete and recreate the repo, delete the old package first — otherwise the build will fail with a permission error.

**4. Download and boot**

Grab `disk.qcow2` from the **Releases** page and boot it:

```bash
qemu-system-x86_64 -m 2048 -cpu host -enable-kvm -hda disk.qcow2
```

Log in with username **admin** and password **password**.

> **Change these credentials** before putting this anywhere real. See [docs/going-further.md](docs/going-further.md) for SSH key setup.

## Upgrade a running machine

On any machine running your image:

```bash
sudo bootc upgrade
```

It pulls the latest container image and applies it on next boot.

## Rebuild the disk image

The disk image builds automatically on your first push. After that, you can rebuild it any time from the **Actions** tab → **Disk image** → **Run workflow**.

## Install on bare metal

To install on a real machine, build an ISO from the **Actions** tab → **ISO installer** → **Run workflow**. Download `install.iso` from the **Releases** page, flash it to a USB drive, and boot from it. The installer will pull your container image and install it to disk.

---

## Want more?

- [bootc documentation](https://containers.github.io/bootc/)
- Private images, RHEL base, signing, AMI/ISO output → see [docs/going-further.md](docs/going-further.md)
