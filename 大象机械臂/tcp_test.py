from pymycobot import MyCobot280Socket
import time
# 默认使用9000端口
#其中"172.20.10.14"为机械臂IP，请自行输入你的机械臂IP
mc =MyCobot280Socket("192.168.1.233",9000)

#连接正常就可以对机械臂进行控制操作
# mc.send_angles([0,0,0,0,0,0],20)

# mc.send_angles([5.88, -11.33, -60.11, -16.69, 4.3, -121.55],20)
# mc.send_angles([0,0,0,0,0,0],20)

# mc.release_all_servos()

print(mc.get_angles())

res = mc.get_angles()
print(res)

mc.send_angles([0,0,0,0,0,0],30)

mc.send_angles([-1.4, -4.48, -86.3, 3.95, -2.54, 0.0],30)

mc.send_angles([-52.38, -33.48, -51.94, 1.93, -1.05, 0.0],30)

time.sleep(1)

mc.send_angles([0,0,0,0,0,0],30)

mc.send_angles([-23.99, -41.22, -112.14, 59.5, -2.19, 0.0],30)
