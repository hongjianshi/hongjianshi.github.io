---
layout: page
permalink: /publications/
title: publications
description: 
years: [2025, 2024, 2023, 2022, 2020]
years1: [2025, 2024]
years2: [2021]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>preprints</h1>

{% for y in page.years1 %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f preprints -q @*[year={{y}}]* %}
{% endfor %}

<h1>journal articles</h1>

{% for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

<h1>Ph.D. thesis</h1>

{% for y in page.years2 %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f thesis -q @*[year={{y}}]* %}
{% endfor %}

</div>
