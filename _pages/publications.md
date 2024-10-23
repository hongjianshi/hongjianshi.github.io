---
layout: page
permalink: /publications/
title: publications
description: 
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>preprints</h1>

{% bibliography -f preprints %}

<h1>journal articles</h1>

{% for y in page.years %}
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

<h1>Ph.D. thesis</h1>

{% bibliography -f thesis %}

</div>
