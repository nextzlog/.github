---
title: コンテスト運営を支援する自動集計システム
subtitle: Amateur-Radio Contest Administration System
pdf: ats4.pdf
---
## [1 はじめに](https://zenn.dev/nextzlog/articles/ats4-chapter1)
1 はじめに

本稿で解説する**自動集計システム**は、アマチュア無線のコンテストの効率的な運営を支援する、**ウェブシステム**である。
[ALLJA1コンテスト](https://ja1zlo.u-tokyo.org/allja1)を対象に、参加者の集計と結果発表を迅速化する目的で整備された。2014年以来の運用実績がある。

...
## [2 従来方式](https://zenn.dev/nextzlog/articles/ats4-chapter2)
2 従来方式

我が無線部では、開催後の書類受付の要領を抜本的に見直し、書類の曖昧性を排除して、自動処理する方法を模索した。
日本国内のコンテストでは、[JARL](https://jarl.org)が推奨する**サマリーシート**を、電子メールに添付して提出する方法が標準的である。

...
## [3 書類提出](https://zenn.dev/nextzlog/articles/ats4-chapter3)
3 書類提出

第2章で提起した問題意識から、我が無線部ではウェブ提出の仕組みを構築して、電子メールでの書類受付を廃止した。
ATS-3型の開発では、PCの操作が苦手な参加者に配慮して、無駄な画面遷移を排除し、**ユーザビリティ**の確保に努めた。

...
## [4 推奨書式](https://zenn.dev/nextzlog/articles/ats4-chapter4)
4 推奨書式

qxmlは、ATS-4型の内部で使われる書式である。[ADIF](https://adif.org)と対照的に、最小限を志向し、名前空間による拡張性を有する。

```java
...
