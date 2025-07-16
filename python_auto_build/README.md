# Python whl 自动化构建说明

## 环境设置

系统环境：bianbu desktop v2.2, https://nexus.bianbu.xyz/repository/image/k1/version/bianbu/v2.2/bianbu-24.04-desktop-k1-v2.2-20250430190125.zip

## auto_pypi_build

此文件夹下的脚本用于逐个构建 Python 社区最活跃的包

get_pkg_name.py 将 top-pypi-packages.csv 转为 txt

top-pypi-packages.csv 来源于 https://hugovk.github.io/top-pypi-packages/

执行构建流程：

```
 ./01create_venv.sh
 ./install_and_upload.sh
```

## hp_build

此文件夹下的脚本用于构建使用非常频繁的 Python 包

hp_pkgs.txt 里面包含了待构建的包名

使用 test.sh 可以测试一个包是否能通过该流程构建，使用方法

```
./test.sh numpy

```

执行流程：

```
 ./01create_venv.sh
 ./02hp_build.sh
```

## version build

此文件夹下脚本用于完善 https://git.spacemit.com/api/v4/projects/33/packages/pypi/simple 里面Python包的近1.5年的版本


执行流程：

```
 ./01create_venv.sh
 ./01version_build.sh
```

skip_pkgs.txt 里面记录需要跳过的包

02single_build.sh 脚本用于构建单个或者多个包的近期版本

用法：

```
./02single_build.sh opencv-python opencv-contrib-python
```