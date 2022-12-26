### うさぎさんでもわかる並列言語 Chapel

クレイ社が贈る最高に洗練された並列プログラミング言語を網羅的に解説する日本語初の資料です。

- [記事](chpl) ([PDF](chpl.pdf))

```Chapel
class Duck {
	proc quack() return "quack!";
}
class Kamo {
	proc quack() return "quack!";
}
proc voice(x) return x.quack();
writeln(voice(new Duck())); // quack!
writeln(voice(new Kamo())); // quack!
```
