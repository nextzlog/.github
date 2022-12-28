---
title: Scalaで実装するパターン認識と機械学習
subtitle: Scala's Pattern Recognition & Machine Learning
pdf: mine.pdf
---
## [1 初歩的な機械学習モデル](https://zenn.dev/nextzlog/articles/mine-chapter1)
1 初歩的な機械学習モデル

機械学習とは、説明変数 $\boldsymbol{x}$ と目的変数 $\boldsymbol{y}$ の組 $\left(\boldsymbol{x},\boldsymbol{y}\right)$ の集合 $\mathbb{T}$ から、変数 $\boldsymbol{x},\boldsymbol{y}$ の関係を表す関数 $f$ を推定する方法である。
集合 $\mathbb{T}$ が、関数 $f$ の取る値 $\boldsymbol{y}$ を具体的に列挙する場合は、その問題を**教師あり学習**と呼び、集合 $\mathbb{T}$ を**教師データ**と呼ぶ。

...
## [2 ニューラルネットワーク](https://zenn.dev/nextzlog/articles/mine-chapter2)
2 ニューラルネットワーク

**ニューラルネットワーク**は、線型回帰に似た**ニューロン**と呼ばれる関数を連結して、連鎖構造にした複雑な関数である。
単体のニューロンは、線型回帰の後に、**活性化関数**と呼ばれる非線型な関数 $f$ を適用した関数で、式 2.1で定義される。

...
## [3 サポートベクターマシン](https://zenn.dev/nextzlog/articles/mine-chapter3)
3 サポートベクターマシン

**サポートベクターマシン**は、分類問題に対し、各クラスの集団からの距離 $d$ が最大になる境界を学習する分類器である。
Fig. 3.1(1)に線型分離可能な問題の、(2)に線型分離が困難な問題の例を示す。まずは、線型分離可能な場合を解説する。

...
## [4 決定木の学習と汎化性能](https://zenn.dev/nextzlog/articles/mine-chapter4)
4 決定木の学習と汎化性能

意思決定の分野では、しばしば**決定木**と呼ばれる、質問と条件分岐の再帰的な木構造で、条件 $\boldsymbol{x}$ と結論 $y$ の関係を表す。
例えば、式 4.1は、海水浴の是非 $y$ を判断する決定木である。気象 $\boldsymbol{x}$ に対し、質問と条件分岐を繰り返し、結論を導く。

...
## [5 潜在的ディリクレ配分法](https://zenn.dev/nextzlog/articles/mine-chapter5)
5 潜在的ディリクレ配分法

自然言語の機械学習には、特有の困難がある。特定の形態素が出現する確率は低く、その確率も話題に応じて変化する。
話題も曖昧で多岐に渡り、教師あり学習が困難なので、単語 $w$ の背後にある話題 $z$ を、教師なし学習する方法を考える。

...
## [6 混合正規分布と最尤推定](https://zenn.dev/nextzlog/articles/mine-chapter6)
6 混合正規分布と最尤推定

適当な観測量 $\boldsymbol{x}$ から、それが従う確率分布 $p$ を推定する手法が最尤推定である。具体的には、分布 $p$ の母数を推定する。

$$\forall\boldsymbol{x}\colon \boldsymbol{x} =
...
