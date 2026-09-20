# 伺か in Zig

[ukadll_zig](https://github.com/syobocat/ukadll_zig)と[shiori_zig](https://github.com/syobocat/shiori_zig)を利用して作られたZig製のデモゴーストです。

## 特徴

- クロスコンパイルが容易\
  Zig製なのでクロスコンパイルが容易です。macOSやLinux、FreeBSDからでもゴースト開発ができます。
- `.nar`作成スクリプトつき\
  `create_nar.sh`を実行するだけで`.nar`が作成できます。`updates.txt`も生成されます。GitHub Actions等でビルドするのに便利。
- Utataneネイティブ対応\
  `.dll`に加え`.dylib`を生成するようになっており、macOS向けベースウェアの[Utatane](https://dl.wmsci.com/utatane/)にネイティブ対応しています。

## ライセンス

MIT-0の実質的なパブリックドメインで利用可能です。テンプレートとしてご自由にお使いください。
