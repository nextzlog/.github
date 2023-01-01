### 電子ログ自動集計ライブラリ QxSL

{{site.briefs.qxsl}}

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
