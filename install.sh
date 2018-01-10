#!/bin/bash
# 该脚本用来安装各类软件

# 使用未声明变量时退出
# set -u
# 遇到错误时退出
set -e

LINUX_CONFIG_PATH=$(dirname $(readlink -f $0))

ins_ssh()
{
    sudo apt-get install openssh-server
    sudo service ssh start
}

ins_samba()
{
    sudo apt-get install samba
    sudo apt-get install smbclient
    sudo /etc/init.d/samba start
    sudo /etc/init.d/samba stop
    sudo /etc/init.d/samba restart
    mkdir $HOME/pub/
    if [ ! -d "$HOME/pub" ]; then
        mkdir $HOME/pub
    fi
    #security=user 后面添加：
    sudo chmod 777 /etc/samba/smb.conf
    sudo echo "security=share" >> /etc/samba/smb.conf
    sudo echo "[share]" >> /etc/samba/smb.conf
    sudo echo "comment=this is Linux share directory" >> /etc/samba/smb.conf
    sudo echo "path=$HOME/pub/" >> /etc/samba/smb.conf
    sudo echo "public=yes" >> /etc/samba/smb.conf
    sudo echo "writable=yes" >> /etc/samba/smb.conf
    sudo echo "vaild users = $USER" >> /etc/samba/smb.conf
    sudo chmod 644 /etc/samba/smb.conf
    sudo smbpasswd -a $USER
    sudo /etc/init.d/samba restart
}

ins_python()
{
    sudo apt-get install -y python python-dev python-pip
    sudo apt-get install -y python3 python-dev python3-pip
    make -C $LINUX_CONFIG_PATH install-pip
    sudo pip install -U pip
    sudo pip install virtualenv
    mkdir -p ~/.env
    virtualenv -p python ~/.env/py2
    virtualenv -p python3 ~/.env/py3
}

ins_nvim()
{
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get install -y neovim

    sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
    sudo update-alternatives --config vi
    sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    sudo update-alternatives --config vim
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
    sudo update-alternatives --config editor

    # install plug.vim
    sudo apt-get install -y curl
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # install nvim config && plugin
    make -C $LINUX_CONFIG_PATH install-nvim
    nvim -c 'PlugInstall'
    # install nvim plug config
    ins_nvim_plug_conf
}

ins_zsh()
{
    # 注意：在init函数中， 该函数必须在最后执行，由于执行完终端会切换到zsh，从而终端脚本
    sudo apt-get install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

ins_fzf()
{
    if [[ -e ~/.fzf ]]; then
        (cd ~/.fzf; git pull)
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    sudo ~/.fzf/install
}

ins_other()
{
    # common
    sudo apt-get install -y vim openssh-client openssh-server lrzsz
    # zsh plugin
    sudo apt-get install -y autojump silversearcher-ag
    # nvim
    sudo apt-get install -y exuberant-ctags
}

# 安装nvim插件配置
ins_nvim_plug_conf()
{
    py_snip=$LINUX_CONFIG_PATH/nvim/plugged/vim-snippets/UltiSnips/python.snippets
    py_snip_bak=$LINUX_CONFIG_PATH/nvim/plugged/vim-snippets/UltiSnips/python.snippets.bak
    diy_py_snip=$LINUX_CONFIG_PATH/nvim/python.snippets
    if [[ -z $(grep "# DIY" $py_snip) ]]; then
        cp $py_snip $py_snip_bak
        ln -s $diy_py_snip $py_snip
        #cat $diy_py_snip >> $py_snip
    fi
}

# 安装用于nvim的python插件
ins_pytools()
{
    # for nvim
    pip install -U pip neovim jedi flake8 pep8 pylint

    # tools
    pip install thefuck pipreqs mycli alembic, ipdb
    if [[ -n $(python -V 2>&1 | grep -P '2\.7\.') ]]; then
        pip install ipython==5.4.1
    else
        pip install ipython
    fi
}

# 用于装完系统后安装各类工具
init()
{
    sudo apt-get update
    ins_ssh
    ins_samba
    ins_python
    ins_nvim
    ins_fzf
    ins_other
    make -C $LINUX_CONFIG_PATH
    ins_nvim_plug_conf
    ins_pytools
    # zsh必须在最后安装，由于它会将终端切到zsh，从而中断脚本
    ins_zsh
}

# 该函数必须在zsh安装完后安装，由于该函数会生成.oh-my-zsh目录，导致ins_zsh无法正常安装
ins_zsh_plug()
{
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestion
    make -C $LINUX_CONFIG_PATH install-zsh
}

help()
{
    cat << EOF
Usage:            ./install [OPT]
OPT:
    ins_ssh:            安装open-ssh
    ins_samba:          安装samba及相关配置，共享目录为~/pub
    ins_python:         安装python以及虚拟环境
    ins_nvim:           安装nvim以及相关插件
    ins_zsh:            安装zsh
    ins_fzf:            安装fzf
    ins_nvim_plug_conf: 安装nvim插件配置
    ins_pytools:        安装python工具，在安装python虚拟环境后安装
    init:               执行ins_ssh, ins_samba, ins_python, ins_nvim, ins_zsh, ins_fzf, ins_other, make, ins_nvim_plug_conf, ins_pytools
    ins_zsh_plug:       安装zsh的脚本，必须在安装zsh后执行，否则会阻碍oh-my-zsh的安装
EOF
}

# main
if [[ -z $1 || $1 == '-h' || $1 == '--help' ]]; then
    help
else
    $1
fi
