
# rtspserver

## server
`v4l2rtspserver -H 720 -W 1280 -F 25 -P 8555 /dev/video0`

## stream video demo
./stream "( filesrc location=mars2020_animation.mp4 ! qtdemux ! h264parse ! rtph264pay name=pay0 pt=96 )"

