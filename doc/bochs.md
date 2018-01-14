# 过程

0. download bochs latest version
1. ./configure --enable-debugger --enable-disasm
2. make
3. sudo make install

# 安装依赖的包

1. sudo apt-get install build-essential
2. sudo apt-get install xorg-dev

> ERROR: X windows gui was selected, but X windows libraries were not found.

## build-essential

build-essential 指的是编译程序必须的软件包。

> apt-cache depends build-essential
> build-essential
> 依赖: libc6-dev
> 依赖: <libc-dev>
> libc6-dev
> 依赖: gcc
> 依赖: g++
> 依赖: make
> 依赖: dpkg-dev
> 安装了该包，c/c++ 等编译器都会被安装
