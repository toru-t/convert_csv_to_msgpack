# -*- coding: utf-8 -*-

require 'msgpack' # need to install
require 'optparse' # コマンドラインの引数取得用
require 'csv'
require 'zlib' # gzip用

#
# csv形式からMsgPack形式に変換するスクリプト
# csvの先頭にheader情報が付与されているものとする
# Author: T.Takahashi
# Date  : 2013/04/19
#

# コマンドライン引数の取得
def option
  return OptionParser.new do |parser|
    parser.on('-i', '--input INPUT_FILE', 'csv format, input file path.')
  end.getopts
end

filename = option['input']

# ヘッダー情報の取得
infile = CSV.open(filename, 'rb')

# gzipの作成
outfile = File.open("#{filename}.msgpack.gz", "wb")
gz = Zlib::GzipWriter.new(outfile)

# header情報の読み込みとheader分のシフト
header = infile.take(1)[0]

# CSVファイルからの読み込み
infile.each do |row|
  i = 0
  # 毎rowでHashの初期化
  data = Hash::new
  
  # 各columnの情報からhashの作成
  row.each do |item|
    data[header[i]] = item
    # 次のheaderへ
    i = i + 1
  end
  
  # 今回はcsvに時間情報が無いため付与する. とりあえず現在の時刻のunixtimeを格納する
  data['time'] = Time.now.to_i
  
  # msgpackに変換し、書き込み
  gz.write(data.to_msgpack)
end

gz.close
infile.close

puts("done.")
