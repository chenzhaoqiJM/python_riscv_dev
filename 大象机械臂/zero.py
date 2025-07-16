from pymycobot import *
import time
# 默认使用9000端口
#其中"172.20.10.14"为机械臂IP，请自行输入你的机械臂IP
mc =MyCobot280Socket("192.168.1.233",9000)

mc = MyCobot320("/dev/ttyAMA0", baudrate="115200")

#连接正常就可以对机械臂进行控制操作
# mc.send_angles([0,0,0,0,0,0],20)

# mc.send_angles([5.88, -11.33, -60.11, -16.69, 4.3, -121.55],20)
# mc.send_angles([0,0,0,0,0,0],20)

# mc.release_all_servos()

print(mc.get_angles())

res = mc.get_angles()
print(res)

mc.send_angles([0,0,0,0,0,0],30)

