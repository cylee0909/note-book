# 编译ffmpeg到Android平台

## 编译环境

cygwin + ndk_r19 + ffmpeg ffmpeg-4.1.3

## 环境搭建

* cygwin下载： http://www.cygwin.com/

* ndk_r19 下载：https://developer.android.google.cn/ndk/downloads/

* ffmpeg 4.1.3下载： http://www.ffmpeg.org/download.html

## 工具准备
ndk 解压到某（eg D:/Softs/Android/Sdk/ndk-bundle) 目录
ffmpeg 解压到某目录

## 编译脚本
在 ffmpeg 解压目录创建 android_build.sh文件
```bash
#!/bin/bash
 
NDK=D:/Softs/Android/Sdk/ndk-bundle3
SYSROOT=$NDK/platforms/android-L/arch-arm/
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/windows-x86_64
function build_one
{
echo build_one start...
export TMPDIR=D:/cygwin64/tmp
echo $TMPDIR
./configure \
--extra-libs=-lgcc \
--prefix=$PREFIX \
--enable-shared \
--disable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-avdevice \
--disable-doc \
--disable-symver \
--disable-encoders  \
--disable-muxers \
--disable-demuxers \
--disable-parsers  \
--disable-bsfs \
--disable-protocols \
--disable-indevs \
--disable-outdevs \
--disable-filters \
--enable-filter=colorbalance \
--disable-decoders \
--enable-decoder=h264 \
--enable-decoder=hevc \
--enable-decoder=aac \
--enable-muxer=mp4 \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--target-os=linux \
--arch=arm \
--cpu=armv7-a \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG
#make clean
 
 
echo make -j4 start
make -j4
 
echo make install start
make install
}
CPU=arm
PREFIX=D:/ffmpeg/android/$CPU
ADDI_CFLAGS="-marm"
build_one
```
## 配置configure
打开 ffmpeg源码内 configure 文件进行如下修改：
SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)'$(LIBDIR)/$(LIBNAME)''
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR)$(SLIBNAME)'
替换为：
SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)'$(LIBDIR)/$(LIBNAME)''
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'

## 可能遇到的问题

* 临时目录问题，各种提示.....temp\No such file or directory

  更改ffmpeg自带的configure文件  

  \# set temporary file name
  : ${TMPDIR:=$TEMPDIR}
  : ${TMPDIR:=$TMP}
  : ${TMPDIR:=tmp}改为

  \# set temporary file name
  : ${TMPDIR:=$TEMPDIR}
  : ${TMPDIR:=$TMP}
  : ${TMPDIR:=D:/cygwin64/tmp}
  
  都要确保D:/cygwin64/tmp路径存在
  
* 其他路径问题
  由于使用cygwin系统编译ffmpeg，在配置文件中一律使用windows路径形式
  
* make -j8 时B0错误

  ```c
  libavcodec/aaccoder.c: In function 'search_for_ms':
  libavcodec/aaccoder.c:803:25: error: expected identifier or '(' before numeric constant
                       int B0 = 0, B1 = 0;
                           ^
  libavcodec/aaccoder.c:865:28: error: lvalue required as left operand of assignment
                           B0 += b1+b2;
                              ^
  libavcodec/aaccoder.c:866:25: error: 'B1' undeclared (first use in this function)
                           B1 += b3+b4;
                           ^
  libavcodec/aaccoder.c:866:25: note: each undeclared identifier is reported only once for each function it appears in
  CC    libavcodec/aacpsdsp_fixed.o
  ffbuild/common.mak:60: recipe for target 'libavcodec/aaccoder.o' failed
  make: *** [libavcodec/aaccoder.o] Error 1
  ```

  需要将libavcodec/aaccoder.c里面的B0定义改一下, 直接注释掉就可以了。

* 其他错误
  如遇其他错误可参考[这篇文章](http://alientechlab.com/how-to-build-ffmpeg-for-android/)