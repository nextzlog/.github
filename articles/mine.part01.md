---
title: Scalaで実装するパターン認識と機械学習 (1) 初歩的な機械学習モデル
---
## 1 初歩的な機械学習モデル

機械学習とは、説明変数 $\boldsymbol{x}$ と目的変数 $\boldsymbol{y}$ の組 $\left(\boldsymbol{x},\boldsymbol{y}\right)$ の集合 $\mathbb{T}$ から、変数 $\boldsymbol{x},\boldsymbol{y}$ の関係を表す関数 $f$ を推定する方法である。
集合 $\mathbb{T}$ が、関数 $f$ の取る値 $\boldsymbol{y}$ を具体的に列挙する場合は、その問題を**教師あり学習**と呼び、集合 $\mathbb{T}$ を**教師データ**と呼ぶ。

$$\forall\boldsymbol{x},\boldsymbol{y}\colon \left(\boldsymbol{x},\boldsymbol{y}\right)\in\mathbb{T} \Rightarrow \boldsymbol{y} \approx f(\boldsymbol{x}). \qquad(1.1)$$

教師あり学習で、目的変数 $\boldsymbol{y}$ が、**クラス**と呼ばれる離散値を取る場合を**分類**と呼ぶ。その初歩的な例が**最近傍法**である。
最近傍法では、未知の点 $\boldsymbol{x}$ のクラスは、 $\boldsymbol{x}$ の至近距離にある既知の $K$ 個の点の多数決で決まる。Fig. 1.1(1)に例を示す。

![images/knn.model.svg](images/knn.model.svg)

(1)  $k$  nearest neighbor diameters.

![images/knn.class.svg](images/knn.class.svg)

(2)  $k\!=\!10$  region segmentation.

Fig. 1.1  $k$  nearest neighbor model.

Fig. 1.1(2)は、各々が正規分布に従う3クラスの点の集合を学習し、空間全体をそれらのクラスに分類した結果である。
最近傍法では、適当な距離関数 $d$ を使う。距離関数 $d$ は、式 1.2の**距離の公理**を満たし、任意の2点の距離を定義する。

$$\forall \boldsymbol{x},\boldsymbol{y},\boldsymbol{z} \in \mathbb{R}^D \colon
0 \leq d(\boldsymbol{x},\boldsymbol{y}) = d(\boldsymbol{y},\boldsymbol{x}) \leq d(\boldsymbol{x},\boldsymbol{z}) + d(\boldsymbol{z},\boldsymbol{y}),\;
\boldsymbol{x} = \boldsymbol{y} \Leftrightarrow d(\boldsymbol{x},\boldsymbol{y}) = 0. \qquad(1.2)$$

最近傍法は、他の著名な教師あり学習の手法と比較して、事前の学習が不要である点が特徴的で、**遅延学習**と呼ばれる。
以上の議論に基づき、最近傍法を実装しよう。引数は、参照する近傍点の個数 $K$ と、集合 $\left\lbrace \boldsymbol{x},y\right\rbrace $ と、距離関数 $d$ である。

```scala
class KNN[D,T](k: Int, data: Seq[(D,T)], d: (D,D)=>Double) {
	def apply(x: D) = data.sortBy((p,t)=>d(x,p)).take(k).groupBy((p,t)=>t).maxBy((g,s)=>s.size)._1
}
```

使用例を以下に示す。距離関数の例として、初等幾何学の基礎であるユークリッド距離や**マンハッタン距離**を使用した。
後者は、座標の差の絶対値の総和を距離とする。距離関数の最適な選択肢は、分類対象の問題の性質に応じて変化する。

```scala
val samples2d = Seq.fill(100)(Seq.fill(2)(util.Random.nextGaussian) -> util.Random.nextBoolean)
val euclidean = new KNN(5, samples2d, (a,b) => math.sqrt(a.zip(b).map((a,b)=>(a-b)*(a-b)).sum))
val manhattan = new KNN(5, samples2d, (a,b) => a.zip(b).map(_-_).map(_.abs).sum)
```

### 1.1 線型回帰

