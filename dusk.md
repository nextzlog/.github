---
title: D言語で実装する並列スケジューラ入門
subtitle: Parallel Work-Stealing Scheduler on D
pdf: dusk.pdf
---
## [1 並列スケジューラの概念](https://zenn.dev/nextzlog/articles/dusk-chapter1)
**並列処理**とは、長時間を要する計算の内容を分割して複数のプロセッサに分担させ、処理速度の改善を図る技術を指す。
 ...
## [2 並列スケジューラの実装](https://zenn.dev/nextzlog/articles/dusk-chapter2)
第1.4節で議論した、ワークスティーリングを実装する。第2章に掲載する実装を順番に結合すると、完全な実装になる。
 ...
## [3 キャッシュ効率の最適化](https://zenn.dev/nextzlog/articles/dusk-chapter3)
並列処理では、台数効果も重要だが、逐次処理の性能も重要である。特に、参照局所性を意識した最適化が、必須となる。
 ...
## [4 行列積の並列処理の評価](https://zenn.dev/nextzlog/articles/dusk-chapter4)
第4章では、行列積の処理速度の計測を通じて、第2章で実装したスケジューラを利用した場合の**台数効果**を確認する。
 ...
## [5 高性能並列処理系の紹介](https://zenn.dev/nextzlog/articles/dusk-chapter5)
第5章で解説するduskは、*non uniform memory access* (NUMA) 型の共有メモリ環境を指向したスケジューラである。
 ...
