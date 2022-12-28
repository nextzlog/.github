---
pdf: fava.pdf
title: Scalaで自作するプログラミング言語処理系
subtitle: Computation Models & Compilers on Scala
---
* TOC
{:toc}
## 1 言語処理系を作る

本書では、**ラムダ計算**を理論的背景に持つ独自のプログラミング言語の**インタプリタ**を自作して、**計算論**の基礎を学ぶ。
自作する言語の名前はfavaとする。最低限の機能に限定した簡素な言語だが、改良次第では高機能な言語に拡張できる。

### 1.1 サンプル

理念的には**純粋関数型言語**に分類できる。状態の概念がなく、式の値は定数だが、理論的には任意の計算を実行できる。
関数は関数の引数や返り値にできる。ただし、関数の名前も局所変数も定義できず、参照可能な変数は引数に限られる。

```
fava$ ((x)=>(y)=>3*x+7*y)(2)(3)
27
```

実用的な計算が困難な程の制約に思えるが、実際には第3章で述べる通り、任意の計算を実行できる。階乗も計算できる。

```
fava$ ((f)=>((x)=>f(x(x)))((x)=>f(x(x))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
3628800
```

自然数を関数で定義する例を示す。この例題は、関数型言語が任意の計算を実行できる性質を示す際に、よく登場する。

```
fava$ ((f,x)=>f(f(f(f(f(x))))))((x)=>x+1,0) // 0 + 1 + 1 + 1 + 1 + 1
5
```

任意の順序組も定義できる。端的に言えば構造体に相当し、複雑なグラフ構造も関数で表現できる性質を示す例である。

```
fava$ ((pair)=>pair((car,cdr)=>car))(((car,cdr)=>(z)=>z(car,cdr))(12,34))
12
fava$ ((pair)=>pair((car,cdr)=>cdr))(((car,cdr)=>(z)=>z(car,cdr))(12,34))
34
```

### 1.2 開発環境

favaの実装は公開済みで、以下の操作でビルドできる。実行環境としてJavaが、開発環境としてGradleが必要である。

```
$ git clone https://github.com/nextzlog/fava
$ gradle build -p fava
```

以下の操作で起動する。fava以外にも、第2章で実装する様々な計算モデルを実験する機能も含まれ、起動時に選べる。
favaは対話的に実行できる。favaの内部で実行される命令列を表示する機能も用意した。内部的な動作の理解に役立つ。

```
$ java -jar fava/build/libs/fava.jar
which language do you use?
[0]: fava
[1]: lisp
[2]: math
select: 0
fava$ "HELLO, WORLD!"
HELLO, WORLD!
fava$ compile(1 + 2)
Push(1) Push(2) Add
```

## 2 計算モデルを作る

**言語処理系**とは、言語仕様に沿って書かれた計算手順を読み取り、任意の計算機を構築または模倣する**万能機械**である。
計算機を抽象化した数学的な模型を**計算モデル**と呼ぶ。例えば、論理回路は第2.1節に述べる**有限状態機械**で表現できる。

### 2.1 有限状態機械

有限状態機械は、**状態**と**遷移規則**の有限集合で構成される。論理回路で言えば、**記憶素子**が保持する情報が状態である。
有限状態機械に信号 $x_n$ を与えると、Table 2.1の遷移規則に従って、状態 $q_n$ から状態 $q_{n+1}$ に遷移して、信号 $y_n$ を返す。

Table 2.1 state transition tables.

(1) SR flip-flop.

|$x_n$  |  $q_n$  |  $q_{n+1}$  |  $y_n$  |
|---|---|---|---|
|00 | 0 | 0 | 0 |
|00 | 1 | 1 | 1 |
|01 | 0 | 0 | 0 |
|01 | 1 | 0 | 1 |
|10 | 0 | 1 | 0 |
|10 | 1 | 1 | 1 |
|11 | 0 | - | - |
|11 | 1 | - | -|


(2) JK flip-flop.

|$x_n$  |  $q_n$  |  $q_{n+1}$  |  $y_n$  |
|---|---|---|---|
|00 | 0 | 0 | 0 |
|00 | 1 | 1 | 1 |
|01 | 0 | 0 | 0 |
|01 | 1 | 0 | 1 |
|10 | 0 | 1 | 0 |
|10 | 1 | 1 | 1 |
|11 | 0 | 1 | 0 |
|11 | 1 | 0 | 1|


(3) 2bit counter.

|$x_n$  |  $q_n$  |  $q_{n+1}$  |  $y_n$  |
|---|---|---|---|
|0 | 00 | 00 | 00 |
|1 | 00 | 01 | 00 |
|0 | 01 | 01 | 01 |
|1 | 01 | 10 | 01 |
|0 | 10 | 10 | 10 |
|1 | 10 | 11 | 10 |
|0 | 11 | 11 | 11 |
|1 | 11 | 00 | 11|

有限状態機械が受け取る信号列を**文**と見做す場合もある。これを言語処理に応用する体系が、第4章の**言語理論**である。
有限状態機械には、それに対応する**正規表現**が必ず存在する。この性質を利用して、正規表現の処理系を実装してみる。

```scala
class R[S](val test: Seq[S] => Option[Seq[S]])
```

正規表現は、正規表現を結合して、帰納的に定義できる。その最小単位が以下に示すOne型で、特定の1文字に適合する。

```scala
case class One[S](r: S) extends R[S](Some(_).filter(_.head == r).map(_.tail))
```

適合すると、残りの文字列を返す。ここに別の正規表現を適用すれば、正規表現の連結を意味する。これがCat型である。
Alt型は、正規表現の選択肢を表す。これは、遷移先の状態が複数ある状況を表す。これを遷移規則の**非決定性**と呼ぶ。

```scala
case class Cat[S](l: R[S], r: R[S]) extends R[S](seq => l.test(seq).map(r.test).flatten)
case class Alt[S](l: R[S], r: R[S]) extends R[S](seq => l.test(seq).orElse(r.test(seq)))
```

Opt型は、指定された正規表現の省略可能な出現を表す。また、Rep型は、指定された正規表現の0回以上の反復を表す。

```scala
case class Opt[S](r: R[S]) extends R[S](seq => r.test(seq).orElse(Some(seq)))
case class Rep[S](r: R[S]) extends R[S](seq => Cat(r, Opt(Rep(r))).test(seq))
```

正規表現Z(L+\|G)Oに相当する、有限状態機械の実装例を示す。第2.1節の内容を応用すれば、言語処理系も実装できる。

```scala
val ZLO = Cat(One('Z'), Cat(Alt(Rep(One('L')), One('G')), One('O')))
println(if(ZLO.test("ZLLLLLLLLLLLLLLLLO").isDefined) "OK" else "NO")
```

### 2.2 セルオートマトン

単体の有限状態機械は、再帰計算が苦手である。しかし、その集合体である**セルオートマトン**は、任意の計算ができる。
構成単位を**セル**と呼ぶ。各セルは、近傍 $k$ 個のセルの状態を参照し、式 2.1に示す遷移規則 $\delta$ に従って、状態遷移する。

$$\delta: Q^k \to Q. \qquad(2.1)$$

空間的な自由を得た恩恵で、再帰構造を持つ計算に対応する。例えば、**フラクタル図形**を描画する遷移規則が存在する。
さて、2次元のセルオートマトンの実装例を、以下に示す。引数は、遷移規則と、縦横に並んだセルの最初の状態である。

```scala
class Grid[S](rule: Rule[S], data: Array[Array[S]]) {
	def update = {
		val next = rule(data.map(_.toSeq).toSeq)
		next.zip(data).foreach(_.copyToArray(_))
	}
}
```

全てのセルが同時に状態遷移する**同期型セルオートマトン**を以下に実装する。引数は、遷移規則と、近傍の距離である。

