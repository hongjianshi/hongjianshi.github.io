---
layout: page
permalink: /publications/
title: publications
description: 
years: [2025, 2024, 2023, 2022, 2020]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>preprints</h1>

{% bibliography -f preprints %}

<h1>journal articles</h1>

{% for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

<h1>Ph.D. thesis</h1>

{% bibliography -f thesis %}

</div>
