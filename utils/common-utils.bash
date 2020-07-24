#! /bin/bash

LOG_DIR=`pwd`
STANDART_OUTPUT="${LOG_DIR}/standart-output.log"
ERROR_OUTPUT="${LOG_DIR}/error.log"

# 指定されたディレクトリ配下の「.DS_Store」ファイルを削除する
function delete_DS_Store() {
    if [ -f $1/.DS_Store ]; then
        rm $1/.DS_Store
    fi
    return 0
}

# 指定したファイルのフルパスを取得
# ディレクトリの場合、末尾のスラッシュを除外する
function get_realpath() {
    local _dirpath=''
    if [ ${1:0:1} = / ] ; then
        _dirpath=$1
    else
        _dirpath=`pwd`/$1
    fi
    echo ${_dirpath%/}
    return 0
}

# 引数に渡された全てのファイル名を1からナンバリングする
# 3桁のゼロパディングとなり、1000以上の場合は、パディングされない
function numbering_only_imagefile() {

    # スペース含むファイル名の場合、コマンドが区切れてしまい正常に処理できないため、区切り文字を一時的に変更する
    PRE_IFS=$IFS
    IFS=$'\n'

    local readonly _DIRPATH=`get_realpath $1`

    # 連番にするための変数
    local i=1
    local num=''

    for _filename in ${_DIRPATH}/* ; do

        # ファイルパス、拡張子を取得
        local readonly _FILEPATH=${_filename}
        local _extension=${_FILEPATH##*.}

        if [ ${_extension} = jpg ] || [ ${_extension} = JPG ] || [ ${_extension} = jpeg ] || [ ${_extension} = JPEG ] ; then
            _extension=jpg
        elif [ ${_extension} = png ] || [ ${_extension} = PNG ] ; then
            _extension=png
        elif [ ${_extension} = gif ] || [ ${_extension} = GIF ] ; then
            _extension=gif
        elif [ ${_extension} = bmp ] || [ ${_extension} = BMP ] ; then
            _extension=bmp
        elif [ ${_extension} = tif ] || [ ${_extension} = TIF ] || [ ${_extension} = tiff ] || [ ${_extension} = TIFF ] ; then
            _extension=tif
        else
            echo 'no image.'
            return 1
        fi

        # 連番をゼロパディング(3桁)
        if [ ${i} -lt 10 ] ; then
            num=00${i}
        elif [ ${i} -lt 100 ] ; then
            num=0${i}
        else
            num=${i}
        fi

        # ファイル名変換(上書きしない)
        mv -n ${_FILEPATH} ${_DIRPATH}/${num}.${_extension}

        # 連番を1つ増やす
        i=`expr $i + 1`
    done

    # 区切り文字を元に戻す
    IFS=$PRE_IFS

    return 0
}