```scala
class Rule[S](rule: Seq[Seq[S]] => S, d: Int = 1) {
	def ROI[V](i: Int)(s: Seq[V]) = Range.inclusive(i - d, i + d).map(Math.floorMod(_, s.size)).map(s)
	def apply(s: Seq[Seq[S]]) = s.indices.map(x => s(x).indices.map(y => rule(ROI(x)(s).map(ROI(y)))))
}
```

理論的には、任意の遷移規則を初期状態で受け取り、模倣する万能機械も構築できる。その例が**ワイヤワールド**である。
黒の基板に黄色の配線を作ると、信号が配線を巡り、記憶素子を含む、様々な論理回路を模倣する。Fig. 2.1に例を示す。

![images/wire.count.svg](images/wire.count.svg)

Fig. 2.1 Wireworld logic circuits.

Fig. 2.1は**カウンタ**である。左側の**発振回路**から周期的に信号を送る度に、右側の4本の配線を流れる信号が切り替わる。

```scala
object WireWorldRule extends Rule[Char](ROI => (ROI(1)(1), ROI.flatten.count(_ == 'H')) match {
	case ('W', 1) => 'H'
	case ('W', 2) => 'H'
	case ('W', _) => 'W'
	case ('H', _) => 'T'
	case ('T', _) => 'W'
	case ('B', _) => 'B'
})
```

### 2.3 チューリング機械

**チューリング機械**は、無限長の**テープ**と、その内容を読み書きする有限状態機械と、式 2.2の遷移関数 $\delta$ で構成される。
状態 $q_n$ で記号 $x_n$ を読み取ると、記号 $y_n$ に書き換える。状態 $q_{n+1}$ に遷移して $\lambda_n$ の方向に移動し、再び記号を読み取る。

