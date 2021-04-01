# Readme

## gstreamer

### IP
```
nmap -sP 192.168.31.1/24
```

### check if communicate with camera
```bash
ls /dev/video*
sudo apt install v4l-utils
v4l2-ctl --list-formats-ext --all -d0
bash -c 'gst-launch-1.0 v4l2src device=/dev/video0 \
            ! "image/jpeg, width=1280, height=720,type=video,framerate=30/1" \
            ! jpegdec ! videoflip method=none \
            ! timeoverlay halignment=right valignment=bottom \
            ! clockoverlay halignment=left valignment=bottom time-format="%Y/%m/%d %H:%M:%S" \
            ! jpegenc  ! rtpjpegpay ! queue \
            ! udpsink host=192.168.31.99 port=5600'
```

### Autologin
```bash
$ cat /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
[Seat:*]
user-session=mate
autologin-user=gyb
autologin-user-timeout=0


$ sudo nano /etc/systemd/system/getty.target.wants/getty@tty1.service
[Service]
ExecStart=-/usr/bin/agetty --autologin ubuntu --noclear %I $TERM
```

### install, test doc
```bash
apt-get install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

git clone https://gitlab.freedesktop.org/gstreamer/gst-docs.git
cd gst-docs/examples/tutorials

gcc basic-tutorial-1.c -o basic-tutorial-1 `pkg-config --cflags --libs gstreamer-1.0`
./basic-tutorial-1
```

## Learn
```bash
gst-launch-1.0 -v videotestsrc pattern=snow ! video/x-raw,width=640,height=480 ! autovideosink
gst-launch-1.0 -v videotestsrc pattern=ball ! video/x-raw,width=640,height=480 ! autovideosink

gst-launch-1.0 -v v4l2src device=/dev/video2 ! image/jpeg,width=1280,height=720,type=video,framerate=30/1 ! jpegdec ! autovideosink

gst-launch-1.0 v4l2src device=/dev/video2 ! "image/jpeg, width=1920, height=1080" ! jpegdec ! autovideosink

gst-launch-1.0 v4l2src device=/dev/video0 ! "video/x-raw, width=1280,height=720,type=video,framerate=30/1" ! videoconvert ! autovideosink sync=false

gst-launch-1.0 v4l2src device=/dev/video0 ! "video/x-raw, format=YUY2,width=640,height=480,type=video,framerate=30/1" ! videoconvert ! autovideosink sync=false
```

### Server, jpeg  
```bash
gst-launch-1.0  v4l2src device=/dev/video0 ! image/jpeg,width=1280,height=720,type=video,framerate=30/1 ! jpegdec ! videoscale ! videoconvert ! x264enc ! rtph264pay ! udpsink host=192.168.31.99 port=5600
```

### Server, flip, time
```bash
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

gst-launch-1.0 v4l2src device=/dev/video0 ! "image/jpeg, width=1280, height=720,type=video,framerate=30/1"  ! jpegdec ! videoflip method=none ! timeoverlay halignment=right valignment=bottom ! clockoverlay halignment=left valignment=bottom time-format="%Y/%m/%d %H:%M:%S" ! jpegenc  ! rtpjpegpay  pt=96 ! queue ! udpsink host=192.168.31.99 port=5600
```

videoflip method = 
- clockwise (1) – Rotate clockwise 90 degrees
- rotate-180 (2) – Rotate 180 degrees
- counterclockwise (3) – Rotate counter-clockwise 90 degrees
- horizontal-flip (4) – Flip horizontally
- vertical-flip (5) – Flip vertically
- upper-left-diagonal (6) – Flip across upper left/lower right diagonal
- upper-right-diagonal (7) – Flip across upper right/lower left diagonal
- automatic (8) – Select flip method based on image-orientation tag

