#!/bin/bash
# install.sh
# Waveshare 2.8 Installation with Klipperscreen
# Author: Kyle Hart (hartk)
# License: GPL 3.0

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Step 1: Clone Waveshare-DSI-LCD driver repo
echo "Cloning Waveshare-DSI-LCD driver repository..."
cd ~
git clone https://github.com/waveshare/Waveshare-DSI-LCD && cd Waveshare-DSI-LCD

# Step 2: Find the kernel version and system architecture
echo "Checking system kernel version and architecture..."
KERNEL_INFO=$(uname -m -r)
echo "Kernel info: $KERNEL_INFO"

# Extract kernel version and architecture
KERNEL_VERSION=$(echo $KERNEL_INFO | awk '{print $1}' | cut -d'-' -f1)
ARCHITECTURE=$(echo $KERNEL_INFO | awk '{print $2}')

# Determine if the system is 32bit or 64bit
if [[ $ARCHITECTURE == *"aarch64"* ]]; then
  SYS_DIR="64"
else
  SYS_DIR="32"
fi

# Step 3: Navigate to the appropriate directory
echo "Navigating to the appropriate driver directory..."
cd $KERNEL_VERSION/$SYS_DIR

# Step 4: Install the drivers
echo "Installing the drivers..."
sudo bash ./WS_xinchDSI_MAIN.sh 28 I2C0

# Step 5: Add 90-monitor.conf file
echo "Checking if /usr/share/X11/xorg.conf.d/ directory exists..."
if [ ! -d "/usr/share/X11/xorg.conf.d/" ]; then
  echo "Directory does not exist. Creating directory..."
  sudo mkdir -p /usr/share/X11/xorg.conf.d/
else
  echo "Directory already exists."
fi

sudo wget -P /usr/share/X11/xorg.conf.d/ https://raw.githubusercontent.com/hartk1213/MISC/main/Voron%20Mods/Voron%200/0.2/2_8WaveshareDisplay/Software/90-monitor.conf

# Step 6: Update /boot/config.txt
echo "Updating /boot/config.txt..."
sudo sh -c 'echo "\
dtoverlay=vc4-kms-v3d\n\
dtoverlay=vc4-kms-dsi-waveshare-panel,2_8_inch\n\
dtoverlay=WS_xinchDSI_Screen,SCREEN_type=0,I2C_bus=10\n\
dtoverlay=WS_xinchDSI_Touch,I2C_bus=10,invertedy,invertedx" >> /boot/config.txt'

# Step 7: Ask the user if they want to install klipperscreen now
read -p "Do you want to install Klipperscreen now? (y/n): " KLIPPERSCREEN_NOW

if [[ "$KLIPPERSCREEN_NOW" == "y" || "$KLIPPERSCREEN_NOW" == "Y" ]]; then
  echo "Installing Klipperscreen..."
  cd ~/
  git clone https://github.com/KlipperScreen/KlipperScreen.git
  ./KlipperScreen/scripts/KlipperScreen-install.sh
else
  echo "Klipperscreen installation skipped."
fi

# Step 8: Ask the user if they want to reboot
read -p "Do you want to reboot now? (y/n): " REBOOT_NOW

if [[ "$REBOOT_NOW" == "y" || "$REBOOT_NOW" == "Y" ]]; then
  echo "Rebooting the system..."
  sudo reboot
else
  echo "Reboot skipped. Please reboot the system manually to apply changes."
fi
