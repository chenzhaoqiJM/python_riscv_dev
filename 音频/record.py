import webrtcvad
import pyaudio
import tempfile
import wave
import time

class RecAudio:
    def __init__(self, vad_mode=1, sld=1, channels=1, rate=48000, input_device_index=0):
        """
        Args:
            vad_mode: vad 的模式
            sld: 静音多少 s 停止录音
            channels: 声道数
            rate: 采样率
            input_device_index: 输入的设备索引
        """
        self._mode = vad_mode
        self._sld = sld

        # 参数配置
        self.FORMAT = pyaudio.paInt16  # 16-bit 位深
        self.CHANNELS = channels              # 单声道
        self.RATE = rate              # 16kHz 采样率
        FRAME_DURATION = 30       # 每帧时长（ms）
        self.FRAME_SIZE = int(self.RATE * FRAME_DURATION / 3000)  # 每帧采样数

        self.pa = pyaudio.PyAudio()
        self.stream = self.pa.open(
            format=self.FORMAT,
            channels=self.CHANNELS,
            rate=self.RATE,
            input=True,
            frames_per_buffer=self.FRAME_SIZE,
            input_device_index=input_device_index
        )

    def vad_audio(self):

        # 变量初始化
        frames = []                # 存储录制的音频帧
        speech_detected = False    # 是否已检测到人声
        last_speech_time = time.time()  # 最后检测到人声的时间
        MIN_SPEECH_DURATION = 1.0 # 最短录制时间（秒），避免误触发

        vad = webrtcvad.Vad()
        vad.set_mode(self._mode)

        temp_wav_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
        temp_wav_path = temp_wav_file.name
        print(temp_wav_path)

        try:
            while True:
                # 读取一帧音频数据
                frame = self.stream.read(self.FRAME_SIZE, exception_on_overflow=False)

                # print("%$%%%%%%%%%%%%%%%%%%%%%%%33333")
                # VAD 检测是否含人声
                is_speech = vad.is_speech(frame, self.RATE)
                if is_speech:
                    print("检测是否含人声: ", is_speech)
                if is_speech:
                    # 检测到人声，更新最后活动时间
                    last_speech_time = time.time()
                    if not speech_detected:
                        speech_detected = True
                        print("检测到语音，开始录制...")

                # # 如果已经开始录制，保存音频帧
                # if speech_detected:
                frames.append(frame)

                # 静音超时判断（且满足最短录制时间）
                current_time = time.time()
                if (speech_detected and
                    current_time - last_speech_time > self._sld and
                    current_time - last_speech_time > MIN_SPEECH_DURATION):
                    print(f"静音超过 {self._sld} 秒，停止录制。")
                    break

                time.sleep(0.01)

        except KeyboardInterrupt:
            print("手动中断录制。")
        finally:
            # 停止并关闭音频流
            print("关闭流")
            self.stream.stop_stream()
            # self.stream.close()
            # self.pa.terminate()

            if len(frames) > 0:
                with wave.open(temp_wav_path, "wb") as wf:
                    wf.setnchannels(self.CHANNELS)
                    wf.setsampwidth(self.pa.get_sample_size(self.FORMAT))
                    wf.setframerate(self.RATE)
                    wf.writeframes(b"".join(frames))
                print("音频已保存为 temp_wav_file")
                return temp_wav_path

    def record_audio(self):
        self.stream.start_stream()
        temp_wav_file_path = self.vad_audio()
        return temp_wav_file_path
