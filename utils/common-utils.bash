#! /bin/bash

LOG_DIR=`pwd`
STANDART_OUTPUT="${LOG_DIR}/standart-output.log"
ERROR_OUTPUT="${LOG_DIR}/error.log"

# 指定されたディレクトリ配下の「.DS_Store」ファイルを削除する
function delete_DS_Store() {
    if [ -f "$1/.DS_Store" ] ; then
        rm "$1/.DS_Store" 1>>"${STANDART_OUTPUT}" 2>>"${ERROR_OUTPUT}"
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

    # まずは10桁に変換
    for _filename in `ls ${_DIRPATH}` ; do

        # ファイルパスを取得
        local readonly _FILEPATH=${_DIRPATH}/${_filename}

        # 拡張子を取得
        local readonly _EXTENSION=`get_image_extension "${_FILEPATH}"`
        if [ $? -ne 0 ] ; then
            echo ${_EXTENSION}
            return 1
        fi

        # 連番をゼロパディング(10桁)
        local readonly _FILE_NUMBER=`get_zero_padded_value ${i} 10`

        # ファイル名変換(上書きしない)
        mv -n "${_FILEPATH}" "${_DIRPATH}/${_FILE_NUMBER}.${_EXTENSION}" 1>>"${STANDART_OUTPUT}" 2>>"${ERROR_OUTPUT}"

        # 連番を1つ増やす
        i=`expr $i + 1`
    done

    # 連番をリセット
    i=1

    for _filename in `ls ${_DIRPATH}` ; do

        # ファイルパスを取得
        local readonly _FILEPATH=${_DIRPATH}/${_filename}
        #local _extension=${_FILEPATH##*.}

        # 拡張子を取得
        local readonly _EXTENSION=`get_image_extension "${_FILEPATH}"`
        if [ $? -ne 0 ] ; then
            echo ${_EXTENSION}
            return 1
        fi

        # 連番をゼロパディング(3桁)
        local readonly _FILE_NUMBER=`get_zero_padded_value ${i} 3`

        # ファイル名変換(上書きしない)
        mv -n "${_FILEPATH}" "${_DIRPATH}/${_FILE_NUMBER}.${_EXTENSION}" 1>>"${STANDART_OUTPUT}" 2>>"${ERROR_OUTPUT}"

        # 連番を1つ増やす
        i=`expr $i + 1`
    done

    # 区切り文字を元に戻す
    IFS=$PRE_IFS

    return 0
}

# 拡張子が画像ファイルのものならば、拡張子を取得する
# 画像ファイル以外の拡張子の場合、エラーとなる
function get_image_extension() {

    # ファイル名の末尾の.(ドット)以降を取得
    local readonly _extension=${1##*.}

    if [ ${_extension} = jpg ] || [ ${_extension} = JPG ] || [ ${_extension} = jpeg ] || [ ${_extension} = JPEG ] ; then
        echo 'jpg'
        return 0
    elif [ ${_extension} = png ] || [ ${_extension} = PNG ] ; then
        echo 'png'
        return 0
    elif [ ${_extension} = gif ] || [ ${_extension} = GIF ] ; then
        echo 'gif'
        return 0
    elif [ ${_extension} = bmp ] || [ ${_extension} = BMP ] ; then
        echo 'bmp'
        return 0
    elif [ ${_extension} = tif ] || [ ${_extension} = TIF ] || [ ${_extension} = tiff ] || [ ${_extension} = TIFF ] ; then
        echo 'tif'
        return 0
    fi

    # いづれにも該当しない場合、エラー
    echo "\nerror: '$1' is no image extension.\n"
    return 1
}

# 指定された数値を指定された桁数でゼロパティングした値を取得する
function get_zero_padded_value() {

    # 指定された数値、桁数を取得
    local readonly _TARGET_NUMBER=$1
    local readonly _NUMBER_OF_DIGIT=$2

    # 連番をゼロパディング(10桁)
    echo `printf "%0${_NUMBER_OF_DIGIT}d" ${_TARGET_NUMBER}`
    return 0
}