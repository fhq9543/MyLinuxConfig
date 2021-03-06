#!/bin/bash
# 该脚本用来安装各类软件

# 使用未声明变量时退出
# set -u
# 遇到错误时退出
set -e

LINUX_CONFIG_PATH=$(dirname $(readlink -f $0))

ins_samba()
{
    echo "Now execute ins_samba."
    sudo apt-get install -y samba
    sudo apt-get install -y smbclient
    sudo /etc/init.d/samba-ad-dc start
    samba_dir=$HOME/pub/
    if [ ! -d $samba_dir ]; then
        mkdir $samba_dir
    fi
    smb_conf=/etc/samba/smb.conf
    smb_conf_bak=/etc/samba/smb.conf.bak
    if [ ! -f $smb_conf_bak ]; then
        sudo cp $smb_conf $smb_conf_bak
    fi

    sudo cp $smb_conf_bak $smb_conf
    #security=user 后面添加：
    sudo chmod 777 /etc/samba/smb.conf
    sudo echo "security=share" >> /etc/samba/smb.conf
    sudo echo "[share]" >> /etc/samba/smb.conf
    sudo echo "comment=this is Linux share directory" >> /etc/samba/smb.conf
    sudo echo "path=$samba_dir" >> /etc/samba/smb.conf
    sudo echo "public=yes" >> /etc/samba/smb.conf
    sudo echo "writable=yes" >> /etc/samba/smb.conf
    sudo echo "vaild users = $USER" >> /etc/samba/smb.conf
    sudo chmod 644 /etc/samba/smb.conf
    sudo smbpasswd -a $USER
    sudo /etc/init.d/samba-ad-dc restart
}

ins_python()
{
    echo "Now execute ins_python."
    #sudo apt-get install -y python python-dev python-pip
    sudo apt-get install -y python3 python3-pip
    make -C $LINUX_CONFIG_PATH install-pip
    sudo pip3 install -U pip
    sudo pip3 install virtualenv
    mkdir -p ~/.env
    #virtualenv -p python ~/.env/py2
    virtualenv -p python3 ~/.env/py3
    virtualenv -p python3 ~/.env/web
}

ins_nvim()
{
    echo "Now execute ins_nvim."
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
    echo "Now execute ins_zsh."
    # 注意：在init函数中， 该函数必须在最后执行，由于执行完终端会切换到zsh，从而终端脚本
    sudo apt-get install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

ins_fzf()
{
    echo "Now execute ins_fzf."
    if [[ -e ~/.fzf ]]; then
        (cd ~/.fzf; git pull)
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    sudo ~/.fzf/install
}

ins_other()
{
    echo "Now execute ins_other."
    # common
    sudo apt-get install -y vim openssh-client openssh-server lrzsz
    # zsh plugin
    sudo apt-get install -y autojump silversearcher-ag
    # nvim
    sudo apt-get install -y exuberant-ctags
    sudo service ssh start
}

# 安装nvim插件配置
ins_nvim_plug_conf()
{
    echo "Now execute ins_nvim_plug_conf."
    py_snip=$LINUX_CONFIG_PATH/nvim/plugged/vim-snippets/UltiSnips/python.snippets
    py_snip_bak=$LINUX_CONFIG_PATH/nvim/plugged/vim-snippets/UltiSnips/python.snippets.bak
    diy_py_snip=$LINUX_CONFIG_PATH/nvim/python.snippets

    if [[ -z $(grep "# DIY" $py_snip)  ]]; then
        cp $py_snip $py_snip_bak
    else
        cp $py_snip_bak $py_snip
    fi
    cat $diy_py_snip >> $py_snip
}

# 安装用于nvim的python插件
ins_pytools()
{
    echo "Now execute ins_pytools."
    # for nvim
    pip3 install -U pip testresources neovim jedi flake8 pep8 pylint

    # tools
    sudo pip3 install thefuck pipreqs mycli alembic ipdb
    #if [[ -n $(python -V 2>&1 | grep -P '2\.7\.') ]]; then
        #sudo pip install ipython==5.4.1
    #else
    sudo pip3 install ipython
    #fi
    sudo pip3 install neovim thefuck
    sudo cp -r ~/.local/lib/python3.6/site-packages/greenlet* \
            ~/.local/lib/python3.6/site-packages/jedi* \
            ~/.local/lib/python3.6/site-packages/msgpack* \
            ~/.local/lib/python3.6/site-packages/neovim* \
            ~/.local/lib/python3.6/site-packages/parso* \
            ~/.env/py3/lib/python3.6/site-packages/
}

# 用于装完系统后安装各类工具
init()
{
    echo "Now execute apt-get update."
    sudo apt-get update
    echo "Now install git."
    sudo apt-get install -y git
    ins_python
    ins_nvim
    ins_fzf
    ins_other
    make -C $LINUX_CONFIG_PATH
    ins_pytools
    # zsh必须在最后安装，由于它会将终端切到zsh，从而中断脚本
    ins_zsh
}

# 该函数必须在zsh安装完后安装，由于该函数会生成.oh-my-zsh目录，导致ins_zsh无法正常安装
ins_zsh_plug()
{
    echo "Now execute ins_zsh_plug."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    make -C $LINUX_CONFIG_PATH install-zsh
}

help()
{
    cat << EOF
Usage:            ./install [OPT]
OPT:
    ins_samba:          安装samba及相关配置，共享目录为~/pub
    ins_python:         安装python以及虚拟环境
    ins_nvim:           安装nvim以及相关插件ins_nvim_plug_conf
    ins_fzf:            安装fzf
    ins_other:          安装open-ssh, autojump, ctags, vim等
    ins_pytools:        安装python工具，在安装python虚拟环境后安装
    ins_zsh:            安装zsh
    init:               执行ins_ssh, ins_python, ins_nvim, ins_fzf, ins_other, make, ins_pytools, ins_zsh
    ins_zsh_plug:       安装zsh的脚本，必须在安装zsh后执行，否则会阻碍oh-my-zsh的安装
    ins_nvim_plug_conf: 安装nvim插件配置
EOF
}

# main
if [[ -z $1 || $1 == '-h' || $1 == '--help' ]]; then
    help
else
    $1
fi
