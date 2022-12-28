---
title: うさぎさんでもわかる並列言語Chapel
subtitle: Chapel the Parallel Programming Language
pdf: chpl.pdf
---
## [1 はじめに](https://zenn.dev/nextzlog/articles/chpl-chapter1)
[Chapel](https://chapel-lang.org)は、**型推論**と**テンプレート**と**区分化大域アドレス空間**を特徴とし、高度に抽象化された**高生産性並列言語**である。
 ...
## [2 式](https://zenn.dev/nextzlog/articles/chpl-chapter2)
C言語と同様に、演算子には、左右の**結合法則**と**優先順位**がある。優先順に掲載する。演算の順序は、括弧で調整できる。
 ...
## [3 変数](https://zenn.dev/nextzlog/articles/chpl-chapter3)
varで宣言された識別子は、**変数**となる。宣言と同時に型と値を指定できる。自明な場合は、型または値を省略できる。
 ...
## [4 構文](https://zenn.dev/nextzlog/articles/chpl-chapter4)
Chapelの構文には、Fortranの影響が見られる。**文**の区切りには、;を記す。基本的に、先頭の文から順番に実行される。
 ...
## [5 関数](https://zenn.dev/nextzlog/articles/chpl-chapter5)
Chapelの関数には、**手続き**と**イテレータ**と演算子の3種類が存在し、予約語のprocとiterとoperatorで定義できる。
 ...
## [6 構造体](https://zenn.dev/nextzlog/articles/chpl-chapter6)
Chapelでは、構造体を定義して、構造体に変数や関数を定義できる。変数を**フィールド**と呼び、関数を**メソッド**と呼ぶ。
 ...
## [7 配列](https://zenn.dev/nextzlog/articles/chpl-chapter7)
Chapelの配列には、**矩形配列**と**連想配列**の2種類が存在する。また、類似の概念に、**タプル**と**レンジ**と**領域**が存在する。
 ...
## [8 並列処理](https://zenn.dev/nextzlog/articles/chpl-chapter8)
Chapelは、[qthreads](https://github.com/qthreads/qthreads)の**軽量スレッド**を採用し、細粒度の並列処理が得意で、**タスク**の分岐と待機を高効率に実行できる。
 ...
