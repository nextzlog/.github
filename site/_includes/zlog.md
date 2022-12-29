### zLog令和版

{{site.briefs.zlog}}

- [公式情報](https://use.zlog.org)
- [開発情報](https://dev.zlog.org)

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
