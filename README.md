# firecracker-arch

## Project Goal(s)

My goal with this project is to be able to quickly spin up a VM on my home network
possibly available outside of my home network by adding them to my [tailscale](https://tailscale.com/) network
for experimentation that looks identical --- i.e., running Arch Linux with my dotfiles ---
to my host development machine. In the future, I'd like to try to mount my `$HOME`
into the VMs via something like [upspinfs](https://pkg.go.dev/upspin.io/cmd/upspinfs)
so that I don't have to worry about checking changes into git and pulling them
down everywhere, etc. I've experienced the challenge of maintaining my dotfiles
between my work and personal machines and I struggle to check in changes.

## Getting Started

1. Build a root filesystem and uncompressed kernel.

    Note(s): [here](https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md) are the official docs.
    * [`vmlinux` Make target in the Linux source](https://github.com/torvalds/linux/blob/44db63d1ad8d71c6932cbe007eb41f31c434d140/Makefile#L1198).

    ```bash
    ./create-arch-rootfs.sh
    ```

1. Start the Firecracker API.

    ```bash
    rm -rf /tmp/firecracker.socket && firecracker --api-sock /tmp/firecracker.socket &
    ```

1. Create a bridge network interface on your host.

https://www.systutorials.com/setting-up-gateway-using-iptables-and-route-on-linux/

1. Start a new VM.
