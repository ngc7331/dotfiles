# xu_zh's dotfiles
个人常用环境配置文件

## Usage
1. Clone 本仓库
2. 运行
```
chmod +x install.sh && ./install.sh
```
3. 根据提示进一步设置

## .zshrc
修改自 [Kali Linux](https://www.kali.org/) 默认的 zsh 配置文件，增加了：
1. [thefuck](https://github.com/nvbn/thefuck) 支持，需要手动安装`thefuck`
2. git 仓库信息显示

prompt 如下：
```
┌──(user@host)-[path]-(repo@branch [*+])
└─$
```
当不处于某一 git 仓库时，`-(repo@branch [*+])`不显示

`*`表示有未暂存的修改，`+`表示有已暂存但未提交的修改
