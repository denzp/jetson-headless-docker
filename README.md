# Headless Ubuntu 20.04 with Docker for NVIDIA Jetson

The purpose of the scripts is to provide a smaller than official OS image for Docker-based workload.
The use case for this is headless server for inference or GPU-accelerated computing.

**Theoretically the approach is suitable for most devices in the Jetson family, but was only tested on a Jetson Nano development kit.**

## Steps

**Important!** Second step is potentially destructive action! Please backup the device data first!

1. Create a rootfs: `./00-prepare-rootfs.sh`
2. **Option A:** Flash the rootfs into device: `./01-flash.sh`
**Option B:** Create an SD card image: `./01-create-image.sh`
3. Connect the device via USB and perform the [headless configuration](https://www.jetsonhacks.com/2019/08/21/jetson-nano-headless-setup/).

## Recommended actions after the configuration
```
sudo apt-get auto-remove
sudo reboot
```
