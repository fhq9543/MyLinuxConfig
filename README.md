# My linux auto config
Ubuntu higher versions that 16.04

# dotfiles
我的linux配置文件

# 说明
install.sh: 用于安装各类工具
Makefile: 用于安装各类配置文件

# 使用方法
## 下载
git clone git@github.com:fhq9543/MyLinuxConfig.git

## install.sh
install.sh -h|--help: 查看帮助

## Makefile
1. make [opt]: 安装对应选项的配置
2. make: 安装所有配置

## vim关键字：
**mapleader** 是自定义命令的起始键，一般都定义成逗号。

**map** 命令的用途是把一组键映射为其他的命令。

	常用的有 nmap、vmap、imap 和 cmap 等，分别适用于普通、可视、插入和命令行模式。
	加上 nore 这个前缀，确保替换成的命令是不会因其他设置而改动。
	
**silent** 表示不在命令行显示输入的命令。

**buffer** 表示只对当前文件有效。

**nowait** 表示不等待范围更大的组合匹配。例如同时定义这两组：

	nnoremap <Leader>wd dw
	nnoremap <buffer> <nowait> <Leader>w w	
	如果没有加「<**nowait**>」，按下「,w」后，要等一段时间确认之后你接下来要按的不是「d」，才会执行。
	加了之后就不会等待，而是直接执行了，缺点就是「,wd」会失效。
	
## 映射键：
	nnoremap <leader>W :execute 'w !sudo tee >/dev/null %' \| :e!<cr>  强制保存
	nnoremap <leader>X :execute 'w !sudo tee >/dev/null %' \| :q!<cr>  强制保存退出
	nnoremap <leader>C :!rm ~/.local/share/nvim/swap/* -rf<cr>    清除vim生成的swap文件。
	nnoremap <leader>T :vs term://zsh<cr>a   在nvim开启一个shell终端。

	F2 行号开关，用于鼠标复制代码用 
	F3 显示可打印字符开关  
	F4 换行开关   自动换行
	F5 插入是按F5，在粘贴的时候，不自动缩进
	,d 跳转到函数定义
	,a 跳转到函数被使用地方
	,m 标记
	,c 清除标记
	<ESC><ESC> 清除查找高亮
	,T 开终端
	,y 复制选中区到系统剪切板中
	,q :q
	,w :w
	,e :qa
	,x :x
	,z :q!
	,te 打开一个新标签
	,td 关闭标签
	,1  跳转到第一个标签
	nj,nk 相对行数跳转
