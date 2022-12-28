---
title: Scalaで実装するパターン認識と機械学習 (5) 潜在的ディリクレ配分法
---
## 5 潜在的ディリクレ配分法

自然言語の機械学習には、特有の困難がある。特定の形態素が出現する確率は低く、その確率も話題に応じて変化する。
話題も曖昧で多岐に渡り、教師あり学習が困難なので、単語 $w$ の背後にある話題 $z$ を、教師なし学習する方法を考える。

### 5.1 確率的潜在意味解析

話題 $z$ は観測できず、潜在的な情報である。また、話題 $z$ の分布は、記事の主題に応じて変化する。その点を考慮しよう。
具体的には、単語 $w$ の出現が、試行1回の**多項分布**に従うと考える。また、単語 $w$ と話題 $z$ が従う確率分布を仮定する。

$$P\left(w,z,\phi,\theta\right) =
P\left(w\,\middle|\,\phi\right) P\left(\phi\right) P\left(z\,\middle|\,\theta\right) P\left(\theta\right) =
\left(\displaystyle\prod_{v=1}^V \phi_{zv}^{N_v}\right) \mathrm{Dir}\left(\phi\,\middle|\,\nu\right) \left(\displaystyle\prod_{k=1}^K \theta_k^{N_k}\right) \mathrm{Dir}\left(\theta\,\middle|\,\alpha\right). \qquad(5.1)$$

変数 $N_v,N_k$ は、単語 $v$ と話題 $k$ の出現の数で、総和は $1$ である。変数 $\phi_v,\theta_k$ は、単語 $v$ と話題 $k$ が出現する確率である。
式 5.2の多項分布は、話題 $k$ が確率 $\theta_k$ で現れる記事から $N$ 語を取得して、話題 $k$ の単語が $N_k$ 個となる確率を与える。

$$P\left(z\,\middle|\,\theta\right) =
N! \displaystyle\prod_{k=1}^K \displaystyle\frac{\theta_k^{N_k}}{N_k!},
\enspace\mathrm{where}\enspace
\displaystyle\sum_{k=1}^K N_k = N. \qquad(5.2)$$

式 5.3の**ディリクレ分布**は、話題 $k$ の単語が $N_k-1$ 個だった場合に、実際に話題 $k$ が確率 $\theta_k$ で出現する確率を与える。
これは、変数 $N$ を連続量に拡張した多項分布である。式 5.3に従う話題 $z$ の推定を、**潜在的ディリクレ配分法**と呼ぶ。

$$P\left(\theta\right) =
\mathrm{Dir}\left(\theta\,\middle|\,N\right) =
\Gamma\left(\displaystyle\sum_{k=1}^K N_k\right) \displaystyle\prod_{k=1}^K \displaystyle\frac{\theta_k^{N_k-1}}{\Gamma\left(N_k\right)} =
\displaystyle\frac{1}{\mathrm{B}\left(N\right)} \displaystyle\prod_{k=1}^K \theta_k^{N_k-1}. \qquad(5.3)$$

式 5.3で、関数 $\Gamma$ は**ガンマ関数**で、自然数の階乗 $(n-1)!$ を複素数の階乗に拡張した関数である。式 5.4に定義する。

$$\Gamma\left(n\right) = \int_0^{\infty} x^{n-1} e^{-x} dx. \qquad(5.4)$$

関数 $\mathrm{B}$ は**ベータ関数**を多変量に拡張した複素関数で、式 5.2に現れる多項係数の逆数に相当する。式 5.5が成立する。

$$\mathrm{B}\left(N\right) =
\int \displaystyle\prod_{k=1}^K x_k^{N_k+1} d\boldsymbol{x} =
\int\cdots\int \displaystyle\prod_{k=1}^K x_k^{N_k+1} dx_1 dx_2 \cdots dx_K,
\enspace\mathrm{where}\enspace
\displaystyle\sum_{k=1}^K x_k = 1. \qquad(5.5)$$

式 5.5から、式 5.6が簡単に導ける。式 5.6の性質は、確率 $\theta$ を実際の記事から推定する際に、重要な役割を果たす。

$$P\left(z\right) =
\int P\left(z\,\middle|\,\theta\right) P\left(\theta\right) d\boldsymbol{\theta} =
N! \displaystyle\frac{\mathrm{B}\left(\hat{\alpha}\right)}{\mathrm{B}\left(\alpha\right)} \displaystyle\prod_{k=1}^K \displaystyle\frac{1}{N_k!},
\enspace\mathrm{where}\enspace
\hat{\alpha}_k = \alpha_k + N_k. \qquad(5.6)$$

記事を学習すると、確率 $\theta_k$ の最適値は式 5.7に従う。これを事後確率と呼ぶ。また、式 5.2を確率 $\theta_k$ の尤度と呼ぶ。
学習前では、どの話題の出現も均等と仮定し、式 5.3に従って、確率 $\theta_k$ に初期値を設定できる。これを事前確率と呼ぶ。

$$\theta_k \sim
P\left(\theta\,\middle|\,z\right) =
\displaystyle\frac{P\left(z\,\middle|\,\theta\right) P\left(\theta\right)}{P\left(z\right)} =
\displaystyle\frac{1}{\mathrm{B}\left(\hat{\alpha}\right)} \displaystyle\prod_{k=1}^K \theta_k^{\hat{\alpha}_k-1}. \qquad(5.7)$$

