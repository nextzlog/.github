### zLog令和版

長年に渡り、コンテストを戦う数多の無線家に支持される。本格派が愛用するロギングソフトです。

- [最新版](https://github.com/jr8ppg/zLog/releases/latest)
- [プラグインで広がる可能性](https://pafelog.net/zylo.pdf)

```golang
package main

func init() {
	OnLaunchEvent = onLaunchEvent
}

func onLaunchEvent() {
	HandleButton("MainForm.CWPlayButton", onButton)
	HandleEditor("MainForm.CallsignEdit", onEditor)
}

func onButton(num int) {
	DisplayToast("click CWPlayButton")
}

func onEditor(key int) {
	DisplayToast(Query("QSO with $B"))
}
```
