#!/bin/bash
# 生成物をDesktopの「AIの作業場」フォルダ内にだけコピーする専用スクリプト。
# 用途: リポジトリやscratchpad内のファイルを、決まった保存先フォルダにだけ届ける。
# 安全のため、AIの作業場フォルダの外には絶対に書き込まない。

set -euo pipefail

BASE_DIR="$HOME/Desktop/AIの作業場"

usage() {
  echo "使い方: $(basename "$0") <コピー元> <AIの作業場からの相対パス>" >&2
  echo "例:    $(basename "$0") box_v4.png 箱デザイン/GoldenRabbit_箱デザイン_サンプル.png" >&2
  exit 1
}

[ $# -eq 2 ] || usage

SRC="$1"
REL_DEST="$2"

[ -e "$SRC" ] || { echo "エラー: コピー元が存在しません: $SRC" >&2; exit 1; }

# 相対パスの先頭が / や .. を含んでAIの作業場の外に出ようとしていないか弾く
case "$REL_DEST" in
  /*|*..*)
    echo "エラー: 保存先はAIの作業場からの相対パス（.. や先頭 / なし）で指定してください: $REL_DEST" >&2
    exit 1
    ;;
esac

mkdir -p "$BASE_DIR"
DEST="$BASE_DIR/$REL_DEST"
DEST_DIR="$(dirname "$DEST")"
mkdir -p "$DEST_DIR"

# 実際に解決したパスがAIの作業場配下に収まっているか最終確認
RESOLVED_BASE="$(cd "$BASE_DIR" && pwd -P)"
RESOLVED_DEST_DIR="$(cd "$DEST_DIR" && pwd -P)"
case "$RESOLVED_DEST_DIR" in
  "$RESOLVED_BASE"|"$RESOLVED_BASE"/*)
    ;;
  *)
    echo "エラー: 保存先がAIの作業場の外になっています: $RESOLVED_DEST_DIR" >&2
    exit 1
    ;;
esac

if [ -d "$SRC" ]; then
  cp -r "$SRC" "$DEST"
else
  cp "$SRC" "$DEST"
fi

echo "保存しました: $DEST"
