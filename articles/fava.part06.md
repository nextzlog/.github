---
title: Scalaで自作するプログラミング言語処理系 (6) 命令セットを作る
---
## 6 命令セットを作る

第6章では、第2.4節で実装した計算機を拡張し、**分岐命令**を備えた**命令セット**を設計して、条件分岐や関数を実現する。
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

同じ引数を何度も参照する場合は、値を再利用すると効率的である。これを**必要呼び**と呼ぶ。詳細は第6.6節に述べる。

```
fava$ compile(((x)=>x)(5))
Def(11,1) Load(0,0) Nil Skin(6) Ref Call(0) Load(0,0) Fix Set Get Ret Def(3,0) Push(5) Ret Arg Call(1)
```

### 6.1 命令の基本設計

命令は、Code型を継承する。FaVM型は、実行環境の本体である。命令は、所定の操作を実行し、変数pcを繰り上げる。

```scala
class Code(op: FaVM => Unit) {
	def apply(vm: FaVM) = (op(vm), vm.pc += 1)
}
```

変数pcは、**プログラムカウンタ**に相当する。これは、命令を実行する度に繰り上がり、次に実行する命令の位置を示す。

### 6.2 関数の基本設計

次に、関数の仕組みを実装する。関数は、関数の冒頭の位置と、引数の個数と、関数を生成した時点の環境を参照する。
関数が参照する環境は、この関数を包み込む関数の引数を格納した環境である。関数閉包を実現するための布石である。

```scala
case class Closure(from: Int, narg: Int, out: Env)
```

遅延評価の仕組みも実装する。遅延評価は、関数の引数を包む関数と、その計算結果を格納する記憶領域で構成される。
引数が計算済みの場合は、その値を使用し、何度も計算を繰り返す無駄を省く。計算を行う前の状態を**プロミス**と呼ぶ。

```scala
case class Promise(thunk: Closure, var cache: Any = null, var empty: Boolean = true)
```

最後に環境を実装する。環境は、関数適用の際に構築され、関数の引数を記憶する。遅延評価ではプロミスを管理する。
関数閉包の機能を実現するため、環境は連鎖構造を持つ。環境は、関数の包含関係と連動し、**静的スコープ**を構成する。

```scala
case class Env(local: Seq[Any], out: Env = null) {
	def apply(depth: Int, index: Int): Any = depth match {
		case 0 => this.local(index)
		case d => out(d - 1, index)
	}
}
```

関数の引数は、Load命令で取得する。現在の環境を起点に、環境の連鎖構造を辿り、指定された番号の引数を取り出す。

```scala
case class Load(nest: Int, id: Int) extends Code(vm => vm.data.push(vm.call.env(nest, id)))
```

以上で、関数や遅延評価の仕組みを整備した。実際に関数や遅延評価を実現する命令は、第6.5節や第6.6節で設計する。

### 6.3 実行環境の設計

以下のFaVM型が実行環境である。Fig. 6.1と同様に、2個のスタックを備え、引数で渡された命令列を順番に実行する。

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

### 6.4 演算命令の設計

第6.4節では、第2.4節で解説した逆ポーランド記法を参考に、四則演算や論理演算を含む各種の演算命令を充実させる。
まず、Push命令を実装する。引数に指定された**即値**をスタックに積む命令である。特に、定数に相当する命令と言える。

```scala
case class Push(v: Any) extends Code(vm => vm.data.push(v))
```

次に、複数の引数をスタックから取り出して、計算結果をスタックに戻す演算命令は、以下に示すArity型を継承する。
ただし、引数の型を指定する必要がある場合は、Typed型を継承する。引数のopは、この命令に対応する演算子である。

```scala
class Arity(n: Int, f: Function[Seq[Any], Any]) extends Code(vm => vm.data.push(f(vm.data.popN(n))))
class Typed(val n: Int, val op: String, val t: Type, f: Function[Seq[Any], Any]) extends Arity(n, f)
```

Typed型を継承した命令は、以下のOp型で管理する。これは、演算子と命令を紐付け、検索を容易にする仕組みである。

```scala
class Op(op: Typed*)(val table: Map[(String, Type), Typed] = op.map(op => (op.op, op.t) -> op).toMap)
```

例えば、加減算や乗除算の命令をOp型にまとめ、管理する。演算子を指定すれば、対応する命令がtableから得られる。
なお、第7章で実装するコンパイラは、この機能を利用して、加減算や乗除算の構文木を、対応する演算命令に変換する。

