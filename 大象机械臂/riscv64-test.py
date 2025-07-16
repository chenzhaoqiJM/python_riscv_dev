from pymycobot import MyCobot280, MyCobot320
import time

# mc = MyCobot320('/dev/ttyACM0',115200,debug=True)

mc = MyCobot320('/dev/ttyUSB0',115200,debug=True)


mc.send_angles([0,0,0,0,0,0],50)
time.sleep(2)
print("回零中...")

