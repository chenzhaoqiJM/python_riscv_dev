import serial

PORT = '/dev/ttyUSB0'  # 改为你的接收端串口
BAUDRATE = 115200
ser = serial.Serial(PORT, BAUDRATE, timeout=2)

if not ser.is_open:
    print(f"{PORT} 打开失败")
    exit()

print(f"{PORT} 接收端启动")

while True:
    data = ser.read(64)  # 最多读64字节
    if data:
        print(f"[RX] 接收到: {data}")
