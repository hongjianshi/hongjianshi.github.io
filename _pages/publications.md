---
layout: page
permalink: /publications/
title: publications
description: 
years: [2023,2022,2021,2020]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>preprints</h1>

{% bibliography -f preprints %}

<h1>conference &amp; journal articles</h1>

{% for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

<h1>PhD thesis</h1>

{% bibliography -f thesis %}

<h1>technical reports &amp; short papers</h1>

{% bibliography -f reports %}

</div>
