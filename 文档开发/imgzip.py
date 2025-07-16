
import cv2
import os

# 设置图片文件夹路径
folder_path = "path/to/images_dir"  # <-- 替换为你的路径

# 支持的图片扩展名（大小写不敏感）
valid_exts = (".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".webp")

# 压缩后的最大高度
max_height = 1080

# 遍历文件夹中的所有文件
for filename in os.listdir(folder_path):
    if not filename.lower().endswith(valid_exts):
        continue

    file_path = os.path.join(folder_path, filename)

    # 读取图像
    img = cv2.imread(file_path)

    if img is None:
        print(f"无法读取图像: {filename}")
        continue

    height, width = img.shape[:2]

    # 判断是否需要压缩
    if height > max_height:
        scale = max_height / height
        new_width = int(width * scale)
        img = cv2.resize(img, (new_width, max_height), interpolation=cv2.INTER_AREA)
        print(f"已压缩: {filename} → 高度 {max_height}")
    else:
        print(f"无需压缩: {filename} (高度: {height})")

    # 检查是否为4通道图像（带alpha），转为3通道
    if img.shape[2] == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

    # 保存为 .jpg（与原文件同名，仅扩展名变为 .jpg）
    base_name = os.path.splitext(filename)[0]
    new_file_path = os.path.join(folder_path, base_name + ".jpg")

    success = cv2.imwrite(new_file_path, img, [int(cv2.IMWRITE_JPEG_QUALITY), 85])
    if success:
        print(f"已保存为 JPG: {base_name}.jpg")

        # 删除原图（如果不是 .jpg 文件）
        if not filename.lower().endswith(".jpg"):
            try:
                os.remove(file_path)
                print(f"已删除原图: {filename}")
            except Exception as e:
                print(f"删除失败: {filename}，原因: {e}")
    else:
        print(f"保存 JPG 失败: {filename}")
