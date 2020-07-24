#! /bin/bash

source utils/converter-utils.bash

# 引数で指定したzipファイル内の全ての画像ファイルをまとめて1つのpdfファイルに変換する
for _file_dir in $@ ; do
    if [ -d ${_file_dir} ] ; then
        convert_zip_to_pdf ${_file_dir}
    fi
done