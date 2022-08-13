---
title: Journal of Hamradio Informatics
subtitle: アマチュア無線は次世代の体験へ
cards:
- fava.md
- zlog.md
- ats4.md
- qxsl.md
- mine.md
- dusk.md
- chpl.md
---

{% for card in page.cards %}
<div class='card my-1 my-md-3'>
<div class='card-body'>
{% capture body %}
{% include {{card}} %}
{% endcapture %}
{{body | markdownify}}
</div>
</div>
{% endfor %}
