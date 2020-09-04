#!/bin/bash

git status
echo 'git status ok.'
read -p "确保修改的文件无误后按任意一个键继续梭 ."  #这个地方做暂停动作,方便查看修改的文件是否符合要求
git add .
echo 'git add ok.'
git commit -m $1   #$1是sss.sh 后面的第一个参数（即为commit的内容）
echo 'git commit ok.'
git pull
echo 'git pull ok.'
# sleep 3
# read -p "Press any key to continue."
git push
echo 'git push ok.'

