---
title: Scalaで自作するプログラミング言語処理系
subtitle: Computation Models & Compilers on Scala
pdf: fava.pdf
---
## [1 言語処理系を作る](https://zenn.dev/nextzlog/articles/fava-chapter1)
本書では、**ラムダ計算**を理論的背景に持つ独自のプログラミング言語の**インタプリタ**を自作して、**計算論**の基礎を学ぶ。
 ...
## [2 計算モデルを作る](https://zenn.dev/nextzlog/articles/fava-chapter2)
**言語処理系**とは、言語仕様に沿って書かれた計算手順を読み取り、任意の計算機を構築または模倣する**万能機械**である。
 ...
## [3 ラムダ計算の理論](https://zenn.dev/nextzlog/articles/fava-chapter3)
実在する計算機を意識した第2章の計算モデルに対し、関数の**評価**と**適用**による計算手順の抽象化がラムダ計算である。
 ...
## [4 簡単なコンパイラ](https://zenn.dev/nextzlog/articles/fava-chapter4)
第2章の計算モデルは、C言語やラムダ計算など**高水準言語**の内容を実行するには原始的すぎる。そこで、翻訳を行う。
 ...
## [5 自作言語の仕様書](https://zenn.dev/nextzlog/articles/fava-chapter5)
favaは静的型付け言語である。組込み型には、整数型と実数型と論理型と文字列型と関数型があり、型推論が行われる。
 ...
## [6 命令セットを作る](https://zenn.dev/nextzlog/articles/fava-chapter6)
第6章では、第2.4節で実装した計算機を拡張し、**分岐命令**を備えた**命令セット**を設計して、条件分岐や関数を実現する。
 ...
## [7 コンパイラを作る](https://zenn.dev/nextzlog/articles/fava-chapter7)
第7章では、第5章の仕様に従って、式を第6章の命令列に翻訳する仕組みを作る。構文解析には第4.3節の実装を使う。
 ...
