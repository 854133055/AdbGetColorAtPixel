#课程自动播放：点击固定位置x，y
#课程中断提醒：通过获取屏幕某一位置的色值判断是否课程中断
#以上1min执行一次
#功能依赖adb环境、MacOS（发通知）
#适合手机连adb无线调试

#自定义参数区域
deviceid="-s 10.30.127.247:5555"
nextBtnX=749   #注意赋值时不能有空格
nextBtnY=462
dialogBtnX=435
dialogBtnY=1621


widthheight=$(adb $deviceid shell wm size | sed "s/.* //")
width=$(($(echo $widthheight | sed "s/x.*//g" )+0))
height=$(($(echo $widthheight | sed "s/.*x//g" )+0))


GetColorAtPixel2 () {
        rm ./screen.dump 2> /dev/null
        adb $deviceid shell rm /sdcard/screen.dump
        adb $deviceid shell screencap /sdcard/screen.dump
        adb $deviceid pull /sdcard/screen.dump ./ > /dev/null
        # 每次尝试点击下一单元，按钮位置需要自己确定
        adb $deviceid shell input tap $nextBtnX $nextBtnY

        x=$dialogBtnX;y=$dialogBtnY; #弹窗红色按钮位置
        screenshot_size=$(($(wc -c screen.dump | awk '{print $1}')));
        buffer_size=$(($screenshot_size/($width*height)))
        let offset=$width*$y+$x+3
        color=$(dd if="screen.dump" bs=$buffer_size count=1 skip=$offset 2>/dev/null | hexdump | awk '{ print toupper($0) }' | grep -Eo "([0-9A-F]{2})+" | sed ':a;N;$!ba;s/\n//g' | awk 'NR>1 && NR<5')
        colorR=$(echo $color | awk '{print $1}')
        colorG=$(echo $color | awk '{print $2}')
        colorB=$(echo $color | awk '{print $3}')
        #弹窗红色按钮色值 r g b
        if [ $colorR == "B5" -a $colorG == "25" -a $colorB == "19" ]   #人机校验
        then 
                osascript -e 'display notification "需要人工操作" with title "挂课提醒"' #发送mac通知
                echo "需要提醒操作"
        elif [ $colorR == "F2" -a $colorG == "F2" -a $colorB == "F2" ] #人脸识别
        then
                osascript -e 'display notification "需要人工操作" with title "挂课提醒"'
                echo "需要提醒操作"
        fi   
}

while true 
do
        echo "挂课进行中"
        GetColorAtPixel2
        sleep 60
done