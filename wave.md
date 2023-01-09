---
title: Haskellで実装する信号処理と制御理論
subtitle: Signal Processing & Control Theory on Haskell
topics: PID,MPC,制御工学,信号処理
pdf: wave.pdf
web: https://zenn.dev/nextzlog/books/signal-processing-control-theory-on-haskell
---
{% for file in site.static_files %}
{% if file.basename contains 'wave.page' and file.extname == '.svg' %}
<img src="{{file.path}}" class="img-thumbnail img-fluid" width="100%">
{% endif %}
{% endfor %}
