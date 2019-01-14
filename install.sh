#! /bin/bash



# install in the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROS_WS_DIR=$DIR/ros_ws




# root Check
if [ $(id -u) -ne 0 ]; then
  echo "This script requires to be launched as root"
  exit
fi


# Prerequisits
sudo apt-get install git cmake



# ROS
cd $DIR
git clone https://github.com/jetsonhacks/installROSTX2.git
cd $DIR/installROSTX2
sudo chmod +x installROS.sh
./installROS.sh ros-kinetic-ros-base
sudo apt-get -y install ros-kinetic-cv-bridge ros-kinetic-image-transport
./setupCatkinWorkspace.sh ../../$ROS_WS_DIR   # by default it install in the home dir ../../ bring it back to /


# Patch for Jetson inference (make error)
# https://devtalk.nvidia.com/default/topic/1007290/jetson-tx2/building-opencv-with-opengl-support-/post/5141945/#5141945
cd /usr/lib/aarch64-linux-gnu/
sudo ln -sf tegra/libGL.so libGL.so


# Jetson-inference
cd $DIR
git clone https://github.com/dusty-nv/jetson-inference
cd $DIR/jetson-inference
git submodule update --init
mkdir build
cd build
cmake ../
make
sudo make install


# ROS DetectNet

cd $ROS_WS_DIR/src
git clone https://github.com/cesare-montresor/DetectNet_ROS.git
cd $ROS_WS_DIR


# (Optional) v4l2loopback Tegra TX2

apt-get install v4l2loopback-utils
cd /usr/src/linux-headers-($uname -r)
make modules_prepare
git clone https://github.com/umlaeute/v4l2loopback.git
cd v4l2loopback
make
make install
modprobe v4l2loopback
