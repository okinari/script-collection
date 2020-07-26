#! /bin/bash

source ${BASH_SOURCE%/*}/utils/common-utils.bash

# 引数で指定したディレクトリ内の全ての画像ファイルを数値の連番に変更する
for _file_dir in "$@" ; do
    if [ -d "${_file_dir}" ] ; then
        numbering_only_imagefile "${_file_dir}"
    fi
done