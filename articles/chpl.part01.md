---
title: うさぎさんでもわかる並列言語Chapel (1) はじめに
---
## 1 はじめに

[Chapel](https://chapel-lang.org)は、**型推論**と**テンプレート**と**区分化大域アドレス空間**を特徴とし、高度に抽象化された**高生産性並列言語**である。
NUMAや分散メモリ環境を得意とし、通常の共有メモリ環境と同様の記述性ながら、高度な並列分散処理を実装できる。

```bash
$ VERSION=1.28.0
$ wget https://github.com/chapel-lang/chapel/releases/download/$VERSION/chapel-$VERSION.tar.gz
$ tar xzf chapel-$VERSION.tar.gz && cd chapel-$VERSION && ./configure && sudo make install
```

以下のhello.chplを作成する。main関数は省略できる。コメントの記法は、C言語(C99)と同様だが、ネストできる。

```
/*
multiline comments
 or block comments
*/
writeln("Hello, world!"); // 1-line comments
```

chplでビルドして、helloを生成する。--fastを指定すると、最適化が有効になり、実行時の検査機能が無効化される。
他にも、--savecを指定すると、C言語に変換できる。helloには、--helpを始め、便利な機能が自動的に付加される。

```bash
$ chpl --fast -o hello --savec savec hello.chpl
$ ./hello
Hello, world!
$ ./hello --help
```

Chapelでは、module宣言で**名前空間**を定義する。関数の外に記述された処理は、名前空間の初期化と同時に実行される。
最も外側の処理は、拡張子.chplを除外した名前の、名前空間を構成する。これが、main関数を省略できた理由である。

```
module Foo {
	writeln("initilize Foo");
	proc main() {
		writeln("This is Foo");
	}
}
module Bar {
	writeln("initilize Bar");
	proc main() {
		writeln("This is Bar");
	}
}
import baz.Foo;
import baz.Bar;
proc main() {
	Foo.main();
	Bar.main();
}
```

複数の名前空間を定義した場合は、どの名前空間に実装されたmain関数を起動するか、ビルド時に指定する必要がある。

```bash
$ chpl --main-module baz baz.chpl
$ ./baz
initilize Foo
initilize Bar
This is Foo
This is Bar
```