### Client, h264
```bash
gst-launch-1.0 udpsrc port=5600 ! application/x-rtp,media=video,clock-rate=90000,encoding-name=H264 ! rtph264depay ! h264parse ! avdec_h264 ! videoconvert ! autovideosink

gst-launch-1.0 udpsrc port=5600 ! application/x-rtp, media=video, clock-rate=90000, encoding-name=H264 ! rtph264depay ! avdec_h264 ! autovideosink fps-update-interval=1000 sync=false
```

### Client, jpeg
```bash
gst-launch-1.0 udpsrc port=5602 ! application/x-rtp,encoding-name=JPEG,clock-rate=90000,payload=26 ! rtpjpegdepay ! jpegdec ! autovideosink fps-update-interval=1000 sync=false
```

#### play and save
```bash
gst-launch-1.0 -e udpsrc port=5600 ! application/x-rtp,encoding-name=JPEG,clock-rate=90000,payload=26 ! rtpjpegdepay ! jpegdec ! videoconvert ! tee name=splitter ! queue ! autovideosink sync=false splitter. ! queue ! x264enc pass=quant ! matroskamux ! filesink location=video_l_$(date +"%Y-%m-%d_%H-%M").mkv
```
### VLC Receiver
```bash
$ cat test.sdp
v=0
o=- 1208520720 2590316915 IN IP4 192.168.31.142 #server ip
c=IN IP4 192.168.31.142
s=MPEG STREAM
m=video 5600 RTP/AVP 96
a=rtpmap:96 JPEG/90000
a=fmtp:96 media=video; clock-rate=90000; encoding-name=JPEG; 
```

### SERVER, two cameras
```
gst-launch-1.0 \
    v4l2src device=/dev/video0 \
    ! "image/jpeg, width=640, height=480,type=video,framerate=30/1" \
    ! rtpjpegpay  pt=96 \
    ! udpsink host=192.168.31.99 port=5600 \
    v4l2src device=/dev/video2 \
    ! "image/jpeg, width=640, height=480,type=video,framerate=30/1" \
    ! rtpjpegpay  pt=96 \
    ! udpsink host=192.168.31.99 port=5602

$ crontab -e
@reboot  /home/ubuntu/two_camera.sh
```

### Client, two cameras
```bash
gst-launch-1.0 -e \
videomixer name=mix \
        sink_0::xpos=0   sink_0::ypos=0  sink_0::alpha=0\
        sink_1::xpos=0   sink_1::ypos=20 \
        sink_2::xpos=640 sink_2::ypos=20 \
    ! videoconvert ! autovideosink fps-update-interval=5000 sync=false \
videotestsrc pattern="black" \
    ! video/x-raw,width=1280,height=520 \
    ! mix.sink_0 \
udpsrc port=5600 \
    ! application/x-rtp,encoding-name=JPEG,clock-rate=90000,payload=26 \
    ! rtpjpegdepay ! jpegdec \
    ! mix.sink_1 \
udpsrc port=5602 \
    ! application/x-rtp,encoding-name=JPEG,clock-rate=90000,payload=26 \
    ! rtpjpegdepay ! jpegdec \
    ! mix.sink_2

```



### Two raspi, one client 
```
gst-launch-1.0 -v rpicamsrc num-buffers=-1 ! image/jpeg,width=640,height=480,framerate=30/1 ! timeoverlay time-mode="buffer-time" ! jpegenc ! rtpjpegpay ! udpsink host=192.168.0.89 port=5000
gst-launch-1.0 -v rpicamsrc num-buffers=-1 ! image/jpeg,width=640,height=480,framerate=30/1 ! timeoverlay time-mode="buffer-time" ! jpegenc ! rtpjpegpay ! udpsink host=192.168.0.89 port=5001

gst-launch-1.0 -v videomixer name=mix ! videoconvert \
    ! fbdevsink device=/dev/fb0 \
    udpsrc port=5000 ! application/x-rtp, encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! videobox left=-642 border-alpha=0 ! mix. \
    udpsrc port=5001 ! application/x-rtp, encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! mix.
```
