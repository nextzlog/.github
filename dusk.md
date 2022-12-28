---
title: D言語で実装する並列スケジューラ入門
subtitle: Parallel Work-Stealing Scheduler on D
pdf: dusk.pdf
---
## [1 並列スケジューラの概念](https://zenn.dev/nextzlog/articles/dusk-chapter1)
### 1.1 データレベルの並列性
### 1.2 タスクレベルの並列性
### 1.3 粗粒度なタスクの分配
### 1.4 ワークスティーリング
## [2 並列スケジューラの実装](https://zenn.dev/nextzlog/articles/dusk-chapter2)
### 2.1 スケジューラ
### 2.2 タスクの実装
### 2.3 キューの実装
## [3 キャッシュ効率の最適化](https://zenn.dev/nextzlog/articles/dusk-chapter3)
### 3.1 キャッシュミス率の抑制
### 3.2 キャッシュの競合の抑制
## [4 行列積の並列処理の評価](https://zenn.dev/nextzlog/articles/dusk-chapter4)
### 4.1 提案実装によるタスク並列化
### 4.2 既存実装によるタスク並列化
### 4.3 反復処理によるデータ並列化
### 4.4 台数効果の評価と結果の解釈
## [5 高性能並列処理系の紹介](https://zenn.dev/nextzlog/articles/dusk-chapter5)
### 5.1 利用方法
# make build install -C dusk
# ldconfig
### 5.2 環境変数
### 5.3 性能測定
