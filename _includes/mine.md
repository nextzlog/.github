### Scalaで実装するパターン認識と機械学習

線型回帰からサポートベクターマシンまで主要な機械学習を手作りします。情報科学を究める喜び。

- [記事](mine) ([PDF](mine.pdf))
- [実装](https://github.com/nextzlog/mine)

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
