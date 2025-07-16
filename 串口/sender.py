import serial
import time

PORT = '/dev/ttyUSB0'  # 改为你的发送端串口
BAUDRATE = 115200
ser = serial.Serial(PORT, BAUDRATE, timeout=1)

if not ser.is_open:
    print(f"{PORT} 打开失败")
    exit()

print(f"{PORT} 发送端启动")

count = 0
while True:
    message = f"msg_{count}".encode('utf-8')
    ser.write(message)
    print(f"[TX] 发送: {message}")
    count += 1
    time.sleep(1)
