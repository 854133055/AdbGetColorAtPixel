        deviceid="" #指定设备填写：例-s 10.30.127.247:5555
        
        #先进行截图
        rm ./screen.dump 2> /dev/null
        adb $deviceid shell rm /sdcard/screen.dump
        adb $deviceid shell screencap /sdcard/screen.dump
        adb $deviceid pull /sdcard/screen.dump ./ > /dev/null
        
        #获取屏幕信息，宽高
        widthheight=$(adb $deviceid shell wm size | sed "s/.* //")
        width=$(($(echo $widthheight | sed "s/x.*//g" )+0))
        height=$(($(echo $widthheight | sed "s/.*x//g" )+0))
        #获取截图大小（字节数）
        screenshot_size=$(($(wc -c screen.dump | awk '{print $1}')));
        #每像素字节数
        buffer_size=$(($screenshot_size/($width*height)))
        #假设获取100,100位置的颜色
        x=100;y=100 
        let offset=$width*$y+$x+3 
        #dd命令用于拷贝截图中指定大小的内容； hexdump获取对应内容的rgb值
        color=$(dd if="screen.dump" bs=$buffer_size count=1 skip=$offset 2>/dev/null | hexdump | awk '{ print toupper($0) }' | grep -Eo "([0-9A-F]{2})+" | sed ':a;N;$!ba;s/\n//g' | awk 'NR>1 && NR<5')
        echo $color