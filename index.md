---
title: アマチュア無線は次世代の体験へ
subtitle: Journal of Hamradio Informatics
bootstrap: true
layout: page
hide: true
---

![WireWorld](https://raw.githubusercontent.com/nextzlog/book/master/wire/WIRE1.gif)

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/DigitalDocument">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/fava" itemprop="url">
				<span itemprop="name">Computation Models &amp; Compilers on <i>Scala</i></span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">関数型言語を自作します。パーサコンビネータも手作り。計算論の基礎とチューリング機械を学ぶ。</p>
		<a class="card-link" href="https://pafelog.net/fava.pdf">記事</a>
		<a class="card-link" href="https://github.com/nextzlog/fava">実装</a>
	</div>
</div>

```scala
((f)=>((x)=>f(x(x)))((x)=>f(x(x))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/SoftwareApplication">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://zlog.org" itemprop="url">
				<span itemprop="name">zLog</span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">30年以上にわたって多くのアマチュア無線家が愛用するコンテスト用ロギングソフトの最新版です。</p>
		<a class="card-link" href="https://github.com/jr8ppg/zLog/releases/latest">最新版</a>
	</div>
</div>
<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/SoftwareApplication">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://zylo.pafelog.net" itemprop="url">
				<span itemprop="name">ZyLO</span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">アマチュア無線家を納得させる使い勝手はそのままに数多の拡張機能でzLogをカスタマイズします。</p>
		<a class="card-link" href="https://zylo.pafelog.net/market">マーケットプレイス</a>
		<a class="card-link" href="https://pafelog.net/zylo.pdf">発表資料</a>
		<a class="card-link" href="https://github.com/nextzlog/zylo">実装</a>
	</div>
</div>

```golang
package main

func init() {
	OnLaunchEvent = onLaunchEvent
}

func onLaunchEvent() {
	HandleButton("MainForm.CWPlayButton", onButton)
	HandleEditor("MainForm.CallsignEdit", onEditor)
}

func onButton(num int) {
	DisplayToast("click CWPlayButton")
}

func onEditor(key int) {
	DisplayToast(Query("QSO with $B"))
}
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/SoftwareApplication">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/ats4" itemprop="url">
				<span itemprop="name">ATS-4</span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">アマチュア無線のコンテスト運営を支援。集計結果をリアルタイムに把握し、作業効率を高めます。</p>
		<a class="card-link" href="https://pafelog.net/ats4.pdf">記事</a>
		<a class="card-link" href="https://allja1.org">ALLJA1コンテスト</a>
		<a class="card-link" href="https://realtime.allja1.org">リアルタイムコンテスト</a>
	</div>
</div>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<list xmlns:qxsl="qxsl.org">
	<item qxsl:time="2017-06-03T16:17:00Z" qxsl:call="QV1DOK" qxsl:band="14000" qxsl:mode="CW">
		<rcvd qxsl:rstq="599" qxsl:code="120103"/>
		<sent qxsl:rstq="599" qxsl:code="100110"/>
	</item>
	<item qxsl:time="2017-06-04T00:01:00Z" qxsl:call="QD1QXB" qxsl:band="21000" qxsl:mode="CW">
		<rcvd qxsl:rstq="599" qxsl:code="110117"/>
		<sent qxsl:rstq="599" qxsl:code="100110"/>
	</item>
</list>
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/SoftwareApplication">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://github.com/nextzlog/qxsl" itemprop="url">
				<span itemprop="name">Amateur-Radio Logging Library <i>QxSL</i></span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">汎用的なドメイン特化言語であらゆる書式の交信記録の処理とコンテストの得点計算に対応します。</p>
		<a class="card-link" href="https://nextzlog.github.io/qxsl/doc">API</a>
	</div>
</div>

```lisp
; scoring
(defmacro result (score mults names)
	`(block
		(setq mults (length (quote ,mults)))
		(setq names (length (quote ,names)))
		(ceiling (/ (* ,score mults) names))))
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/DigitalDocument">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/mine" itemprop="url">
				<span itemprop="name"><i>Scala's</i> Pattern Recognition &amp; Machine Learning</span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">線型回帰からサポートベクターマシンまで主要な機械学習を手作りします。情報科学を究める喜び。</p>
		<a class="card-link" href="https://pafelog.net/mine.pdf">記事</a>
		<a class="card-link" href="https://github.com/nextzlog/book">実装</a>
	</div>
</div>

```scala
class AdaDelta(r: Double = 0.95, e: Double = 1e-8) extends SGD {
	var eW, eE = 0.0
	def apply(dE: Double) = {
		lazy val v = math.sqrt(eW + e) / math.sqrt(eE + e)
		this.eE = r * eE + (1 - r) * math.pow(1 * dE, 2.0)
		this.eW = r * eW + (1 - r) * math.pow(v * dE, 2.0)
		this.w -= v * dE
	}
}
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/DigitalDocument">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/dusk.pdf" itemprop="url">
				<span itemprop="name">Parallel Work-Stealing Scheduler on <i>D</i></span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">並列処理系を自作。私たちの生活に浸透したメニーコアプロセッサを極限まで使い切る技術を学ぶ。</p>
		<a class="card-link" href="https://github.com/nextzlog/dusk">実装</a>
	</div>
</div>

```dlang
int dmm_dawn(int i1, int i2, int j1, int j2, int k1, int k2) {
	auto axes = [i2 - i1, j2 - j1, k2 - k1];
	if(axes[axes.maxIndex] <= 128) {
		dmm_leaf(i1, i2, j1, j2, k1, k2);
	} else if(axes.maxIndex == 0) {
		auto t1 = sched.fork!dmm_dawn(i1, (i1+i2)/2, j1, j2, k1, k2);
		auto t2 = sched.fork!dmm_dawn((i1+i2)/2, i2, j1, j2, k1, k2);
		sched.join(t1);
		sched.join(t2);
	} else if(axes.maxIndex == 1) {
		auto t1 = sched.fork!dmm_dawn(i1, i2, j1, (j1+j2)/2, k1, k2);
		auto t2 = sched.fork!dmm_dawn(i1, i2, (j1+j2)/2, j2, k1, k2);
		sched.join(t1);
		sched.join(t2);
	} else if(axes.maxIndex == 2) {
		auto t1 = sched.fork!dmm_dawn(i1, i2, j1, j2, k1, (k1+k2)/2);
		auto t2 = sched.fork!dmm_dawn(i1, i2, j1, j2, (k1+k2)/2, k2);
		sched.join(t1);
		sched.join(t2);
	}
	return 0;
}
```

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/DigitalDocument">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/chpl" itemprop="url">
				<span itemprop="name"><i class="mx-1">Chapel</i> the Parallel Programming Language</span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">クレイ社が贈る最高に洗練された並列プログラミング言語を網羅的に解説する日本語初の資料です。</p>
		<a class="card-link" href="https://pafelog.net/chpl.pdf">記事</a>
	</div>
</div>

<div class="card my-1 my-md-5" itemscope itemtype="http://schema.org/DigitalDocument">
	<div class="card-body">
		<h4 class="card-title">
			<a class="card-link" href="https://pafelog.net/type" itemprop="url">
				<span itemprop="name">Type Inference &amp; Garabage Collection on <i class="mx-1">C++</i></span>
			</a>
		</h4>
		<p class="card-text" itemprop="headline">プログラミング言語処理系の自作で不可欠な型推論とガベージコレクションを手作りする予定です。</p>
	</div>
</div>
