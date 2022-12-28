---
title: うさぎさんでもわかる並列言語Chapel (8) 並列処理
---
## 8 並列処理

Chapelは、[qthreads](https://github.com/qthreads/qthreads)の**軽量スレッド**を採用し、細粒度の並列処理が得意で、**タスク**の分岐と待機を高効率に実行できる。

### 8.1 タスク

まず、基本の構文を解説する。begin文でタスクを非同期に実行し、sync文でそのタスクを待機する。以下に例を示す。

```
sync {
	begin writeln("1st parallel task");
	begin writeln("2nd parallel task");
	begin writeln("3rd parallel task");
}
writeln("task 1, 2, 3 are finished");
```

begin文は、入れ子にできる。糖衣構文として、cobegin文でも同じ処理を記述できる。通常はcobegin文で事足りる。

```
cobegin {
	writeln("1st parallel task");
	writeln("2nd parallel task");
	writeln("3rd parallel task");
}
writeln("task 1, 2, 3 are finished");
```

外側で宣言された変数に、begin文やcobegin文で値を書き戻す場合は、with節の宣言が必要である。以下に例を示す。

```
var a: string;
var b: string;
sync {
	begin with(ref a) a = "1st parallel task";
	begin with(ref b) b = "2nd parallel task";
}
writeln(a);
writeln(b);
```

sync文やcobegin文による待機は、僅かな負荷を生じるので、効率を求める場合は、敢えてbegin文を使う場合もある。

```
inline proc string.shambles: void {
	proc traverse(a: int, b: int) {
		if b > a {
			const mid = (a + b) / 2;
			begin traverse(a, 0 + mid);
			begin traverse(1 + mid, b);
		} else writeln(this(a));
	}
	sync traverse(0, this.size - 1);
}
```

serial文は、条件式がtrueの場合に、並列処理を逐次処理に切り替える。並列処理の最適化やデバッグに利用できる。

```
serial true {
	begin writeln("1st serial task");
	begin writeln("2nd serial task");
}
```

### 8.2 反復処理

forall文とcoforall文は、並列化されたfor文である。OpenMPのomp parallel forに相当する。以下に例を示す。

```
forall i in 1..100 do writeln(i);
coforall i in 1..100 do writeln(i);
```

coforall文は、以下の糖衣構文である。反復回数と同じ個数のタスクを生成する。**タスク並列**を意識した機能と言える。

```
sync for i in 1..100 do begin writeln(i);
```

forall文は、タスクを生成する*leader*と、末端の逐次処理を担当する*follower*の、2個のイテレータで並列処理を行う。

```
iter foo(rng): int {
	for i in rng do yield i;
}
```

fooイテレータを多重に定義して、以下の派生型を実装する。これが*leader*で、タスクとデータを再帰的に分岐させる。

```
iter foo(param tag, rng): range where tag == iterKind.leader {
	if rng.size > 16 {
		const mid = (rng.high + rng.low) / 2;
		cobegin {
			for i in foo(tag, rng(..mid+0)) do yield i;
			for i in foo(tag, rng(mid+1..)) do yield i;
		}
	} else yield rng;
}
```

また、以下の派生型が*follower*で、並列処理の末端で、細粒度の逐次処理を担当する。データはfollowThisに渡される。

```
iter foo(param tag, rng, followThis): int where tag == iterKind.follower {
	for i in followThis do yield i;
}
```

処理の内容に応じて、最適なタスクとデータの分配方法を選べる点で、forall文は**データ並列**を意識した機能と言える。

```
forall i in foo(1..100) do writeln(i);
```

### 8.3 ロケール

Chapelでは、分散メモリ環境の構成単位を**ロケール**と呼ぶ。典型的には、1個の共有メモリ環境がロケールに相当する。
利用可能なロケールはLocalesで得られる。また、[GASNet](https://gasnet.lbl.gov)を使う場合は、環境変数`CHPL_COMM`を設定する必要がある。

```
coforall l in Locales do on l {
	writeln(here == l);
	writeln(here.name);
	writeln(here.numPUs());
}
```

特定のロケールを指定して、タスクを実行するには、on文を使う。また、hereを通じて、現在のロケールを参照できる。
他のロケールに存在するデータを参照すると、**レイテンシ**が発生する。on文は、参照の局所性を高める目的でも使える。

```
import BigInteger;
var x: BigInteger.bigint;
on Locales(0) do x = new BigInteger.bigint(12);
on x.locale do writeln(x, " is on ", x.locale);
```

### 8.4 分散配列

Chapelの配列のメモリ領域は、第8.3節のロケールに分散して配置できる。分配の方法は、dmapped演算子で指定する。
例えば、Blockを選ぶと、配列は矩形の塊で分配される。また、localSubdomainで、そのロケールの領域を取得できる。

```
use BlockDist;
var A: [{1..10,1..10} dmapped Block(boundingBox={1..10,1..10})] real;
for l in Locales do on l do for (i, j) in A.localSubdomain() do writeln(A(i, j).locale);
```

Cyclicを選ぶと、周期的に分配される。dmappedで確保した配列は、必要に応じてon文で参照の局所性を確保できる。

```
use CyclicDist;
var B: [{1..10,1..10} dmapped Cyclic(startIdx=(1,1))] real;
for l in Locales do on l do for (i, j) in B.localSubdomain() do writeln(B(i, j).locale);
```

### 8.5 アトミック変数

並列処理で、複数のタスクが共通の変数を読み書きする場合は、**アトミック演算**で、タスク間の競合を防ぐ必要がある。
競合の例を以下に示す。変数sumの値を取得し、新たな値を書き戻す間に、sumの値が変化すれば、誤った結果になる。

```
config const N = 80;
var sum: int;
do {
	coforall n in 1..N with(ref sum) do sum -= n * n;
	coforall n in 1..N with(ref sum) do sum += n * n;
} while sum == 0;
writeln(sum);
```

以下に、適切な実装を示す。addやsubの代わりに、fetchAddやfetchSubを使えば、演算する直前の値も取得できる。

```
config const N = 80;
var sum: atomic int;
do {
	coforall n in 1..N do sum.sub(n * n);
	coforall n in 1..N do sum.add(n * n);
} while sum.read() == 0; // infinite loop
writeln(sum);
```

### 8.6 ロック付き変数

sync型の変数を参照するには、readFEを使う。ただし、変数の状態が*empty*の場合は、*full*に遷移するまで待機となる。
writeEFで値を書き込むと、状態が*full*に遷移する。これは**排他制御**の機能であり、タスク間の競合を防ぐ効果がある。

```
config const N = 80;
var sum: sync int = 0;
do {
	coforall n in 1..N do {
		const v = sum.readFE();
		sum.writeEF(v + n * n);
	}
	coforall n in 1..N do {
		const v = sum.readFE();
		sum.writeEF(v - n * n);
	}
} while sum.readFF() == 0; // infinite loop
writeln(sum.readFF());
```