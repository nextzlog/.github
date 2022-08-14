### zLog令和版

長年に渡り、コンテストを戦う数多の無線家に支持される。本格派が愛用するロギングソフトです。

- [公式資料](https://zylo.pafelog.net)
- [発表資料](zylo)

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
