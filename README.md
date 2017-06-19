alphapolis_spliter.pl
===============================

alphapolis_spliter.plとは？
-------------------------------

　青空文庫形式のテキストファイルを任意のサイズに分割して保存します。

　スマホやタブレットの縦書きビューワで表示させる場合、
ファイルサイズが大きすぎると途端に動作が重くなってしまいます。

　そこでこのツールで分割してあげれば快適に閲覧できます。

## インストール

`  git clone  https://github.com/yama-natuki/aozora_splitter.git `

# 使い方

　例えば *natume_souseki.txt* を *512kb* のサイズでファイル名 *「natume-」* の頭文字を付けて保存する。

`    ./alphapolis_spliter.pl -s 512k -i natume_souseki.txt -p natume- `

とすれば、

`    natume-001.txt `

といった連番ファイルが作成されます。

`   ./alphapolis_spliter.pl --help `

とすればhelpが表示されます。

# ライセンス
　GPLv2


