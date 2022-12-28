---
title: うさぎさんでもわかる並列言語Chapel (7) 配列
---
## 7 配列

Chapelの配列には、**矩形配列**と**連想配列**の2種類が存在する。また、類似の概念に、**タプル**と**レンジ**と**領域**が存在する。

### 7.1 タプル

タプルは、複数の要素をカンマ区切りで並べた値である。値型で、要素の型が揃う必要もなく、配列よりも軽量である。
要素の型を揃えた場合は、要素の数と型の乗算により、タプル型を表現できる。また、theseイテレータが利用できる。

```
const nums: 9 * int = (60, 45, 53, 163, 90, 53, 165, 75, 60);
const boys: (string, string, string) = ("Tom", "Ken", "Bob");
writeln(boys(0), boys(1), boys(2), for name in boys do name); // TomKenBobTom Ken Bob
```

タプルは、複数の変数を同時に宣言する場合や、値を同時に書き込む場合に利用できる。この機能を**アンパック**と呼ぶ。

```
var (a, b): (string, int) = ("student", 24);
writeln(a, b);
```

タプルのアンパック機能は、関数の宣言でも利用できる。タプルで宣言された引数には、タプルの値を渡す必要がある。

```
proc foo(x: int, (y, z): (int, int)): int return x * (y + z);
writeln(foo(2, (3, 4))); // 14
```

### 7.2 レンジ

レンジは、整数の有限区間や半無限区間や無限区間を表す値である。値型で、同様の機能を持つ領域よりも軽量である。

```
const from100To200: range(int, boundedType = BoundedRangeType.bounded) = 100..200;
const from100ToInf: range(int, boundedType = BoundedRangeType.boundedLow) = 100..;
const fromInfTo200: range(int, boundedType = BoundedRangeType.boundedHigh) = ..20;
```

byで刻み幅を指定できる。その場合は、alignで指定された値を必ず含む。また、`#`でレンジの要素の個数を指定できる。

```
writeln(10..30 by -7);              // 30 23 16
writeln(10..30 by -7 align 13);     // 27 20 13
writeln(10..30 by -7 align 13 # 2); // 27 20
```

レンジに含まれる要素の個数は.sizeで、区間の下限は.lowで、区間の上限は.highで、刻み幅は.strideで得られる。

```
writeln((100..200).size);      // 101
writeln((100..200).low);       // 100
writeln((100..200).high);      // 200
writeln((100..200).stride);    //   1
writeln((100..200).alignment); // 100
```

レンジでは、theseイテレータが利用できる。for文に限らず、並列化されたforall文やcoforall文でも利用できる。

```
for i in 1..100 do writeln(i);
forall i in 1..100 do writeln(i);
coforall i in 1..100 do writeln(i);
```

### 7.3 領域

領域は、配列の定義域や値の集合を表す。レンジのタプルと等価な**矩形領域**と、要素を格納した**連想領域**の2種類がある。
領域の要素の型は.idxTypeで取得できる。特に、矩形領域は、.rankで階数を、.dimsでレンジのタプルを取得できる。

```
const rectangular: domain = {0..10, -1..2};
const associative: domain = {"foo", "bar"};
writeln(rectangular.rank);
writeln(rectangular.dims());
writeln(rectangular.idxType: string); // int(64)
writeln(associative.idxType: string); // string
```

矩形領域も連想領域も、theseイテレータが利用できる。特に、矩形領域は、多重ループを表す構文としても利用できる。

```
for xyz in {1..10, 1..10, 1..10} do writeln(xyz);
for boy in {"Tom", "Ken", "Bob"} do writeln(boy);
```

### 7.4 配列

配列は、定義域から値域への写像を表す。矩形領域に対応する**矩形配列**と、連想領域に対応する**連想配列**の2種類がある。

```
const rectangular = [1, 2, 3, 4, 5, 6, 7, 8];
const associative = [1 => "one", 2 => "two"];
writeln(rectangular, rectangular.domain); // 1 2 3 4 5 6 7 8{0..7}
writeln(associative, associative.domain); // one two{1, 2}
```

thisメソッドが利用でき、要素の位置を引数に渡せば、その要素を参照できる。領域を渡せば、部分配列も参照できる。

```
var A: [{1..10, 1..10}] real;
var B: [{'foo', 'bar'}] real;
A[1, 2] = 1.2;
A(3, 4) = 3.4;
writeln(A(1..2, 1..3));
```

theseイテレータも利用できる。左辺値を返すので、for文でループ変数に値を書き込むと、その値が配列に反映される。

```
var boys = ['Tom', 'Ken', 'Bob'];
for boy in boys do boy += '-san';
writeln(boys); // Tom-san Ken-san Bob-san
```

祖な矩形領域を定義域に指定すると、粗な配列を宣言できる。これは、粗行列の実装として活用できる。以下に例を示す。

```
var D: sparse subdomain({1..16, 1..64});
var A: [D] real;
D += (8, 10);
D += (3, 64);
A[8, 10] = 114.514;
```

配列は値型であり、配列を他の配列に代入すると、値が複製される。ただし、関数に配列を渡す場合は、参照渡しになる。

```
proc update(arr: [] int) {
	arr = [2, 3, 4];
}
var A = [1, 2, 3];
var B = A;
update(A);
writeln(A); // 2 3 4
writeln(B); // 1 2 3
```
