sudo apt-get install cmake liblog4cpp5-dev libv4l-dev libssl-dev liblivemedia-dev openssl
git clone https://github.com/mpromonet/v4l2rtspserver.git
cd v4l2rtspserver
git config --global https_proxy https://192.168.31.163:7890
# modify the CMakeLists.txt
sed -i /^\s*EXEC_PROGRAM("git/ c\EXEC_PROGRAM("git submodule update --init --depth=1") CMakeLists.txt
cmake -H. -Bbuild
cd build && make
sudo make install
v4l2rtspserver -H 720 -W 1280 -F 15 -P 8555 /dev/video0
