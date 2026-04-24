FROM quay.io/fedora/fedora-bootc:latest

# Add your packages here
RUN dnf -y install vim-enhanced tmux && dnf clean all

# Default login — change this!
RUN useradd -m -G wheel admin && echo "admin:password" | chpasswd
