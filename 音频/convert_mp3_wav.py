from pydub import AudioSegment
mp3_audio = AudioSegment.from_file("jiesuanwancheng.mp3", format="mp3")
mp3_audio.export("jiesuanwancheng.wav", format="wav")
print("转换完成")