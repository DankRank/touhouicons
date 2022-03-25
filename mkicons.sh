#!/bin/sh
game_path="${game_path:-/srv/egor}"
exec_line="${exec_line:-env LC_ALL=ja_JP WINEPREFIX=/srv/egor/wine32 wine}"

games_supported="alcostg th06 th07 th08 th09 th095 th10 th11 th12 th125 th128 th13 th14 th143 th15 th16 th165 th17 th18"
games=""
datadir="${XDG_DATA_HOME:-$HOME/.local/share}"

for i in $games_supported; do
	if [ -d "$game_path/$i" ]; then
		games="${games:+$games }$i"
	fi
done
get_game_title() {
	awk 'BEGIN { FS="\t" } $1 == "'"$1"'" { print $2; exit }' < titles.txt
}
output_desktop() {
	echo "[Desktop Entry]"
	echo "Type=Application"
	echo "Name=$1"
	echo "Comment=$(get_game_title "$1")"
	echo "Path=$game_path/$1"
	echo "Exec=$exec_line $1"
	echo "Icon=$1"
	echo "Categories=Game;"
}
download_icon() {
	sum="$(echo -n "$1" | md5sum)"
	curl -o $1 "https://www.thpatch.net/w/images/$(echo "$sum" | cut -c1)/$(echo "$sum" | cut -c1-2)/$1"
}
for i in $games; do
	output_desktop "$i" > "$i.desktop"
	desktop-file-install --dir="$datadir/applications" "$i.desktop"
	[ ! -f "Icon_$i.png" ] && download_icon "Icon_$i.png"
	cp "Icon_$i.png" "$datadir/icons/$i.png"
done