教師あり学習で、目的変数 $\boldsymbol{y}$ が連続な値を取る場合を**回帰**と呼ぶ。その代表的な例が、**線型回帰**である。式 1.3に示す。
適当な基底関数 $\phi$ の線型結合である。基底関数は、関数 $f$ の形に応じて選ぶ。例えば、多項式基底やガウス基底を使う。

$$\boldsymbol{y} + \varepsilon \approx f(\boldsymbol{x}) = \displaystyle\sum_{k=0}^K w_k \phi_k(\boldsymbol{x}) = {}^t\boldsymbol{w}\boldsymbol{\phi}(\boldsymbol{x}). \qquad(1.3)$$

基本的に、変数 $\boldsymbol{x},\boldsymbol{y}$ は誤差 $\varepsilon$ を含む。例えば、映像や音声信号には、式 1.4に示す、分散 $\sigma^2$ の**ガウスノイズ**が重畳する。

$$y \sim
\mathcal{L}\left(f\right) =
p\left(y\,\middle|\,\boldsymbol{x},f\right) =
\mathcal{N}\left(y\,\middle|\,f(\boldsymbol{x}),\sigma^2\right) =
\displaystyle\frac{1}{\sqrt{2\pi}\sigma}\exp\left\lbrace -\displaystyle\frac{(y-f(\boldsymbol{x}))^2}{2\sigma^2}\right\rbrace . \qquad(1.4)$$

式 1.4の確率は、確率 $f$ の妥当性と見做せる。これを**尤度**と呼ぶ。尤度の最大値を探せば、最適な関数 $\hat{f}$ が推定できる。
これを**最尤推定**と呼び、機械学習の基本原理である。尤度の対数から、式 1.5が導出される。関数 $E$ を2乗誤差と呼ぶ。

$$\hat{f} =
\mathrm{arg\,max}_f \log p\left(y\,\middle|\,\boldsymbol{x},f\right) =
\mathrm{arg\,min}_f \left\lbrace y-f(\boldsymbol{x})\right\rbrace ^2 =
\mathrm{arg\,min}_f E(\boldsymbol{w}). \qquad(1.5)$$

誤差 $E$ を削減する方向に加重 $\boldsymbol{w}$ を動かす操作を繰り返すと、極小点に収束する。これを**勾配法**と呼ぶ。式 1.6に示す。

$$\hat{\boldsymbol{w}} = \boldsymbol{w} - \eta \nabla E(\boldsymbol{w}) = \boldsymbol{w} + \eta \displaystyle\sum_{n=1}^N \lbrace y_n - {}^t\boldsymbol{w} \boldsymbol{\phi}(\boldsymbol{x}_n)\rbrace  \boldsymbol{\phi}(\boldsymbol{x}_n),
\enspace\mathrm{where}\enspace
\eta \ll \left|\displaystyle\frac{\boldsymbol{w}}{\nabla E(\boldsymbol{w})}\right|. \qquad(1.6)$$

定数 $\eta$ を**学習率**と呼ぶ。以上の議論に基づき、線型回帰を実装する。引数は、学習率 $\eta$ と、集合 $\left\lbrace x,y\right\rbrace $ と、基底 $\Phi$ である。

```scala
class Regression(e: Double, data: Seq[(Double,Double)], p: Seq[Double=>Double], epochs: Int = 1000) {
	val w = Array.fill[Double](p.size)(0)
	def apply(x: Double) = w.zip(p.map(_(x))).map(_ * _).sum
	for(n <- 1 to epochs; (x,y) <- data) w.zip(p).map(_ + e * (y - this(x)) * _(x)).copyToArray(w)
}
```

Fig. 1.2は、多項式基底とガウス基底を利用して、各々の基底に適した形状の曲線に対し、線型回帰を行った結果である。

![images/lbf.power.svg](images/lbf.power.svg)

(1)  $\left\lbrace x^3,x^2,x,1\right\rbrace $ 

![images/lbf.gauss.svg](images/lbf.gauss.svg)

(2)  $G(x \vert \pm5, 1)$ 

Fig. 1.2 linear basis function model.

なお、加重 $\boldsymbol{w}$ は最適化されたが、基底関数 $\Phi$ 自体は最適化されず、**ハイパーパラメータ**として扱った点に注意を要する。