```scala
object AddOp extends Op(IAdd, DAdd, SAdd, ISub, DSub, SSub)()
object MulOp extends Op(IMul, DMul, IDiv, DDiv, IMod, DMod)()
object RelOp extends Op(IGt, DGt, ILt, DLt, IGe, DGe, ILe, DLe)()
object EqlOp extends Op(IEq, DEq, SEq, BEq, INe, DNe, SNe, BNe)()
object LogOp extends Op(IAnd, BAnd, IOr, BOr)()
```

さて、演算命令には、単項演算と2項演算がある。単項演算は被演算子が1個の命令で、符号の反転や論理の否定を行う。
以下に、数値の符号を反転させるNeg命令の例を示す。Typed型を継承し、被演算子の型に応じて、何通りか実装する。

```scala
case object INeg extends Typed(1, "-", It, -_.head.asInstanceOf[I])
case object DNeg extends Typed(1, "-", Dt, -_.head.asInstanceOf[D])
```

なお、第6.4節では、基本型に1文字ずつの別名を設定した。例えば、整数型はIで、これは演算命令の接頭辞でもある。

```scala
import java.lang.{String => S}, scala.{Any => A, Int => I, Double => D, Boolean => B}
```

さて、2項演算は、被演算子が2個の命令で、殆どの演算命令が該当する。以下に、加算を表すAdd命令の実装例を示す。

```scala
case object IAdd extends Typed(2, "+", It, v => v.head.asInstanceOf[I] + v.last.asInstanceOf[I])
case object DAdd extends Typed(2, "+", Dt, v => v.head.asInstanceOf[D] + v.last.asInstanceOf[D])
case object SAdd extends Typed(2, "+", St, v => v.head.asInstanceOf[S] + v.last.asInstanceOf[S])
```

以下に、除算を表すDiv命令の例を示す。なお、減算や除算を実装する際は、被演算子を取り出す順番に注意を要する。

```scala
case object IDiv extends Typed(2, "/", It, v => v.head.asInstanceOf[I] / v.last.asInstanceOf[I])
case object DDiv extends Typed(2, "/", Dt, v => v.head.asInstanceOf[D] / v.last.asInstanceOf[D])
```

次に、関係演算命令を実装する。同値関係を調べる関係演算命令2種類と、順序関係を調べる関係演算命令4種類がある。

```scala
case object IGt extends Typed(2, ">", It, v => v.head.asInstanceOf[I] > v.last.asInstanceOf[I])
case object DGt extends Typed(2, ">", Dt, v => v.head.asInstanceOf[D] > v.last.asInstanceOf[D])
```

最後に、2種類の論理演算命令を実装する。論理積と論理和である。整数値の場合は2進数の論理積と論理和を計算する。
以上で、全ての算術演算と関係演算と論理演算の命令が揃った。殆どの命令は、誌面の都合で省略したが、適切に補おう。

```scala
case object IAnd extends Typed(2, "&", It, v => v.head.asInstanceOf[I] & v.last.asInstanceOf[I])
case object BAnd extends Typed(2, "&", Bt, v => v.head.asInstanceOf[B] & v.last.asInstanceOf[B])
```

### 6.5 分岐命令の設計

分岐命令はJump型を継承する。引数に渡された関数が整数を返す場合は、命令を読み取る位置を整数の位置に変更する。

```scala
class Jump(op: FaVM => Option[Int]) extends Code(vm => op(vm).foreach(to => vm.pc = to - 1))
```

Skip命令は、無条件分岐の命令で、指定された個数の命令を読み飛ばす。特に、条件分岐からの脱出で使う命令である。
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
	require(args.length == func.narg)
	vm.call.push(Env(args, func.out))
	vm.data.push(vm.pc + 1)
	func.from
})
```

関数を正格評価する場合は、第6.2節に実装したLoad命令と、第6.4節の演算命令と、第6.5節の分岐命令で事足りる。

### 6.6 遅延評価の設計

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
Set命令は、引数に値を設定する。Fix命令を実行すると、引数の値が確定する。以上の命令で、非正格評価を実現する。

```scala
case object Set extends Code(vm => vm.data.popAs[Promise].cache = vm.data.pop)
case object Fix extends Code(vm => vm.data.topAs[Promise].empty = false)
```
