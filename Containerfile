FROM quay.io/fedora/fedora-bootc:latest

RUN dnf -y install \
    niri \
    neovim \
    pipewire wireplumber \
    NetworkManager \
    mesa-dri-drivers mesa-vulkan-drivers \
    && dnf clean all

RUN dnf -y copr enable pgdev/ghostty && \
    dnf -y install ghostty && \
    dnf clean all

RUN dnf -y copr enable avengemedia/dms && \
    dnf -y install dms && \
    dnf clean all

RUN systemctl enable NetworkManager

# Default login — change this!
RUN useradd -m -G wheel admin && echo "admin:password" | chpasswd