式 5.7は、観測を重視して、尤度を最適化する最尤推定と対照的で、観測の偏りを重視する。これを**ベイズ推定**と呼ぶ。
最尤推定では、観測の偏りに起因した過学習が発生するが、その点が解消される。さて、式 5.5から式 5.8が導ける。

$$\underset{}{\mathbf{E}}\!\left[\,\theta_k\,\right] \underset{}{\mathbf{E}}\!\left[\,\phi_{kv}\,\right] =
\displaystyle\frac{\hat{\alpha}_k}{\left\|\hat{\alpha}\right\|_1}
\displaystyle\frac{\hat{\nu}_{kv}}{\left\|\hat{\nu}_k\right\|_1},
\enspace\mathrm{where}\enspace
\left\|\hat{\alpha}\right\|_1 = \displaystyle\sum_{k=1}^K \alpha_k,\;
\left\|\hat{\nu}_k\right\|_1 = \displaystyle\sum_{v=1}^V \nu_{kv}. \qquad(5.8)$$

式 5.8に従う乱数により、変数 $z$ を何度も選び直すと、最終的に真の分布 $\theta$ に収束する。これを**モンテカルロ法**と呼ぶ。
第6章で学ぶ変分ベイズ法と比較して、収束に時間を要するが、複雑な確率分布にも適用でき、並列処理も容易である。

### 5.2 潜在的な話題の学習

第5.1節の潜在的ディリクレ配分法を実装する。まず、単語と話題の組 $\left(w,z\right)$ を実装する。話題 $z$ は無作為に初期化する。

```scala
case class Word[W](v: W, k: Int) {
	var z = util.Random.nextInt(k)
}
```

潜在的ディリクレ配分法の本体を実装する。引数は、記事と単語の集合に、話題の総数と、母数 $\alpha,\nu$ の初期値を与える。

```scala
class LDA[D,W](texts: Map[D,Seq[W]], val k: Int, a: Double = 0.1, n: Double = 0.01) {
	val words = texts.map(_ -> _.map(Word(_,k)))
	val vocab = words.flatMap(_._2).groupBy(_.v)
	val nd = words.map((d,s) => d -> Array.tabulate(k)(k => s.count(_.z == k) + a)).toMap
	val nv = vocab.map((v,s) => v -> Array.tabulate(k)(k => s.count(_.z == k) + n)).toMap
	val nk = Array.tabulate(k)(k => nv.map(_._2(k)).sum)
	def apply(k: Int) = vocab.keys.toList.filter(v => nv(v).max == nv(v)(k))
	def probs(v: W, d: D) = 0.until(k).map(k => nv(v)(k) * nd(d)(k) / nk(k))
}
```

以上の実装を継承して、モンテカルロ法を実装する。まず、適当な組 $\left(w,z\right)$ を選び、その分を変数 $\alpha_z,\nu_z$ から除去する。
次に、式 5.8に従う乱数を**ノイマンの棄却法**で生成し、話題 $z$ を選び直し、母数 $\alpha_z,\nu_z$ に加える。この手順を繰り返す。

```scala
class Gibbs[D,W](texts: Map[D,Seq[W]], k: Int, epochs: Int = 500) extends LDA(texts, k) {
	for(epoch <- 1 to epochs; (document,words) <- util.Random.shuffle(words); w <- words) {
		nk(w.z) -= 1
		nv(w.v)(w.z) -= 1
		nd(document)(w.z) -= 1
		val uni = util.Random.between(0, probs(w.v,document).sum.toDouble)
		w.z = probs(w.v,document).scan(0.0)(_+_).tail.indexWhere(_ >= uni)
		nd(document)(w.z) += 1
		nv(w.v)(w.z) += 1
		nk(w.z) += 1
	}
}
```

以上で完成した。使用例を示す。これは、素数 $k$ を話題と、その倍数を単語と見做し、無作為に生成した数列を学習する。
単語 $v$ の共起と、記事毎に異なる話題の分布を再現した。学習が進むと、同じ約数を持つ整数が、同じ話題に分配される。

```scala
val bases = Seq(2,3,5,7,11)
def sample(n: Int, m: Int, k: Int) = Seq.fill(n)(k * util.Random.nextInt(m / k + 1)) 
val texts = Seq.fill(1000)(bases.map(sample(util.Random.nextInt(100),50,_)).flatten)
val gibbs = new Gibbs(texts.indices.zip(texts).toMap, bases.size)
```

### 5.3 単語の類似度の推定

確率 $\phi$ を単語の意味を表す変数と考え、その距離に従って、単語を分類しよう。第6章で実装する $k$ -*means*を利用する。

```scala
val kmeans = new Kmeans(gibbs.nv.values.map(_.toList).toSeq, gibbs.k)
val topics = texts.flatten.distinct.topicBy(v => kmeans(gibbs.nv(v)))
for(topic <- topics.values) println(topic.toSeq.sorted.mkString(","))
```

以下に、出力を示す。共通の約数を持つ自然数が綺麗に分離できた。共起に基づく確率的な話題推定の有効性が窺える。

```bash
0,7,14,21,28,35,42,49,56,63,70,77
5,10,15,20,25,30,40,45,50,55,60,65,75,80
3,6,9,12,18,24,27,33,36,39,48,51,54,57,66,69,72,78
2,4,8,16,22,26,32,34,38,44,46,52,58,62,64,68,74,76
```
