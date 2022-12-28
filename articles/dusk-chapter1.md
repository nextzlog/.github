---
title: D言語で実装する並列スケジューラ入門 (1) 並列スケジューラの概念
---
## 1 並列スケジューラの概念

**並列処理**とは、長時間を要する計算の内容を分割して複数のプロセッサに分担させ、処理速度の改善を図る技術を指す。
並列処理には、 ?に示す**データ並列**による方法と、 ?に示す**タスク並列**による方法の2種類がある。



前者はデータの分割に、後者はアルゴリズムの分割に着目するが、両者は背反な概念ではなく、単に着眼点の差である。
なお、プロセッサ内部では、命令の解読と実行と後処理など、**命令レベルの並列性**による逐次処理の高速化も行われる。

### 1.1 データレベルの並列性

処理の対象となるデータを分配して行う並列処理を、**データ並列処理**と呼ぶ。以下は、行列積を並列計算する例である。

```dlang
void dmm_data(shared double[][] A, shared double[][] B, shared double[][] C) {
	import core.atomic, std.numeric, std.parallelism, std.range;
	foreach(i; parallel(iota(A.length))) {
	foreach(j; parallel(iota(B.length))) {
		C[i][j].atomicOp!"+="(A[i][].dotProduct(B[j][]));
	}
	}
}
```

単純な計算に限れば、CPUやGPUの*single instruction multiple data* (SIMD) 命令も、同様の並列処理を実現できる。
使用例を以下に示す。SIMD命令が処理するデータの量には限度があるため、for文の並列処理との併用が基本である。

```dlang
void dmm_simd(shared double[][] A, shared double[][] B, shared double[][] C) {
	import core.simd, std.parallelism, std.range;
	foreach(i; parallel(iota(A.length)))
	foreach(j; parallel(iota(B.length))) {
		double2 u = 0;
		foreach(k; iota(0, A[i].length, 2)) {
			auto a = *cast(double2*) &A[i][k];
			auto b = *cast(double2*) &B[j][k];
			auto w = __simd(XMM.LODUPD, a);
			auto x = __simd(XMM.LODUPD, b);
			w = cast(double2)__simd(XMM.MULPD, w, x);
			u = cast(double2)__simd(XMM.ADDPD, w, u);
		}
		C[i][j] = u[0] + u[1];
	}
}
```

### 1.2 タスクレベルの並列性

関数など処理単位の非同期な実行による並列処理を、**タスク並列処理**と呼ぶ。非同期に実行される処理を**タスク**と呼ぶ。
非同期の実行を制御する仕組みが**スケジューラ**である。その主な役割は、動的な負荷分散である。Fig. 1.1に構成を示す。

![images/dawn.fifo.svg](images/dawn.fifo.svg)

Fig. 1.1 FIFO scheduler on shared-memory architecture.

現代の計算機は、プロセッサと主記憶が対をなす**ノード**の集合体であり、その間に、非対称な**メモリ空間**が共有される。
他のノードのデータを参照すると、**レイテンシ**で律速されるため、タスクが参照するデータは、局所化する必要がある。

### 1.3 粗粒度なタスクの分配

負荷分散だけに着目してタスクを分配すると、同じデータを参照するタスクが各ノードに分散し、参照の局所性を失う。
経験的には、再帰構造を持つタスクの末端を分配すると局所性が失われ、粗粒度な塊を分配すると局所性が保存される。

### 1.4 ワークスティーリング

Fig. 1.2に示す**ワークスティーリング**型のスケジューラでは、プロセッサは、自身が保有するタスクを後着順に実行する。

![images/dawn.filo.svg](images/dawn.filo.svg)

Fig. 1.2 work-stealing scheduler on shared-memory architecture.

保有するタスクを消化した場合は、他のプロセッサにある、最も粗粒度な塊を、即ち、最古のタスクを奪って実行する。