$$(q_{n+1},y_n,\lambda_n) = \delta(q_n,x_n),
\enspace\mathrm{where}\enspace
\enspace\mathrm{where}\enspace
\left\{
\begin{aligned}
q_n &\in Q,\\
x_n,y_n &\in \Sigma,\\
\lambda_n &\in \{L,R\}.
\end{aligned}
\right. \qquad(2.2)$$

この動作は、任意の逐次処理型の計算機と等価であり、並列処理型のセルオートマトンと並んで、計算機の頂点に立つ。
特に、**帰納的に枚挙可能**な集合の計算が得意である。2進数で与えられた自然数の後続を求める手順を、Fig. 2.2に示す。

![images/tape.plus1.svg](images/tape.plus1.svg)

(1) 100=011+001.

![images/tape.plus2.svg](images/tape.plus2.svg)

(2) 110=101+001.

![images/tape.plus3.svg](images/tape.plus3.svg)

(3) 111=110+001.

Fig. 2.2 numerical increment operation on a Turing machine ( $k=1$ ).

任意の遷移関数を読み取り、その遷移関数を忠実に実行する、言語処理系と等価な**万能チューリング機械**も実装できる。
遷移関数と計算手順で、異なるテープを使用した例をUTM型に実装する。状態0から1にかけて、遷移規則を検索する。

```scala
class UTM[V](data1: Seq[V], data2: Seq[V], b1: V, b2: V, mL: V, mR: V, var s1: V, var s2: Int = 0) {
	val tape1 = data1.zipWithIndex.map(_.swap).to(collection.mutable.SortedMap)
	val tape2 = data2.zipWithIndex.map(_.swap).to(collection.mutable.SortedMap)
	var hd1, hd2 = 0
	def r1 = tape1.getOrElse(hd1, b1) 
	def r2 = tape2.getOrElse(hd2, b2)
	def apply(sop: V) = Iterator.continually(s2 match {
		case 0 if r2 == s1 => (s1 = s1, s2 = 1, tape1(hd1) = r1, hd1 += 0, hd2 += 1) 
		case 0 if r2 != s1 => (s1 = s1, s2 = 0, tape1(hd1) = r1, hd1 += 0, hd2 += 5) 
		case 1 if r2 == r1 => (s1 = s1, s2 = 2, tape1(hd1) = r1, hd1 += 0, hd2 += 1) 
		case 1 if r2 != r1 => (s1 = s1, s2 = 0, tape1(hd1) = r1, hd1 += 0, hd2 += 4) 
		case 2 if r2 != b2 => (s1 = r2, s2 = 3, tape1(hd1) = r1, hd1 += 0, hd2 += 1) 
		case 3 if r2 != b2 => (s1 = s1, s2 = 4, tape1(hd1) = r2, hd1 += 0, hd2 += 1) 
		case 4 if r2 == b1 => (s1 = s1, s2 = 5, tape1(hd1) = r1, hd1 += 0, hd2 += 1) 
		case 4 if r2 == mL => (s1 = s1, s2 = 5, tape1(hd1) = r1, hd1 -= 1, hd2 += 1) 
		case 4 if r2 == mR => (s1 = s1, s2 = 5, tape1(hd1) = r1, hd1 += 1, hd2 += 1) 
		case 5 if r2 == b2 => (s1 = s1, s2 = 0, tape1(hd1) = r1, hd1 += 0, hd2 += 1) 
		case 5 if r2 != b2 => (s1 = s1, s2 = 5, tape1(hd1) = r1, hd1 += 0, hd2 -= 1) 
	}).takeWhile(t => s1 != sop || s2 != 0).map(t => tape1.values.mkString)
}
```

状態2から4にかけて、状態遷移と書き戻しと移動を行う。状態5でテープの左端に戻り、状態0に戻る。使用例を示す。
遷移規則は式 2.2の通り、5個組で読み込ませる。初期状態Iから状態Fまで動かすと、Fig. 2.2の計算が実行される。

```scala
case class CUTM(data1: String, data2: String) extends UTM(data1, data2, ' ', '*', 'L', 'R', 'I')
CUTM("0111111", "I0a0RI1a1Ra0a0Ra1a1Ra b Lb0c1Lb1b0Lb F1 c0c0Lc1c1Lc F R")('F').foreach(println)
```

### 2.4 逆ポーランド記法

**スタック**を備え、再帰計算に対応した有限状態機械を**プッシュダウンオートマトン**と呼ぶ。式 2.3の遷移関数 $\delta$ に従う。
 $Q$ は状態の、 $\Sigma$ と $\Gamma$ は入力とスタックの記号の有限集合である。 $\Gamma^*$ は $\Gamma$ の元を並べた任意長の記号列 $y^*$ の集合である。

$$(q_{n+1},y^*_n) = \delta(q_n,\sigma_n,x_n),
\enspace\mathrm{where}\enspace
\left\{
\begin{aligned}
q_n &\in Q,\\
x_n &\in \Gamma,\\
y^*_n &\in \Gamma^*,\\
\sigma_n &\in \Sigma.
\end{aligned}
\right. \qquad(2.3)$$

記号 $\sigma_n$ を受け取ると、スタックの先頭の記号 $x_n$ を取り除き、先頭に記号列 $y^*_n$ を順番に積んで、状態 $q_{n+1}$ に遷移する。
再帰計算を活用した例として、第2.1節で実装した正規表現の拡張を考える。以下の関数ZLOは、記号列 $\texttt{Z}^n\texttt{L}\texttt{O}^n$ を表す。

```scala
def ZLO: R[Char] = Cat(One('Z'), Cat(Alt(One('L'), new R(ZLO.test(_))), One('O')))
println(ZLO.test("ZZZZZZZZZZZZZZZZZZZZZZZZZLOOOOOOOOOOOOOOOOOOOOOOOOO").isDefined)
```

残念ながら、再帰計算は実行できても、受け取った記号列を読み返す機能がなく、計算能力はチューリング機械に劣る。
ただし、記憶装置としてスタックを使う広義の**スタック機械**は、重要な計算モデルである。式 2.4の計算を例に考える。

$$(1 + 2) * (10 - 20). \qquad(2.4)$$

演算子には優先順位があるため、式を左から読むだけでは、計算は困難である。数値を保持する記憶装置も必要である。
前者は、式 2.5の**逆ポーランド記法**で解決する。演算子に優先順位はなく、出現する順番に、直前の数値に適用される。

$$\texttt{1 2 + 10 20 - *}. \qquad(2.5)$$

手順をFig. 2.3に示す。逆ポーランド記法は、式の読み返しを伴う再帰計算や条件分岐を除き、任意の計算を実行できる。
その再帰計算や条件分岐も、指定された長さだけ記号列を遡る**分岐命令**があれば実現できる。詳細は第6章に解説する。

![images/pola.anime.svg](images/pola.anime.svg)

Fig. 2.3 1 2 + 10 20 - *.

逆ポーランド記法とスタック機械による四則演算の実装例を以下に示す。数式は、整数と演算子を空白で区切って渡す。

```scala
object ArithStackMachine extends collection.mutable.Stack[Int]() {
	def apply(program: String): Int = program.split(" +").map {
		case "+" => push(((a: Int, b: Int) => b + a)(pop, pop))
		case "-" => push(((a: Int, b: Int) => b - a)(pop, pop))
		case "*" => push(((a: Int, b: Int) => b * a)(pop, pop))
		case "/" => push(((a: Int, b: Int) => b / a)(pop, pop))
		case num => this.push(num.toInt)
	}.lastOption.map(_ => pop).last
}
```

Fig. 2.3の手順で計算を行う。整数を読み取るとスタックに積み、演算子を読み取ると演算を行う。以下に使用例を示す。

```scala
println(ArithStackMachine("1 2 + 10 20 - *")) // -30
println(ArithStackMachine("3 4 * 10 20 * +")) // 212
```

この実装は、第4章で再び使用する。第4章では、中置記法の数式を逆ポーランド記法に変換するコンパイラを実装する。

## 3 ラムダ計算の理論

実在する計算機を意識した第2章の計算モデルに対し、関数の**評価**と**適用**による計算手順の抽象化がラムダ計算である。
第3章では、任意の式を**ラムダ式**と呼ぶ。変数も、整数も、関数もラムダ式である。関数は、式 3.1のように定義する。

$$f := \lambda xy.2x+3y+z+1. \qquad(3.1)$$

式 3.1を関数 $f$ の**ラムダ抽象**と呼ぶ。変数 $x$ と $y$ を、 $\lambda$ により**束縛**された変数と呼ぶ。また、変数 $z$ を**自由変数**と呼ぶ。
式 3.1は式 3.2と等価である。関数 $g$ は、変数 $x$ を束縛し、変数 $y$ を引数に取る関数を返す。これを**カリー化**と呼ぶ。

$$g := \lambda x.\lambda y.2x+3y+1. \qquad(3.2)$$

式 3.3は、変数 $x$ と $y$ を具体的な値で束縛する。これを関数適用と呼ぶ。また、式の実体を計算する操作を評価と呼ぶ。
評価の途中で、束縛変数を定数に置換する操作を**ベータ簡約**と呼ぶ。式 3.3の値は、2度の簡約を経由して $27$ と求まる。

$$\lambda x.\lambda y.(3x+7y) \enspace 2 \enspace 3 \mathrm{\enspace\xrightarrow[\beta]{}\enspace} \lambda y.(6+7y) \enspace 3 \mathrm{\enspace\xrightarrow[\beta]{}\enspace} 6+21 = 27. \qquad(3.3)$$

任意の自然数と演算は、自然数を枚挙する関数 $s$ と自然数 $0$ があれば、**ペアノの公理**で定義できる。式 3.4に例を示す。
自然数は、2個の引数を取る関数で表す。変数 $x$ に自然数を渡せば、加算になる。変数 $s$ に自然数を渡せば、乗算になる。

$$n := \lambda sx.(s^{\circ n}x) \enspace \lambda x.(x+1) \enspace 0,
\enspace
\left\{
\begin{aligned}
a + b &:= \lambda ab.\lambda sx.as(bsx),\\
a \times b &:= \lambda ab.\lambda sx.a(bs)x.
\end{aligned}
\right. \qquad(3.4)$$

真偽値は、真と偽の順序組を引数に取り、どちらかを返す関数で表現できる。論理積と論理和の定義例を式 3.5に示す。
真偽値の変数 $y$ を偽で束縛すれば、変数 $x$ との論理積になる。逆に、変数 $x$ を真で束縛すれば、変数 $y$ との論理和になる。

$$\mathrm{t} := \lambda xy.x, \enspace
\mathrm{f} := \lambda xy.y, \enspace
\left\{
\begin{aligned}
a \land b &:= \lambda ab.ab\mathrm{f},\\
a \lor  b &:= \lambda ab.a\mathrm{t}b.
\end{aligned}
\right. \qquad(3.5)$$

関数 $f$ に対し、性質 $f(x)\!=\!x$ を満たす点 $x$ を**不動点**と呼ぶ。また、式 3.6の性質を満たす関数 $p$ を**不動点演算子**と呼ぶ。

$$\forall f, \enspace f(p(f)) \equiv p(f). \qquad(3.6)$$

関数 $p$ を利用すれば、再帰的な関数 $h(x)$ を式 3.7で定義できる。関数 $h$ は、再帰計算の実体を表す関数 $g$ を引数に取る。

$$h := \lambda x.pgx, \enspace\mathrm{where}\enspace g := \lambda fy.E. \qquad(3.7)$$

関数 $h$ が再帰的であるには、関数 $g$ の変数 $f$ が関数 $h$ を参照する必要がある。式 3.8の変形で、この要求は保証される。

$$h
\equiv \lambda x.(pg) x
\equiv \lambda x.(g (pg)) x
\equiv \lambda x.ghx. \qquad(3.8)$$

式 3.8を**無名再帰**と呼ぶ。関数 $p$ が実装できれば、任意の再帰計算を実行できる。最も著名な実装例を式 3.9に示す。

$$\mathbb{Y}{} := \lambda f.(\lambda x.f(xx))(\lambda x.f(xx)). \qquad(3.9)$$

関数 $f$ に対し、式 3.9の関数 $\mathbb{Y}$ が式 3.6を満たす様子は、式 3.10で証明できる。ただし、無限再帰に注意を要する。
関数 $\mathbb{Y}{}f$ を評価すると、同じ関数 $\mathbb{Y}{}f$ が右辺に出現する。無限再帰を防ぐには、関数 $\mathbb{Y}{}f$ の評価を遅延させる必要がある。

$$\mathbb{Y}{}f
\mathrm{\enspace\xrightarrow[\beta]{}\enspace} (\lambda x.f(xx))(\lambda x.f(xx))
\mathrm{\enspace\xrightarrow[\beta]{}\enspace} f((\lambda x.f(xx))(\lambda x.f(xx)))
\equiv f(\mathbb{Y}{}f). \qquad(3.10)$$

または、式 3.11の関数 $\mathbb{Z}$ なら、関数 $\mathbb{Z}{}f$ の評価は停止する。関数 $\mathbb{Z}{}$ は、関数 $\mathbb{Y}$ に**イータ変換**の逆を施した関数である。

$$\mathrm{Z} := \lambda f.(\lambda x.f(\lambda y.xxy))(\lambda x.f(\lambda y.xxy)). \qquad(3.11)$$

関数 $\mathbb{Z}{}f$ を評価すると、変数 $y$ を引数に取る関数が出現する。右辺の関数 $\mathbb{Z}{}f$ の展開が保留され、無限再帰は回避される。

$$\mathrm{Z}f
\mathrm{\enspace\xrightarrow[\beta]{}\enspace} (\lambda x.f(\lambda y.xxy))(\lambda x.f(\lambda y.xxy))
\mathrm{\enspace\xrightarrow[\beta]{}\enspace} f(\lambda y.(\lambda x.f(\lambda y.xxy))(\lambda x.f(\lambda y.xxy))y)
\mathrm{\enspace\xrightarrow[\beta]{}\enspace} f(\lambda y.\mathrm{Z}fy). \qquad(3.12)$$

式 3.9の関数 $\mathbb{Z}$ を利用すれば、本書で自作する言語は、任意の計算を実行できる。第9章で実装を終えた後に実験する。

## 4 簡単なコンパイラ

第2章の計算モデルは、C言語やラムダ計算など**高水準言語**の内容を実行するには原始的すぎる。そこで、翻訳を行う。
翻訳を行う言語処理系を**コンパイラ**と呼ぶ。第4章では、簡単な逆ポーランド記法の翻訳を例に、その概念を解説する。

### 4.1 形式言語の階層性

**形式言語**とは、定義が明確で、何らかの計算手順で処理できる言語である。まず、形式言語 $L$ は式 4.1で定義される。

$$L(G) \subset \Sigma^* = \left\{\langle\sigma_1,...,\sigma_n,...\rangle\mid\sigma_n\in\Sigma\right\}. \qquad(4.1)$$

言語 $L$ は**文**の集合である。文とは、記号 $\sigma$ の列である。記号は有限集合 $\Sigma$ で定義され、集合 $\Sigma$ を**アルファベット**と呼ぶ。
記号 $\sigma$ の出現には、明確な規則がある。この規則を**生成規則**と呼び、生成規則の集合を**文法**と呼ぶ。式 4.2に例を示す。

$$P = \left\{
\begin{aligned}
\mathtt{S} &\to \texttt{(S)},\\
\mathtt{S} &\to \texttt{(f)},
\end{aligned}
\right.:(N\cup\Sigma)^*\to(N\cup\Sigma)^*. \qquad(4.2)$$

生成規則は、左辺の記号列を右辺の記号列に置換する規則である。式 4.2の例では、記号Sから式 4.3が導出される。

$$\texttt{(f)},
\texttt{((f))},
\texttt{(((f)))},
\texttt{((((f))))},
\texttt{(((((f)))))},
\texttt{((((((f))))))},
\texttt{(((((((f)))))))},
\texttt{((((((((f))))))))},
\ldots. \qquad(4.3)$$

生成規則の両辺に出現できる記号 $\nu\!\in\!N$ を**非終端記号**と呼ぶ。また、右辺に限って出現する記号 $\sigma\!\in\!\Sigma$ を**終端記号**と呼ぶ。
任意の文は、**開始記号**と呼ばれる記号 $S$ を起点に生成される。最終的に、言語 $L(G)$ の文法 $G$ は式 4.4で定義される。

$$G=(N,\Sigma,P,S),\enspace\mathrm{where}\enspace S\in N. \qquad(4.4)$$

文法 $G$ に従う文を生成し、または文を開始記号 $S$ に帰する手順が定義され、曖昧性がなければ、文法 $G$ は**形式的**である。
形式言語の中でも、生成規則が自由な言語を**帰納的可算言語**と呼び、式 4.5の制限を加えた言語を**文脈依存言語**と呼ぶ。

$$\alpha A \beta \to \alpha \gamma \beta,
\enspace\mathrm{where}\enspace
\left\{
\begin{aligned}
A &\in N,\\
\alpha,\beta &\in (N\cup\Sigma)^*,\\
\gamma &\in (N\cup\Sigma)^+.
\end{aligned}
\right. \qquad(4.5)$$

形式言語の中でも、式 4.6の制限を持ち、前後の文脈に依存せずに、生成規則が適用できる言語を**文脈自由言語**と呼ぶ。
第2.4節で述べたプッシュダウンオートマトンを利用して、文に対して生成規則を再帰的に適用することで処理できる。

$$A \to \alpha,
\enspace\mathrm{where}\enspace
\left\{
\begin{aligned}
A &\in N,\\
\alpha &\in (N\cup\Sigma)^*.
\end{aligned}
\right. \qquad(4.6)$$

形式言語の中でも、文法の制約が強く、有限状態機械で処理可能な言語を**正規言語**と呼ぶ。その記法が正規表現である。
有限状態機械では、無限の記憶を持てず、特に再帰的な生成規則を扱えず、生成規則は式 4.7に示す形式に制限される。

$$\left\{
\begin{aligned}
A &\to a,\\
A &\to aB,
\end{aligned}
\right.
\enspace\mathrm{where}\enspace
\left\{
\begin{aligned}
a &\in \Sigma,\\
A,B &\in N.
\end{aligned}
\right. \qquad(4.7)$$

形式言語の文は、適用した生成規則の木構造で表現できる。これを**構文木**と呼び、構文木を導く作業を**構文解析**と呼ぶ。
特にLL法では、終端記号の列を読み進め、見つけた終端記号に適う生成規則を、開始記号 $S$ を起点に深さ優先探索する。

$$(S=\texttt{add})\to(\texttt{mul + mul})\to(\texttt{num * num + num})\to(\texttt{1 * 2 + 3}). \qquad(4.8)$$

LR法では、終端記号の列を読み進め、置換可能な部分を非終端記号に置換する。最終的に開始記号 $S$ に到達して終わる。

$$(\texttt{1 * 2 + 3})\to(\texttt{num * num + num})\to(\texttt{mul + mul})\to(S=\texttt{add}). \qquad(4.9)$$

通常、高水準言語は形式言語である。仮に自然言語を採用すると、翻訳する手順が曖昧になり、実装困難なためである。

### 4.2 解析表現文法の例

形式文法は、構文解析の際には曖昧になる。そこで、生成規則ではなく、構文解析の手順を形式的に定義した文法もある。
**解析表現文法**はその例である。解析表現文法は、文脈依存言語の部分集合を扱う。簡単な四則演算を定義する例を示す。

|-|-|-|
|---|---|---|
|加減算 | `add ::= mul (('+' / '-') mul)*` |
|乗除算 | `mul ::= num (('*' / '/') num)*` |
|整数値 | `num ::= [0-9]+ / '(' add ')'`|

左辺が非終端記号で、右辺が非終端記号と終端記号の列を表す。ただし、右辺に出現する記号には、以下の意味がある。

|-|-|
|---|---|
|` *` | 直前の記号が0回以上出現する。|
|` +` | 直前の記号が1回以上出現する。|
|` ?` | 直前の記号が出現する場合がある。|
|` /` | 直前または直後の記号が出現する。|
|`()` | 括弧内の記号列をひと纏めにする。|
|`''` | 引用内の字句がそのまま出現する。|
|`[]` | 範囲内の記号が選択的に出現する。|
|` &` | 直後の記号が出現すれば成功する。|
|` !` | 直後の記号が出現すれば失敗する。|

解析表現文法はLL法の亜種である**再帰下降構文解析**を定義する記法である。これは、再帰的な関数で構文解析器を表す。
様々な言語を定義可能だが、非終端記号を置換すると再び左に出現する**左再帰**の言語では、無限再帰に陥る欠点がある。

|-|-|
|---|---|
|左再帰 | `add ::= add ('+' / '-') mul / mul`|

左再帰は、**左結合**の式を表す際に重要である。式 4.10に例を示す。左結合の式では、式の左側の演算子が優先される。

$$1 - 2 - 3 - 4 - 5 = (((1 - 2) - 3) - 4) - 5 = -13. \qquad(4.10)$$

右結合にすれば無限再帰を回避できるが、式の意味が変化してしまう。反復を表す特殊記号*など、代替手段で回避する。

### 4.3 構文解析器の実装

第4.3節では、第2.1節で解説した正規表現の処理系を改良して、解析表現文法に基づく**パーサコンビネータ**を実装する。
以下のPEG型を継承した**高階関数**を組み合わせ、再帰下降構文解析器を構築する。構文解析に成功すると、結果を返す。

```scala
class PEG[+M](f: String => Option[Out[M]]) {
	def skip = Reg("""\s*""".r) ~> this <~ Reg("""\s*""".r)
	def / [R >: M](q: => PEG[R]): PEG[R] = new Alt(this, q)
	def ~ [R](q: => PEG[R]): PEG[(M, R)] = new Cat(this, q)
	def <~[R](q: => PEG[R]) = this ~ q ^ (_._1)
	def ~>[R](q: => PEG[R]) = this ~ q ^ (_._2)
	def ^ [T](f: M => T) = new Map(this, f)
	def * = new Rep(this)
	def ? = new Opt(this)
	def apply(in: String) = f(in)
}
```

構文解析器は、その構文解析器で構築した構文木と、構文解析器が読み残した終端記号の列を返す。Out型に実装する。

```scala
case class Out[+M](m: M, in: String) {
	def tuple[R](o: Out[R]) = Out(m -> o.m, o.in)
	def apply[R](p: PEG[R]) = p(in).map(tuple(_))
	def toSome = Out(Some(m), in)
}
```

最初に、最も単純な構文解析器を実装する。Str型は、指定された終端記号列を左端に発見すると、その記号列を返す。
Reg型は、正規表現で指定された終端記号列を左端に発見すると、その記号列を返す。両者を総称して**字句解析器**と呼ぶ。

```scala
case class Str(p: String) extends PEG(s => Option.when(s.startsWith(p))(Out(p, s.substring(p.length))))
case class Reg(p: Regex) extends PEG(p.findPrefixMatchOf(_).map(m => Out(m.matched, m.after.toString)))
```

Alt型は、1個目の構文解析器が構文解析に成功すると、その結果を返し、失敗した場合は、2個目の構文解析器を試す。
Cat型は、1個目の構文解析器を試してから、読み残した終端記号列に2個目の構文解析器を試し、結果を結合して返す。

```scala
class Alt[L, R >: L](p: => PEG[L], q: => PEG[R]) extends PEG[R](s => p(s) orElse q(s))
class Cat[+L, +R](p: => PEG[L], q: => PEG[R]) extends PEG(p(_).map(_ apply q).flatten)
```

Map型は、指定された構文解析器を試し、その結果に対して、関数を適用する。構文木に何らかの加工を施す際に使う。
Opt型は、省略可能な構文を表す。指定された構文解析器を試すが、構文解析に失敗した場合でも、成功したと見做す。

```scala
class Map[+S, +T](p: => PEG[S], f: S => T) extends PEG[T](p(_).map(t => Out(f(t.m), t.in)))
class Opt[+T](p: => PEG[T]) extends PEG(s => p(s).map(_.toSome).orElse(Some(Out(None, s))))
```

And型とNot型は、先読みを行う。指定された構文解析器を試すが、読み取り位置を進めず、構文解析の成否のみを返す。
LL法でも先読み可能だが、正規表現で切り出した字句の先読みに限定されるため、解析表現文法よりも表現能力が劣る。

```scala
class And[+T](p: => PEG[T]) extends PEG(s => if(p(s).isDefined) Some(Out(None, s)) else None)
class Not[+T](p: => PEG[T]) extends PEG(s => if(p(s).isDefined) None else Some(Out(None, s)))
```

Rep型は、記号の反復を表す。読み取り位置を進めては構文解析を実行し、構文解析に失敗すると、結果を結合して返す。

```scala
class Rep[+T](p: => PEG[T]) extends PEG(s => {
	def ca(a: Out[T]): Out[Seq[T]] = Out(a.m +: re(a.in).m, re(a.in).in)
	def re(s: String): Out[Seq[T]] = p(s).map(ca).getOrElse(Out(Nil, s))
	Some(re(s))
})
```

次に、特殊な構文解析器を実装する。Fold型は、左結合する中置記法の式を表す。無限再帰を回避する代替手段である。
1個目の構文解析器は、被演算子を表す。2個目の構文解析器は演算子を表し、演算子の左右に並ぶ被演算子を結合する。

```scala
class Fold[T](p: => PEG[T], q: => PEG[(T, T) => T]) extends PEG({
	(p ~ (q ~ p).*)^(x => x._2.foldLeft(x._1)((l, r) => r._1(l, r._2)))
} apply(_))
```

最後に実装するSep型は、Rep型の特殊な場合で、区切り文字で区切られた記号の反復を表す。区切り文字は廃棄される。

```scala
class Sep[T](p: => PEG[T], q: => PEG[_]) extends Fold[Seq[T]](p^(Seq(_)), q^(_ => _ ++ _))
```

最終的な構文解析器を、以下のPEGs型を継承して実装すると、文字列や正規表現は、暗黙的に構文解析器に変換される。

```scala
class PEGs {
	implicit def implicitText(p: String): PEG[String] = new Str(p).skip
	implicit def implicitRegex(p: Regex): PEG[String] = new Reg(p).skip
}
```

使用例を示す。この実装は、数式を読み取る機能に加え、逆ポーランド記法の命令列を生成する**コード生成器**も兼ねる。

```scala
object ArithPEGs extends PEGs {
	def add: PEG[String] = new Fold(mul, ("+" / "-").^(op => (a, b) => s"$a $b $op"))
	def mul: PEG[String] = new Fold(num, ("*" / "/").^(op => (a, b) => s"$a $b $op"))
	def num: PEG[String] = "[0-9]+".r / ("(" ~> add <~ ")")
	def apply(e: String) = +ArithStackMachine(add(e).get.m)
}
```

## 5 自作言語の仕様書

本書で設計するfavaは**動的型付け**を行う言語である。データ型は、整数型と実数型と論理型と文字列型と関数型がある。
整数型は符号付き32 bit整数で、実数型はIEEE 754 (64 bit 2進数)浮動小数点数で、文字列はUTF-16で表現される。

|-|-|
|---|---|
|整数型 | `int  ::= [0-9]+` |
|実数型 | `real ::= [0-9]* ([0-9] '.' / '.' [0-9]) [0-9]*` |
|論理型 | `bool ::= 'true' / 'false'` |
|文字列 | `text ::= '"' [^"]* '"'` |
|関数型 | `func ::= '(' (id (',' id)*)? ')' '=>' expr`|

識別子は、その識別子が記述された箇所を包含し、識別子と同じ名前の引数を持つ、最も内側の関数の引数を参照する。
関数の内外で変数を宣言または代入する機能はなく、従って、識別子が参照する実体は何らかの関数の引数に限られる。

|-|-|
|---|---|
|識別子 | `id ::= [@A-Z_a-z] [@0-9A-Z_a-z]*`|

引数の値は変更不可能なため、識別子を含む式が参照する実体は、状態によらず自明である。これを**参照透明性**と呼ぶ。
複数の文を逐次的に実行する**ブロック構文**はなく、関数宣言の構文も省略した。以下に解析表現文法による定義を示す。

|-|-|
|---|---|
|ラムダ式 | `expr ::= cond / or` |
|条件分岐 | `cond ::= or  '?' expr ':' expr` |
|論理積   | `or   ::= or  '|' and / and` |
|論理和   | `and  ::= and '&' eql / eql` |
|等値比較 | `eql  ::= eql ('==' / '!=') rel / rel` |
|順序比較 | `rel  ::= rel ('<' / '>' / '<=' / '>=') add / add` |
|加減算   | `add  ::= add ('+' / '-') mul / mul`|
|乗除算   | `mul  ::= mul ('*' / '/' / '%') unr / unr` |
|単項演算 | `unr  ::= ('+' / '-' / '!') unr / call` |
|関数適用 | `call ::= call '(' expr (',' expr) ')' / fact` |
|式の要素 | `fact ::= func / bool / text / real / int / id / '(' expr ')'`|

この定義は左再帰を含む。中置記法の論理演算と比較演算と算術演算は、全て左結合である。単項演算は右結合である。
関数は、他の関数を引数や返り値にできる。これを**高階関数**と呼ぶ。ただし、関数は宣言できず、従って**無名関数**である。

```
fava$ ((function)=>function())(()=>1+2)
3
```

高階関数の内部で定義された関数からは、外側の高階関数で定義された引数を参照できる。この関数を**関数閉包**と呼ぶ。
関数の引数は、その引数を参照する関数閉包が存在し、参照される限り、関数適用が完了しても生存し、参照可能である。

```
fava$ ((x)=>((y)=>x*y))(2)(3)
6
```

引数の値は、関数を呼び出す時点では計算されず、値が必要になった時点で計算される。この動作を**非正格評価**と呼ぶ。
**遅延評価**とも呼ばれる。詳細は第3章に述べるが、端的に言えば、再帰的な関数が無限再帰に陥るのを防ぐ効果がある。

```
fava$ ((f)=>((x)=>f(x(x)))((x)=>f(x(x))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
3628800
```

## 6 分岐命令の仕組み

逆ポーランド記法の計算機で条件分岐を行うには、指定された長さだけ命令列を読み進め、または遡る分岐命令を使う。
以下に例を示す。まず、Push命令がスタックに値を積む。その値が偽なら、続くSkin命令が、3個の命令を読み飛ばす。

```
fava$ compile(true? 12: 34)
Push(true) Skin(3) Push(12) Skip(2) Push(34)
```

Skip命令は**無条件分岐命令**で、条件式の値に依らず指定された個数の命令を読み飛ばす。この例の計算結果は12である。
関数も同様の仕組みで実現できる。関数は、Def命令に始まり、Ret命令に終わる命令列に翻訳される。以下に例を示す。

```
fava$ compile((x,y)=>x+y)
Def(5,2) Load(0,0) Load(0,1) Add Ret
```

Def命令は、指定された個数の引数を持つ関数を生成し、スタックに積む。また、関数の内容を読み飛ばす機能も備える。
Ret命令は、関数の引数を格納した**環境**を廃棄して、関数を呼び出した位置に復帰する。関数適用の命令列も以下に示す。

```
fava$ compile(((f)=>f())(()=>3))
Def(4,1) Load(0,0) Call(0) Ret Def(3,0) Push(3) Ret Call(1)
```

Call命令は、引数と関数をスタックから取り出す。復帰位置を記録して、環境を構築してから、関数の冒頭に移動する。
Fig. 6.1に動作を示す。上下に2個のスタックがあるが、上のスタックで計算を行う。下のスタックは、環境を格納する。

![images/fava.call2.svg](images/fava.call2.svg)

Fig. 6.1 function call mechanism for ((f)=>f())(()=>3).

以上は、引数の値を関数適用の前に求める**正格評価**の説明である。非正格評価では、引数の値を計算せずに関数を呼ぶ。
条件分岐を含む関数では、引数の値が使用されず廃棄される場合がある。非正格評価であれば、この無駄を解消できる。

```
fava$ ((x,y,z)=>(x?y:z))(true,3+3,3*3)
6
```

引数を無名関数で包み、引数を参照する際にその関数を呼べば、非正格評価と同じ挙動になる。これを**名前呼び**と呼ぶ。

```
fava$ ((x,y)=>x()*x()+y())(()=>3+3,()=>3*3)
45
```

同じ引数を何度も参照する場合は、値を再利用すると効率的である。これを**必要呼び**と呼ぶ。詳細は第8.3節に述べる。

```
fava$ compile(((x)=>x)(5))
Def(11,1) Load(0,0) Nil Skin(6) Ref Call(0) Load(0,0) Fix Set Get Ret Def(3,0) Push(5) Ret Arg Call(1)
```

## 7 仮想計算機を作る

第7章では、第2.4節で実装した逆ポーランド記法の計算機を拡張し、第6章の分岐命令を備えた**仮想計算機**を実装する。
FaVM型が仮想計算機の本体である。Fig. 6.1と同じ2個のスタックを備え、**プログラムカウンタ**が示す命令を実行する。

```scala
class FaVM(val codes: Seq[Code], var pc: Int = 0) {
	val call = new Stack[Env]
	val data = new Stack[Any]
	while(pc < codes.size) codes(pc)(this)
}
```

Stack型はスタックを実装する。指定された個数の値を取り出す機能や、指定された型で値を取り出す機能を実装する。

```scala
class Stack[E] extends collection.mutable.Stack[E] {
	def popN(n: Int) = Seq.fill(n)(pop).reverse
	def popAs[Type]: Type = pop.asInstanceOf[Type]
	def topAs[Type]: Type = top.asInstanceOf[Type]
	def env = (this :+ null).top.asInstanceOf[Env]
}
```

命令はCode型を継承する。仮想計算機の参照を受け取り、所定の操作を実行する。最後に命令を読み取る位置を進める。

```scala
class Code(op: FaVM => Unit) {
	def apply(vm: FaVM) = (op(vm), vm.pc += 1)
}
```

**演算命令**は、値をスタックから取り出して、計算結果をスタックに積む。**算術演算**と**論理演算**と**関係演算**に分類できる。
演算命令はALU型を継承する。演算命令は**型検査**も行う。部分関数の使用は型検査が目的で、型次第では例外を起こす。

```scala
class ALU(n: Int, s: String, f: PartialFunction[Seq[Any], Any]) extends Code(vm => {
	def err(v: Seq[_]) = v.map(s => s"$s: ${s.getClass}").mkString("(", ", ", ")")
	vm.data.push(f.applyOrElse(vm.data.popN(n), (v: Seq[_]) => sys.error(err(v))))
})
```

分岐命令はJump型を継承する。引数に渡された関数が整数を返す場合は、命令を読み取る位置を整数の位置に変更する。

```scala
class Jump(op: FaVM => Option[Int]) extends Code(vm => op(vm).foreach(to => vm.pc = to - 1))
```

次に、関数の仕組みを実装する。関数は、関数の冒頭の位置と、引数の個数と、関数を生成した時点の環境を参照する。
関数が参照する環境は、この関数を包み込む関数の引数を格納した環境である。関数閉包を実現するための布石である。

```scala
case class Closure(from: Int, narg: Int, out: Env)
```

遅延評価の仕組みも実装する。引数の式を包む関数と、計算結果を格納する。これを**プロミス**と呼ぶ。以下に実装する。

```scala
case class Promise(thunk: Closure, var cache: Any = null, var empty: Boolean = true)
```

最後に環境を実装する。環境は、関数適用の際に構築され、関数の引数を記憶する。遅延評価ではプロミスを管理する。
関数閉包の機能を実現するため、環境は連鎖構造を持つ。環境は、関数の包含関係と連動し、**静的スコープ**を構成する。

```scala
case class Env(args: Seq[Any], out: Env = null) {
	def apply(nest: Int, index: Int): Any = if(nest > 0) out(nest - 1, index) else args(index)
}
```

## 8 命令セットを作る

第8章では、第7章に述べた仮想計算機に演算命令と分岐命令と遅延評価の命令を実装し、専用の**命令セット**を構築する。
まず、最も基本的なPush命令を実装する。引数に指定された**即値**をスタックに積む。定数式はPush命令で実現できる。

```scala
case class Push(v: Any) extends Code(vm => vm.data.push(v))
```

機械語では、命令を**オペコード**と呼び、命令の引数を**オペランド**と呼ぶ。第8.2節の分岐命令にも、類似した引数がある。

### 8.1 演算命令の設計

演算命令には単項演算と2項演算がある。単項演算はスタックから値を1個だけ取り出し、計算結果をスタックに戻す。
数値の符号を反転させるNeg命令の実装例を示す。他にはPos命令と論理演算のNot命令もあるが、誌面では省略する。

```scala
case object Neg extends ALU(1, "-", {
	case Seq(v: I) => - v
	case Seq(v: D) => - v
})
```

演算命令は型検査も担当する。被演算子が部分関数に列挙するどの型とも異なる場合は、ALU型の内部で例外が起こる。
なお、実装の本筋とは無関係だが、型検査の条件分岐の式を綺麗に揃える目的で、基本型に1文字ずつ別名を設定した。

```scala
import java.lang.{String=>S}, scala.{Any=>A, Int=>I, Double=>D, Boolean=>B}
```

2項演算は2個の値を取り出し、計算結果をスタックに戻す。最初に、Add命令を始め5種類の算術演算命令を実装する。
減算や除算を実装する際は、被演算子の順序に注意を要する。演算子の左側の値がlhsに、右側の値がrhsに渡される。

```scala
case object Add extends ALU(2, "+", {
	case Seq(lhs: I, rhs: I) => lhs + rhs
	case Seq(lhs: I, rhs: D) => lhs + rhs
	case Seq(lhs: D, rhs: I) => lhs + rhs
	case Seq(lhs: D, rhs: D) => lhs + rhs
	case Seq(lhs: S, rhs: A) => s"$lhs$rhs"
	case Seq(lhs: A, rhs: S) => s"$lhs$rhs"
})
```

次に、関係演算命令を実装する。同値関係を調べる関係演算命令2種類と、順序関係を調べる関係演算命令4種類がある。

```scala
case object Gt extends ALU(2, ">", {
	case Seq(lhs: I, rhs: I) => lhs > rhs
	case Seq(lhs: I, rhs: D) => lhs > rhs
	case Seq(lhs: D, rhs: I) => lhs > rhs
	case Seq(lhs: D, rhs: D) => lhs > rhs
	case Seq(lhs: S, rhs: S) => lhs > rhs
})
```

最後に、2種類の論理演算命令を実装する。論理積と論理和である。整数値の場合は2進数の論理積と論理和を計算する。

```scala
case object Or extends ALU(2, "|", {
	case Seq(lhs: B, rhs: B) => lhs | rhs
	case Seq(lhs: I, rhs: I) => lhs | rhs
})
```

### 8.2 分岐命令の設計

分岐命令は第6章に準拠する。Skip命令は、条件分岐で真の場合の処理を実行した後で、条件分岐を脱出する際に使う。
Skin命令は、値をスタックから取り出し、偽の場合は指定された個数の命令を読み飛ばす。条件分岐や遅延評価で使う。

```scala
case class Skip(plus: Int) extends Jump(vm => Some(vm.pc + plus))
case class Skin(plus: Int) extends Jump(vm => Option.when(!vm.data.popAs[B])(vm.pc + plus))
```

Def命令は、指定された個数の引数を取る関数を生成する。関数の開始位置と環境を保存し、関数定義の直後に脱出する。

```scala
case class Def(size: Int, narg: Int) extends Jump(vm => Some {
	vm.data.push(Closure(vm.pc + 1, narg, vm.call.env))
	vm.pc + size
})
```

Ret命令は、関数定義の最後に配置される。関数の環境を廃棄して、関数を呼ぶ直前の状態を復元し、以前の位置に戻る。

```scala
case object Ret extends Jump(vm => Some {
	vm.call.remove(0).asInstanceOf[Env]
	vm.data.remove(1).asInstanceOf[Int]
})
```

Call命令は、指定された個数の引数で環境を構築する。関数から復帰する際の位置を控え、関数の開始位置に移動する。

```scala
case class Call(argc: Int) extends Jump(vm => Some {
	val args = vm.data.popN(argc)
	val func = vm.data.popAs[Closure]
	vm.call.push(Env(args, func.out))
	vm.data.push(vm.pc + 1)
	if(args.size == func.narg) func.from
	else sys.error(s"${func.narg} arguments required")
})
```

正格評価の場合は、第8.2節に実装した分岐命令と、第8.3節に実装するLoad命令があれば、任意の計算を実行できる。

### 8.3 遅延評価の設計

最初に、関数の引数を参照するLoad命令を実装する。現在の環境の連鎖構造を辿り、指定された番号の引数を取り出す。

```scala
case class Load(nest: Int, id: Int) extends Code(vm => vm.data.push(vm.call.env(nest, id)))
```

Arg命令は、関数をスタックから取り出し、値が未定の引数とする。この命令は、関数適用の直前に実行する想定である。

```scala
case object Arg extends Code(vm => vm.data.push(Promise(vm.data.popAs[Closure])))
```

Get命令は、引数をスタックから回収して、引数の値をスタックに積む。引数の値は、事前に計算済みである必要がある。
引数の値が計算済みか確認するには、Nil命令を使う。計算が必要な場合は、次に実装するRef命令を利用して計算する。

```scala
case object Get extends Code(vm => vm.data.push(vm.data.popAs[Promise].cache))
case object Nil extends Code(vm => vm.data.push(vm.data.topAs[Promise].empty))
case object Ref extends Code(vm => vm.data.push(vm.data.topAs[Promise].thunk))
```

Ref命令は、引数の実体である関数を取り出す。Ref命令を実行した直後にCall命令を実行すれば、引数の値が求まる。
Set命令は、引数に値を設定する。Ref命令とCall命令で計算した結果を引数に設定すれば、非正格評価を実現できる。

```scala
case object Set extends Code(vm => vm.data.popAs[Promise].cache = vm.data.pop)
case object Fix extends Code(vm => vm.data.topAs[Promise].empty = false)
```

## 9 コンパイラを作る

第9章では、第5章の仕様に従って、式を第8章の命令列に翻訳する仕組みを作る。構文解析には第4.3節の実装を使う。
最初に、第9.1節から第9.2節で、様々な構文木を実装する。構文木は、分割統治法によるコード生成器の役割を兼ねる。

```scala
trait AST {
	def code(implicit env: DefST): Seq[Code]
}
```

引数envは、その構文木が表す式を包む最も内側の関数を表す。関数の引数を探す場合は、関数を外向きに辿って探す。

### 9.1 定数と演算の構文木

算術演算や関係演算や論理演算の式は、逆ポーランド記法の命令列に翻訳される。まず、定数を表す構文木を実装する。

```scala
case class LitST(value: Any) extends AST {
	def code(implicit env: DefST) = Seq(Push(value))
}
```

定数は単にPush命令に翻訳される。なお、文字列の場合は、特別にStrST型で扱う。ここで、特殊な文字の処理を行う。

```scala
case class StrST(string: String) extends AST {
	def code(implicit env: DefST) = LitST(StringContext.processEscapes(string)).code
}
```

次に、演算子の構文木を実装する。単項演算はUnST型で表す。被演算子の命令列を生成し、直後に演算命令を追加する。

```scala
case class UnST(op: String, expr: AST) extends AST {
	def code(implicit env: DefST) = op match {
		case "+" => expr.code :+ Pos
		case "-" => expr.code :+ Neg
		case "!" => expr.code :+ Not
	}
}
```

2項演算はBinST型で表す。まず左側の被演算子の、次に右側の被演算子の命令列を生成し、直後に演算命令を追加する。

```scala
case class BinST(op: String, e1: AST, e2: AST) extends AST {
	def code(implicit env: DefST) = op match {
		case "+"  => e1.code ++ e2.code :+ Add
		case "-"  => e1.code ++ e2.code :+ Sub
		case "*"  => e1.code ++ e2.code :+ Mul
		case "/"  => e1.code ++ e2.code :+ Div
		case "%"  => e1.code ++ e2.code :+ Mod
		case "&"  => e1.code ++ e2.code :+ And
		case "|"  => e1.code ++ e2.code :+ Or
		case ">=" => e1.code ++ e2.code :+ Ge
		case "<=" => e1.code ++ e2.code :+ Le
		case ">"  => e1.code ++ e2.code :+ Gt
		case "<"  => e1.code ++ e2.code :+ Lt
		case "==" => e1.code ++ e2.code :+ Eq
		case "!=" => e1.code ++ e2.code :+ Ne
	}
}
```

### 9.2 分岐と関数の構文木

条件分岐の式はIfST型で表す。条件式と、真の場合に評価する式と、偽の場合に評価する式で、合計3個の引数を取る。
条件分岐は、条件式の命令列の後に、Skin命令と、真の場合の命令列と、Skip命令と、偽の場合の命令列を配置する。

```scala
case class IfST(cond: AST, vals: (AST, AST)) extends AST {
	def code(implicit env: DefST) = {
		val code1 = vals._1.code
		val code2 = vals._2.code
		val jmp1 = Skin(2 + code1.size) +: code1
		val jmp2 = Skip(1 + code2.size) +: code2
		cond.code ++ jmp1 ++ jmp2
	}
}
```

次に、関数を表すDefST型を実装する。引数は、関数の引数と内容である。また、外側の関数を参照する変数を定義する。
関数は、内容の命令列を生成して、命令の個数と引数の個数を指定したDef命令と、Ret命令を冒頭と最後に配置する。

```scala
case class DefST(pars: Seq[String], body: AST) extends AST {
	var out: DefST = null
	def code(implicit env: DefST) = {
		val codes = body.code((this.out = env, this)._2)
		(Def(codes.size + 2, pars.size) +: codes :+ Ret)
	}
}
```

関数は、関数が定義された場所での、関数の包含関係を保持する。関数の包含関係は、変数を参照できる範囲を決定する。
外側の関数は、命令列を生成する際に、引数で渡される。また、最も外側の関数は、便宜的に以下のRoot型を参照する。

```scala
object Root extends DefST(Seq(), null)
```

次に、識別子の構文木を実装する。正格評価の場合はStIdST型を使う。関数の包含構造を外向きに遡り、仮引数を探す。

```scala
case class StIdST(val name: String) extends AST {
	def search(env: DefST, nest: Int = 0): Load = {
		if(env.pars.contains(name)) Load(nest, env.pars.indexOf(name))
		else if(env.out != null) search(env.out, nest + 1)
		else sys.error(s"parameter $name is not declared")
	}
	def code(implicit env: DefST) = Seq(search(env))
}
```

非正格評価の場合はLzIdSt型を使う。引数を取り出し、計算が必要なら計算し、引数の値を取り出す命令列を生成する。

```scala
case class LzIdST(val name: StIdST) extends AST {
	val (head, tail) = Seq(Nil, Skin(6), Ref, Call(0)) -> Seq(Fix, Set, Get)
	def code(implicit env: DefST) = (name.code ++ head ++ name.code ++ tail)
}
```

非正格評価の場合は、関数に渡す実引数を関数に包む必要がある。関数の命令列を生成し、直後にArg命令を配置する。

```scala
case class LzArgST(body: AST) extends AST {
	def code(implicit env: DefST) = DefST(Seq(), body).code :+ Arg
}
```

CallST型は、関数適用を表す。まず、関数を参照する式の、次に引数の命令列を展開し、最後にCall命令を配置する。

```scala
case class CallST(f: AST, args: Seq[AST]) extends AST {
	def code(implicit env: DefST) = f.code ++ args.map(_.code).flatten :+ Call(args.size)
}
```

### 9.3 再帰下降構文解析器

最後に、第4.3節で実装した解析表現文法の構文解析器を組み合わせ、再帰下降構文解析器を構築する。以下に実装する。
第5章に掲載した文法の定義とほぼ同じ構造である。ただし、左結合の演算子はFold型を利用して、左再帰を回避した。

```scala
object FavaPEGs extends PEGs {
	def expr: PEG[AST] = (cond / or) <~ ("//" ~ ".*$".r).?
	def cond = (or <~ "?") ~ (expr ~ (":" ~> expr)) ^ IfST
	def or   = new Fold(and, "|" ^ (op => BinST(op, _, _)))
	def and  = new Fold(eql, "&" ^ (op => BinST(op, _, _)))
	def eql  = new Fold(rel, """(!|=)=""".r ^ (op => BinST(op, _, _)))
	def rel  = new Fold(add, """[<>]=?""".r ^ (op => BinST(op, _, _)))
	def add  = new Fold(mul, """[\+\-]""".r ^ (op => BinST(op, _, _)))
	def mul  = new Fold(unr, """[\*/%]""".r ^ (op => BinST(op, _, _)))
	def unr  = ("+" / "-" / "!").* ~ call ^ ((o,e) => o.foldRight(e)(UnST))
	def call = fact ~ args.* ^ ((f,a) => a.foldLeft(f)(CallST))
	def args = "(" ~> new Sep(expr ^ LzArgST, ",") <~")"
	def fact = func / bool / text / real / int / name / ("(" ~> expr <~ ")")
	def func = pars ~ ("=>" ~> expr) ^ ((p,e) => DefST(p, e))
	def pars = "(" ~> new Sep(name, ",") <~ ")" ^ (_.map(_.name.name))
	def bool = ("true" / "false") ^ (_.toBoolean) ^ LitST
	def text = ("\"" ~> """([^"\\]|\\[\\'"bfnrt])*""".r <~ "\"") ^ StrST
	def int  = """\d+""".r ^ (_.toInt) ^ LitST
	def real = """(\d+\.\d*|\d*\.\d+)""".r ^ (_.toDouble) ^ LitST
	def name = """[@A-Z_a-z][@0-9A-Z_a-z]*""".r ^ StIdST ^ LzIdST
}
```

使用例を以下に示す。構文解析を実行し、命令列に翻訳して第7章で実装した仮想計算機に渡すと、計算が実行される。

```scala
println(new FaVM(FavaPEGs.expr("((x,y)=>x+y)(2,3)").get.m.code(Root)).data.pop)
```

この構文解析器に、特殊な命令としてcompileを追加して、命令列を文字列で出力する機能を実装すれば、完成である。

### 9.4 言語処理系を動かす

完成した言語処理系は、第3章に述べたラムダ計算の実験環境として利用できる。まず、式 3.4の自然数の演算を試す。
自然数は帰納的に枚挙可能で、自然数の後続の自然数を求める関数と $0$ で表現できる。加算と乗算も、簡単に実装できる。

```
fava$ ((l,r)=>(f,x)=>l(f)(r(f)(x)))((f)=>(x)=>f(x),(f)=>(x)=>f(f(x)))((x)=>x+1,0) // 1 + 2
3
fava$ ((l,r)=>(f,x)=>l(r(f))(x))((f)=>(x)=>f(f(x)),(f)=>(x)=>f(f(x)))((x)=>x+1,0) // 2 * 2
4
```

次に、式 3.5の真偽値の演算を試す。真偽値は、真と偽の順序組で表現できる。論理積と論理和も、簡単に実装できる。

```
fava$ ((l,r)=>l(r,(x,y)=>y))((x,y)=>x,(x,y)=>y)(true,false) // true & false
false
fava$ ((l,r)=>l((x,y)=>x,r))((x,y)=>x,(x,y)=>y)(true,false) // true | false
true
```

無名関数による再帰計算も可能である。式 3.9に述べた不動点演算子を利用する。 $10$ の階乗を求める例を以下に示す。

```
fava$ ((f)=>((x)=>f(x(x)))((x)=>f(x(x))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
3628800
```

正格評価の言語では、無限再帰に陥る。代替手段として式 3.11の不動点演算子を利用すれば、再帰計算が可能になる。

```
fava$ ((f)=>((x)=>f((y)=>x(x)(y)))((x)=>f((y)=>x(x)(y))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
3628800
```
