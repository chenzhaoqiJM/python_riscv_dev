import os
import time
import sys
from record import RecAudio
rec_audio = RecAudio(vad_mode=1, sld=1, channels=1, rate=48000, input_device_index=0) # 输入设备索引为1，表示使用USB麦克风; 输入设备索引为0，表示使用HDMI麦克风

if __name__ == '__main__':
    try:
        while True:
            print("Press enter to start!")
            input() # enter 触发
            audio_file = rec_audio.record_audio()

    except KeyboardInterrupt:
        print("process was interrupted by user.")
