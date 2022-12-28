---
title: うさぎさんでもわかる並列言語Chapel
subtitle: Chapel the Parallel Programming Language
pdf: chpl.pdf
---
## [1 はじめに](https://zenn.dev/nextzlog/articles/chpl-chapter1)
1 はじめに

[Chapel](https://chapel-lang.org)は、**型推論**と**テンプレート**と**区分化大域アドレス空間**を特徴とし、高度に抽象化された**高生産性並列言語**である。
NUMAや分散メモリ環境を得意とし、通常の共有メモリ環境と同様の記述性ながら、高度な並列分散処理を実装できる。

...
## [2 式](https://zenn.dev/nextzlog/articles/chpl-chapter2)
2 式

C言語と同様に、演算子には、左右の**結合法則**と**優先順位**がある。優先順に掲載する。演算の順序は、括弧で調整できる。

|-|-|-|
...
## [3 変数](https://zenn.dev/nextzlog/articles/chpl-chapter3)
3 変数

varで宣言された識別子は、**変数**となる。宣言と同時に型と値を指定できる。自明な場合は、型または値を省略できる。
変数の値は、**代入演算子**で変更できる。その場合の変数を**左辺値**と呼ぶ。また、**スワップ演算子**で両辺の値を交換できる。

...
## [4 構文](https://zenn.dev/nextzlog/articles/chpl-chapter4)
4 構文

Chapelの構文には、Fortranの影響が見られる。**文**の区切りには、;を記す。基本的に、先頭の文から順番に実行される。
複数の文を括弧で閉じた**複文**は、静的な**スコープ**を形成し、内側で宣言された変数や関数は、外側に対して秘匿される。

...
## [5 関数](https://zenn.dev/nextzlog/articles/chpl-chapter5)
5 関数

Chapelの関数には、**手続き**と**イテレータ**と演算子の3種類が存在し、予約語のprocとiterとoperatorで定義できる。
記事では、単に手続きを指して関数と呼ぶ。関数は、*first-class*で、**テンプレート**の機能を持ち、例外処理も可能である。

...
## [6 構造体](https://zenn.dev/nextzlog/articles/chpl-chapter6)
6 構造体

Chapelでは、構造体を定義して、構造体に変数や関数を定義できる。変数を**フィールド**と呼び、関数を**メソッド**と呼ぶ。
構造体は、**クラス**と**レコード**と**共用体**に分類できる。クラスは**参照型**の性質を、レコードと共用体は**値型**の性質を持つ。

...
## [7 配列](https://zenn.dev/nextzlog/articles/chpl-chapter7)
7 配列

Chapelの配列には、**矩形配列**と**連想配列**の2種類が存在する。また、類似の概念に、**タプル**と**レンジ**と**領域**が存在する。

### 7.1 タプル
...
## [8 並列処理](https://zenn.dev/nextzlog/articles/chpl-chapter8)
8 並列処理

Chapelは、[qthreads](https://github.com/qthreads/qthreads)の**軽量スレッド**を採用し、細粒度の並列処理が得意で、**タスク**の分岐と待機を高効率に実行できる。

### 8.1 タスク
...