### 1.2 単純ベイズ分類器

自然言語で記述された記事の話題を分類する問題を考える。記事 $d$ は単語 $w_n$ の列であり、単語は話題 $c$ から生成される。
記事 $d$ の内容を話題 $c$ と仮定する。この仮説の尤度は、単語の共起を無視すれば、式 1.7の条件付き確率で定義される。

$$\mathcal{L}\left(c\right) =
P\left(d\,\middle|\,c\right) =
P\left(w_1,\dots,w_{N_d}\,\middle|\,c\right) =
\displaystyle\prod_{n=1}^{N_d} P\left(w_n\,\middle|\,c,w_1,...,w_{n-1}\right) \simeq
\displaystyle\prod_{n=1}^{N_d} P\left(w_n\,\middle|\,c\right). \qquad(1.7)$$

最適な話題 $\hat{c}$ は、式 1.8の条件付き確率を最大化する。確率 $P\left(c\right)$ は記事 $d$ とは独立した確率で、**事前確率**と呼ばれる。
式 1.8は、記事 $d$ を観測した後の話題 $c$ の確率で、これを**事後確率**と呼ぶ。式 1.8の変形は、**ベイズの定理**を使った。

$$\hat{c} =
\mathrm{arg\,max}_c P\left(c\,\middle|\,d\right) =
\mathrm{arg\,max}_c \displaystyle\frac{P\left(c\right)P\left(d\,\middle|\,c\right)}{P\left(d\right)} =
\mathrm{arg\,max}_c P\left(c\right)P\left(d\,\middle|\,c\right) =
\mathrm{arg\,max}_c P\left(c\right) \displaystyle\prod_{n=1}^{N_d} P\left(w_n\,\middle|\,c\right). \qquad(1.8)$$

ただし、初めて出現した単語 $w$ に対して、式 1.8の確率が $0$ になる事態を防ぐため、式 1.9の**ラプラス平滑化**を行う。

$$P\left(w\,\middle|\,c\right) =
\displaystyle\frac{P\left(w,c\right)}{P\left(c\right)} \simeq
\displaystyle\frac{N_{wc}+1}{N_c+1} > 0,
\Leftarrow
P\left(w\right) = \displaystyle\frac{1}{\left|V\right|},
\enspace\mathrm{where}\enspace
N_c = \displaystyle\sum_{w \in V} N_{wc}. \qquad(1.9)$$

変数 $N_{wc}$ は、組 $\left(w,c\right)$ の頻度である。式 1.9は、単語 $w$ の事前確率を第5章で学ぶディリクレ分布と仮定して導かれる。
式 1.8の分類器を**単純ベイズ分類器**と呼ぶ。以下に実装を示す。引数は、既知の記事の列と、対応する話題の列である。

```scala
class NaiveBayes[D<:Seq[W],W,C](texts: Seq[D], classes: Seq[C]) {
	val nw = scala.collection.mutable.Map[(W,C),Double]().withDefaultValue(1)
	val pc = classes.groupBy(identity).map(_ -> _.size.toDouble / texts.size)
	def pwc(c: C)(w: W) = nw(w,c) / texts.flatten.distinct.map(nw(_,c)).sum
	def pcd(d: D)(c: C) = math.log(pc(c)) + d.map(pwc(c)).map(math.log).sum
	def apply(d: D) = classes.distinct.maxBy(pcd(d))
	for((d,c) <- texts.zip(classes); w <- d) nw(w,c) += 1
}
```

Fig. 1.3(1)は、百科事典で各地方の記事から固有名詞を抽出して学習し、都道府県の記事の地方を推定した結果である。

![images/nbc.jmap8.svg](images/nbc.jmap8.svg)

(1) 8-regional division.

![images/nbc.jmap2.svg](images/nbc.jmap2.svg)

(2) 2-regional division.

Fig. 1.3 Japanese map division into regions based on classification of Wikipedia pages.

Fig. 1.3(2)は、東日本と西日本の記事を学習して、都道府県を分類した結果である。単純だが、高精度な分類ができる。
