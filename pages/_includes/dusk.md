### D言語で実装する並列スケジューラ入門

{{site.briefs.dusk}}

- [記事](dusk) ([PDF](dusk.pdf))
- [実装](https://github.com/nextzlog/dusk)

```dlang
int dmm_dawn(int i1, int i2, int j1, int j2, int k1, int k2, int grain) {
	auto axes = [i2 - i1, j2 - j1, k2 - k1];
	if(axes.maxElement <= grain) {
		dmm_leaf(i1, i2, j1, j2, k1, k2);
	} else if(axes.maxIndex == 0) {
		auto t1 = sched.fork!dmm_dawn(i1, (i1+i2)/2, j1, j2, k1, k2, grain);
		auto t2 = sched.fork!dmm_dawn((i1+i2)/2, i2, j1, j2, k1, k2, grain);
		sched.join(t1);
		sched.join(t2);
	} else if(axes.maxIndex == 1) {
		auto t1 = sched.fork!dmm_dawn(i1, i2, j1, (j1+j2)/2, k1, k2, grain);
		auto t2 = sched.fork!dmm_dawn(i1, i2, (j1+j2)/2, j2, k1, k2, grain);
		sched.join(t1);
		sched.join(t2);
	} else if(axes.maxIndex == 2) {
		auto t1 = sched.fork!dmm_dawn(i1, i2, j1, j2, k1, (k1+k2)/2, grain);
		auto t2 = sched.fork!dmm_dawn(i1, i2, j1, j2, (k1+k2)/2, k2, grain);
		sched.join(t1);
		sched.join(t2);
	}
	return 0;
}
```
