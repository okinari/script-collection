#! /bin/bash

source utils/converter-utils.bash

# 引数で指定したディレクトリを1つのzipファイルにして、ディレクトリ内の全ての画像ファイルを1つのpdfファイルにする
for _file_dir in $@ ; do
    if [ -d ${_file_dir} ] ; then
        generate_zip_and_pdf_from_imagefile_in_dir ${_file_dir}
    fi
done