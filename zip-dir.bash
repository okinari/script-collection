#! /bin/bash

# 引数で指定したディレクトリを全てzipファイルにする
for _file_dir in $@ ; do
    if [ -d ${_file_dir} ] ; then
        zip -r ${_file_dir}.zip ${_file_dir}
    fi
done