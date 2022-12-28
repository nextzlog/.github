---
title: コンテスト運営を支援する自動集計システム (1) はじめに
---
## 1 はじめに

本稿で解説する**自動集計システム**は、アマチュア無線のコンテストの効率的な運営を支援する、**ウェブシステム**である。
[ALLJA1コンテスト](https://ja1zlo.u-tokyo.org/allja1)を対象に、参加者の集計と結果発表を迅速化する目的で整備された。2014年以来の運用実績がある。

### 1.1 開発の経緯

[ALLJA1コンテスト](https://ja1zlo.u-tokyo.org/allja1)は毎年6月の開催だが、2009年に部員が数名に減勢した我が無線部では、開催困難な状況に陥った。
運営業務は、以下の3段階に区分できるが、開催後の業務の負担が課題で、結果発表が年度末まで遅延する有様だった。

|-|-|
|---|---|
|開催前の業務 | 規約策定と告知 |
|開催中の業務 | 開催状況の把握 |
|開催後の業務 | 書類受付  $\cdot$  採点  $\cdot$  審査  $\cdot$  暫定結果発表  $\cdot$  最終結果発表  $\cdot$  賞状発送|

2010年の増勢により、当面は開催を継続する方針に決着したが、外部に運営を委託する可能性も検討される状況だった。
駒場には委託に抵抗を感じる学生もおり、単独での運営を継続するために整備を始めたのが、下記のシステム群である。

|-|-|-|-|
|---|---|---|---|
|ATS-1型 | 2012年 | 第25回 | 部分的なサマリーシートの自動処理の実現 |
|ATS-2型 | 2013年 | 第26回 | 書類解析の厳密かとウェブ書類受付の実現 |
|ATS-3型 | 2014年 | 第27回 | 書類解析と暫定結果発表のリアルタイム化 |
|ATS-4型 | 2017年 | 第30回 | 自動集計システムとコンテスト規約の分離|

2013年には、交信記録を完全に自動処理できるATS-2型を試作し、悲願だった、締切から2日での結果速報を達成した。
2021年には、従来の[ALLJA1コンテスト](https://ja1zlo.u-tokyo.org/allja1)に加え、JS2FVOらの発案で[リアルタイムコンテスト](https://ja1zlo.u-tokyo.org/rt/rt1.html)の運営業務にも対応した。

### 1.2 実装の公開

現行のATS-4型の完全な実装は、GitHubで無償公開している。Gitを利用して、以下の操作で最新の実装を取得できる。

```bash
$ git clone https://github.com/nextzlog/ats4
```

以下の操作で起動できる。ただし、ATS-4型の開発言語はScalaなので、ATS-4型のビルドと起動には[sbt](https://scala-sbt.org)が必要である。

```bash
$ cd ats4
$ sbt "start -Dhttp.port=8000"
```

ATS-4型では、交信記録の解析や得点計算を再利用可能な形で整備した。これがqxslである。以下の操作で取得できる。

```bash
$ git clone https://github.com/nextzlog/qxsl
```

ATS-4型の特色は、**ドメイン特化言語**による規約の定義を修正すれば、容易に様々なコンテストに移植可能な点にある。
具体的には、交信記録の解析や得点計算が、RubyやLISPで記述される。以下に、対応済みの規約と、その実装を示す。

|-|-|
|---|---|
|[電通大コンテスト](https://www.ja1zgp.com)の例 | [https://github.com/nextzlog/ats4/blob/master/conf/rules/JA1ZGP/uec.rb](https://github.com/nextzlog/ats4/blob/master/conf/rules/JA1ZGP/uec.rb) |
|[多摩川コンテスト](http://apollo.c.ooco.jp)の例 | [https://github.com/nextzlog/ats4/blob/master/conf/rules/JI1YEG/tama.rb](https://github.com/nextzlog/ats4/blob/master/conf/rules/JI1YEG/tama.rb)|

我が無線部では、全てのコンテストがATS-4型を活用する将来を構想しており、ATS-4型の移植は、無償で受け付ける。
