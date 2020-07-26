#! /bin/bash

source ${BASH_SOURCE%/*}/common-utils.bash

# 必要な各コマンドの存在をチェックする
function check_command() {

    local readonly COMMAND_LIST=('unzip' 'mogrify' 'pdfunite')

    for command in ${COMMAND_LIST[@]}
    do
        if type ${command} 1>>${STANDART_OUTPUT} 2>>${ERROR_OUTPUT}
        then
            echo "OK. Command '${command}' exists"
        else
            echo "Error. Command '${command}' does not exist"
            return 1
        fi
    done

    return 0
}

# 引数に渡されたzipファイルをpdfに変換する
# 複数のzipファイルをワイルドカードで一括指定することも可能
function convert_zip_to_pdf() {

    # 引数で指定されたzipファイル名から、zipファイルの絶対パスと解凍するディレクトリの絶対パスを取得
    local readonly _FILEPATH=`get_realpath $1`
    local readonly _DIRPATH=${_FILEPATH%.zip}

    # zipファイルを解凍
    unzip ${_FILEPATH} -d ${_FILEPATH%/*} 1>>${STANDART_OUTPUT} 2>>${ERROR_OUTPUT}
    echo "${_FILEPATH} unzip complete."

    # pdf生成
    generate_pdf_from_image_file_in_dir ${_DIRPATH}

    # 展開したファイルを削除
    rm -rf ${_DIRPATH}

    return 0
}

# 1つのディレクトリ内の全ての画像ファイルから、1つのpdfファイルとzipファイルを生成する
function generate_zip_and_pdf_from_imagefile_in_dir() {

    # 対象ディレクトリの絶対パスを変数に保存
    local readonly _DIRPATH=`get_realpath $1`

    # zip生成
    generate_zip_from_dir ${_DIRPATH}

    # pdf生成
    generate_pdf_from_image_file_in_dir ${_DIRPATH}

    return 0
}

# 1つのディレクトリをzipファイルにする
function generate_zip_from_dir() {

    # 対象ディレクトリの絶対パスを変数に保存
    local readonly _DIRPATH=`get_realpath $1`

    # DS_Storeがあれば、削除
    delete_DS_Store ${_DIRPATH}

    # ディレクトリをzipに固める
    zip --recurse-paths --junk-paths ${_DIRPATH}.zip ${_DIRPATH} 1>>${STANDART_OUTPUT} 2>>${ERROR_OUTPUT}
    echo "${_DIRPATH} zip generation complete."

    return 0
}

# 1つのディレクトリ内の全ての画像ファイルから、1つのpdfファイルを生成する
function generate_pdf_from_image_file_in_dir() {

    # 対象ディレクトリの絶対パスを変数に保存
    local readonly _DIRPATH=`get_realpath $1`

    # DS_Storeがあれば、削除
    delete_DS_Store ${_DIRPATH}

    # ディレクトリの中身を全てPDFへ変換
    mogrify -format pdf ${_DIRPATH}/* 1>>${STANDART_OUTPUT} 2>>${ERROR_OUTPUT}

    # PDFに変換されたファイルを１つのPDFに結合(252ファイルを超えると処理できないので注意)
    pdfunite ${_DIRPATH}/*.pdf ${_DIRPATH}.pdf 1>>${STANDART_OUTPUT} 2>>${ERROR_OUTPUT}
    echo "${_DIRPATH} pdf generation complete."

    return 0
}

# 読み込まれた時点で、コマンドのチェックを行う
check_command