### Scalaで自作するプログラミング言語処理系

{{site.briefs.fava}}

- [記事](fava) ([PDF](fava.pdf))
- [実装](https://github.com/nextzlog/fava)

```scala
((f)=>((x)=>f(x(x)))((x)=>f(x(x))))((f)=>(n)=>(n==0)?1:n*f(n-1))(10)
```
