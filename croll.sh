#! /bin/bash

IFS=$'\n';

site_list=(`cat "./news_list.list" `);

for line in ${site_list[@]}
do
  echo "$line searching..."
  if [ "$line" = "" ];then continue;fi;
  #検索条件ファイルを調べる
  #デバッグ用
  src=`wget -q -O - "$line"`;
  if [ ! -e egreps/${line} ]
  then 
    echo "検索条件ファイル[egreps/${line}]が無いため作成します";
    echo "$line" > egreps/${line};
    w3m "$line";
    echo "抽出条件を正規表現で記入してください";
    read y;
    vi egreps/${line};
  fi;
  reg="`cat egreps/${line}`";
  list=(`echo "$src"|egrep -o "$reg"|sort|uniq`);
  echo "list taked";
  #1件は多分あるはず。なのでボーダーは２件から
  if [ ${#list[@]} -lt 2 ]
  then 
    echo "抽出できませんでした。正規表現を修正してください";
    echo "URL = $line ";
    read y;
    w3m ${line};

    vi "./egreps/${line}";
  fi;
  
  for l in ${list[@]}
  do
    #相対パスか絶対パスかチェックして正規化する
    if [ 0 -eq `echo "$l"|egrep -c "^https*://"` ]
    then
      l="http://${line}${l}";
    fi;
    echo "L=$l";
  done;
done;
echo done.;
