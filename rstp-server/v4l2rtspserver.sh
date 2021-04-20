sudo apt-get install cmake liblog4cpp5-dev libv4l-dev libssl-dev
git clone https://github.com/mpromonet/v4l2rtspserver.git
cd v4l2rtspserver/
cmake .
make
sudo make install
v4l2rtspserver -H 720 -W 1280 -F 15 -P 8555 /dev/video0
