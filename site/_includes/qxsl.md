### 電子ログ自動集計ライブラリ QxSL

汎用的なドメイン特化言語であらゆる書式の交信記録の処理とコンテストの得点計算に対応します。

- [仕様書](https://nextzlog.github.io/qxsl/docs)
- [最新版](https://github.com/nextzlog/qxsl)

```lisp
; scoring
(defmacro result (score mults names)
	`(block
		(setq mults (length (quote ,mults)))
		(setq names (length (quote ,names)))
		(ceiling (/ (* ,score mults) names))))
```
