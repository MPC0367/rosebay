# Folds the four-page site into one self-contained HTML file for publishing
# as an Artifact: chrome from index, the other three pages become routes, and
# every stylesheet, script, image and the menu JSON are inlined.
#
#   powershell -File _qa\build-artifact.ps1
#   -> _qa\rosebay-artifact.html
#
# Two things matter most here:
#  * Each image is base64'd EXACTLY ONCE into window.RB_IMG and the markup
#    carries data-img-src="<original path>". Pasting the data URI at every
#    <img src> multiplies anything that appears on more than one page and
#    blows past the 16 MB ceiling.
#  * scroll-behavior:smooth across a document this tall turns a section jump
#    into an interminable crawl, so it is forced back to auto.
param(
  [string]$Root = "$PSScriptRoot\..",
  [string]$Out  = "$PSScriptRoot\rosebay-artifact.html"
)
$ErrorActionPreference = 'Stop'
function Read-Utf8($p) { [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false)) }

$index = Read-Utf8 (Join-Path $Root 'index.html')
$menu  = Read-Utf8 (Join-Path $Root 'menu.html')
$homeP = Read-Utf8 (Join-Path $Root 'home.html')
$visit = Read-Utf8 (Join-Path $Root 'visit.html')

function Grab($html, $pattern) {
  $m = [regex]::Match($html, $pattern, 'Singleline')
  if (-not $m.Success) { throw "pattern not found: $pattern" }
  return $m.Groups[1].Value
}

# Counting the nesting, not matching lazily to the Nth close tag. A lazy
# `.*?</div>\s*</div>` stops one close short of a three-deep block, and the
# resulting unclosed <div> silently adopts the entire rest of the document —
# which is exactly what made the first build render nothing at all.
function GrabBalanced($html, $startPattern, $tag) {
  $m = [regex]::Match($html, $startPattern)
  if (-not $m.Success) { throw "start not found: $startPattern" }
  $open = "<$tag"; $close = "</$tag>"
  $i = $m.Index; $depth = 0; $p = $i
  while ($true) {
    $no = $html.IndexOf($open, $p, [StringComparison]::Ordinal)
    $nc = $html.IndexOf($close, $p, [StringComparison]::Ordinal)
    if ($nc -lt 0) { throw "unbalanced <$tag> from $startPattern" }
    if ($no -ge 0 -and $no -lt $nc) { $depth++; $p = $no + $open.Length }
    else {
      $depth--
      $p = $nc + $close.Length
      if ($depth -eq 0) { return $html.Substring($i, $p - $i) }
    }
  }
}

# --- the pieces --------------------------------------------------------------
$navHtml   = Grab $index '(<header class="nav".*?</header>)'
$sheetHtml = GrabBalanced $index '<div class="sheet"' 'div'
$veilHtml  = GrabBalanced $index '<div class="veil"' 'div'
$footHtml  = Grab $index '(<footer class="foot".*?</footer>)'
$ubarHtml  = Grab $index '(<nav class="ubar".*?</nav>)'
$dialog    = Grab $index '(<dialog class="lb".*?</dialog>)'
$ld        = Grab $index '(<script type="application/ld\+json">.*?</script>)'

# Every extracted block must close every div it opens, or the page collapses.
foreach ($pair in @(@('nav',$navHtml), @('sheet',$sheetHtml), @('veil',$veilHtml),
                    @('footer',$footHtml), @('ubar',$ubarHtml), @('dialog',$dialog))) {
  $o = ([regex]::Matches($pair[1], '<div\b')).Count
  $c = ([regex]::Matches($pair[1], '</div>')).Count
  if ($o -ne $c) { throw ("$($pair[0]): {0} <div> vs {1} </div>" -f $o, $c) }
}

$mainIndex = Grab $index '<main id="main">(.*?)</main>'
$mainMenu  = Grab $menu  '<main id="main">(.*?)</main>'
$mainHome  = Grab $homeP  '<main id="main">(.*?)</main>'
$mainVisit = Grab $visit '<main id="main">(.*?)</main>'

# index's own #visit section would collide with the #visit route
$mainIndex = $mainIndex -replace '<section class="sect" id="visit"', '<section class="sect" id="find-us"'
# so would visit's #pet against index's
$mainVisit = $mainVisit -replace 'id="pet"', 'id="v-pet"'

# --- links become routes -----------------------------------------------------
function Route($s) {
  $s = $s -replace 'href="visit\.html#pet"',   'href="#pet-friendly"'
  $s = $s -replace 'href="index\.html#',        'href="#'
  $s = $s -replace 'href="menu\.html"',         'href="#menu"'
  $s = $s -replace 'href="home\.html"',         'href="#our-home"'
  $s = $s -replace 'href="visit\.html"',        'href="#visit"'
  $s = $s -replace 'href="index\.html"',        'href="#top"'
  return $s
}
$navHtml, $sheetHtml, $footHtml, $ubarHtml,
$mainIndex, $mainMenu, $mainHome, $mainVisit =
  ($navHtml, $sheetHtml, $footHtml, $ubarHtml,
   $mainIndex, $mainMenu, $mainHome, $mainVisit | ForEach-Object { Route $_ })

# --- the map ------------------------------------------------------------------
# The artifact viewer's CSP admits no third-party frames, so the embedded
# OpenStreetMap would render as an empty box on the one section whose whole
# job is getting somebody to the restaurant. It becomes a real card instead:
# the address, the coordinates, and the button that actually matters.
$mapCard = @'
<div class="map-frame map-static">
  <div class="map-fallback">
    <svg class="map-mark" viewBox="0 0 120 62" role="presentation" focusable="false">
      <path d="M14 32 L60 8 L106 32"></path>
      <path d="M26 32 L26 54 L94 54 L94 32"></path>
    </svg>
    <p class="label" data-th="&#xe2b;&#xe19;&#xe2d;&#xe07;&#xe19;&#xe49;&#xe33;&#xe41;&#xe14;&#xe07; / &#xe40;&#xe02;&#xe32;&#xe43;&#xe2b;&#xe0d;&#xe48;">Nong Nam Daeng / Khao Yai</p>
    <p class="map-addr" data-th="339 &#xe2b;&#xe21;&#xe39;&#xe48; 11 &#xe15;&#xe33;&#xe1a;&#xe25;&#xe2b;&#xe19;&#xe2d;&#xe07;&#xe19;&#xe49;&#xe33;&#xe41;&#xe14;&#xe07;<br>&#xe2d;&#xe33;&#xe40;&#xe20;&#xe2d;&#xe1b;&#xe32;&#xe01;&#xe0a;&#xe48;&#xe2d;&#xe07; &#xe08;&#xe31;&#xe07;&#xe2b;&#xe27;&#xe31;&#xe14;&#xe19;&#xe04;&#xe23;&#xe23;&#xe32;&#xe0a;&#xe2a;&#xe35;&#xe21;&#xe32; 30130">339 Moo 11, Nong Nam Daeng<br>Pak Chong, Nakhon Ratchasima 30130</p>
    <p class="map-geo num">14.63048, 101.40451 &middot; JCJ3+5R</p>
    <a class="btn" href="https://www.google.com/maps/dir/?api=1&amp;destination=14.6304824,101.4045083" target="_blank" rel="noopener" data-th="&#xe40;&#xe1b;&#xe34;&#xe14;&#xe43;&#xe19; Google Maps">Open in Google Maps <span class="arw" aria-hidden="true">&#8599;</span></a>
  </div>
</div>
'@
function Demap($s) {
  return [regex]::Replace($s, '<div class="map-frame">.*?</div>\s*</div>', ($mapCard + "`n"), 'Singleline')
}
# the iframe sits inside .map-frame, so match to the frame's own close
function DemapOne($s) {
  $i = $s.IndexOf('<div class="map-frame">')
  while ($i -ge 0) {
    $end = $s.IndexOf('</div>', $s.IndexOf('</iframe>', $i))
    $s = $s.Substring(0, $i) + $mapCard + $s.Substring($end + 6)
    $i = $s.IndexOf('<div class="map-frame">')
  }
  return $s
}
$mainIndex = DemapOne $mainIndex
$mainVisit = DemapOne $mainVisit
if (($mainIndex + $mainVisit) -match '<iframe') { throw 'an iframe survived the map replacement' }

# The card carries the button and the coordinates itself, so the controls
# that sat beside the live map are now duplicates.
$mainVisit = [regex]::Replace($mainVisit,
  '<div class="row mt-m">\s*<a class="btn" href="https://www\.google\.com/maps/dir[^<]*<span class="arw"[^<]*</span></a>\s*</div>', '', 'Singleline')
$mainIndex = [regex]::Replace($mainIndex,
  '<p class="label mt-m" data-th="[^"]*">14\.63048[^<]*</p>', '', 'Singleline')

# --- images ------------------------------------------------------------------
$aimg = Join-Path $PSScriptRoot 'aimg'
$refs = Get-Content (Join-Path $PSScriptRoot 'used.txt') | Where-Object { $_.Trim() }
$map = [ordered]@{}
foreach ($rel in $refs) {
  $flat = ($rel -replace '^img/', '' -replace '/', '__')
  $f = Join-Path $aimg $flat
  if (-not (Test-Path $f)) { Write-Host "  ! no artifact image for $rel"; continue }
  $mime = if ($rel -match '\.webp$') { 'image/webp' } else { 'image/jpeg' }
  $map[$rel] = "data:$mime;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
}

# markup points at a name; a hydrate pass fills in the blob
$PLACE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
function Swap($s) {
  $s = [regex]::Replace($s, 'src="(img/[^"]+)"', { param($m) 'data-img-src="' + $m.Groups[1].Value + '" src="' + $PLACE + '"' })
  $s = [regex]::Replace($s, 'data-full="(img/[^"]+)"', { param($m) 'data-full="' + $m.Groups[1].Value + '"' })
  return $s
}
$mainIndex, $mainMenu, $mainHome, $mainVisit =
  ($mainIndex, $mainMenu, $mainHome, $mainVisit | ForEach-Object { Swap $_ })

$imgJson = "{" + (($map.Keys | ForEach-Object { '"' + $_ + '":"' + $map[$_] + '"' }) -join ",") + "}"

# --- inline assets -----------------------------------------------------------
$css = (Read-Utf8 (Join-Path $Root 'css\site.css')) + "`n" + (Read-Utf8 (Join-Path $Root 'css\parts.css'))
$menuJson = Read-Utf8 (Join-Path $Root 'data\menu.json')
$jsApp     = Read-Utf8 (Join-Path $Root 'js\app.js')
$jsPan     = Read-Utf8 (Join-Path $Root 'js\pan.js')
$jsMenu    = Read-Utf8 (Join-Path $Root 'js\menu.js')
$jsGallery = Read-Utf8 (Join-Path $Root 'js\gallery.js')

$routeCss = @'

/* --- single-file build -------------------------------------------------- */
/* The four pages become routes. Only one is in the document flow at a time,
   so ids stay unique-in-practice and every page starts at its own top. */
.apage { display: none; }
.apage.is-on { display: block; }
/* The map card that stands in for the blocked third-party frame. */
.map-static { display: grid; place-items: stretch; }
.map-mark { width: 74px; height: auto; overflow: visible; }
.map-mark path {
  fill: none; stroke: var(--green); stroke-width: 3;
  stroke-linecap: square; stroke-linejoin: miter;
}
.map-addr { font-size: 1.02rem; line-height: 1.7; color: var(--fg); }
.map-geo {
  font-size: .78rem; letter-spacing: .1em; color: var(--fg-3);
  font-variant-numeric: tabular-nums;
}
.map-fallback { gap: .9rem; }

/* A document this tall makes smooth scrolling an interminable crawl. */
html { scroll-behavior: auto !important; }
'@

$bootJs = @'
/* ---- single-file runtime ------------------------------------------------ */
/* Every image is stored once, keyed by its original path. The markup carries
   data-img-src and a 1x1 placeholder; this fills them in before app.js runs
   so nothing ever paints an empty frame. */
(function () {
  var imgs = document.querySelectorAll('[data-img-src]');
  for (var i = 0; i < imgs.length; i++) {
    var src = window.RB_SRC(imgs[i].getAttribute('data-img-src'));
    if (src) imgs[i].setAttribute('src', src);
  }
})();

/* ---- routes -------------------------------------------------------------- */
(function () {
  var ROUTES = { 'menu': 'page-menu', 'our-home': 'page-home', 'visit': 'page-visit' };
  /* a hash that means "this route, then this anchor inside it" */
  var ANCHORS = { 'pet-friendly': ['visit', 'v-pet'] };
  var pages = {};
  ['page-index', 'page-menu', 'page-home', 'page-visit'].forEach(function (id) {
    pages[id] = document.getElementById(id);
  });
  var nav = document.querySelector('.nav');

  function go(hash, push) {
    hash = String(hash || '').replace(/^#/, '');
    var target = 'page-index', anchor = '';

    if (ANCHORS[hash]) { target = ROUTES[ANCHORS[hash][0]]; anchor = ANCHORS[hash][1]; }
    else if (ROUTES[hash]) { target = ROUTES[hash]; }
    else if (hash && hash !== 'top' && hash !== 'main') { anchor = hash; }

    for (var id in pages) { if (pages[id]) pages[id].classList.toggle('is-on', id === target); }

    /* the transparent-over-photograph nav only belongs on the home route */
    if (nav) nav.classList.toggle('is-solid', target !== 'page-index');

    /* the utility bar's first slot points wherever you are not */
    var ub = document.querySelector('.ubar a');
    if (ub) {
      var onHome = (target === 'page-index');
      ub.setAttribute('href', onHome ? '#menu' : '#top');
      ub.setAttribute('data-th', onHome ? '0e400e210e190e39' : '0e2b0e190e490e320e410e230e01');
      delete ub.dataset.en;
      ub.textContent = onHome ? 'Menu' : 'Home';
      if (window.Rosebay) window.Rosebay.applyLang(document.documentElement.lang === 'th' ? 'th' : 'en');
    }

    /* mark the current page in the nav */
    var links = document.querySelectorAll('.nav-links a');
    for (var i = 0; i < links.length; i++) {
      var h = (links[i].getAttribute('href') || '').replace(/^#/, '');
      var isCur = (ROUTES[h] && ROUTES[h] === target) || (ANCHORS[h] && ROUTES[ANCHORS[h][0]] === target);
      if (isCur) links[i].setAttribute('aria-current', 'page');
      else links[i].removeAttribute('aria-current');
    }

    if (push && ('#' + hash) !== location.hash) {
      try { history.replaceState(null, '', hash ? '#' + hash : '#top'); } catch (e) {}
    }

    /* the newly shown page has never been measured — reveal it, then land */
    if (window.Rosebay) window.Rosebay.recollect();
    var el = anchor && document.getElementById(anchor);
    if (el) {
      window.scrollTo({ top: el.getBoundingClientRect().top + window.pageYOffset - 72, behavior: 'auto' });
    } else {
      window.scrollTo({ top: 0, behavior: 'auto' });
    }
    if (window.Rosebay) window.Rosebay.sweep();
  }

  document.addEventListener('click', function (e) {
    var a = e.target.closest('a[href^="#"]');
    if (!a) return;
    var h = a.getAttribute('href').slice(1);
    /* let the menu's own category nav scroll within its page */
    if (h.indexOf('cat-') === 0) return;
    e.preventDefault();
    go(h, true);
  });

  window.addEventListener('hashchange', function () { go(location.hash, false); });
  go(location.hash, false);
  /* fonts change every measurement; land again once they have swapped */
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(function () { if (window.Rosebay) window.Rosebay.sweep(); });
  }
})();
'@

# --- assemble ----------------------------------------------------------------
$doc = @"
<title>Rosebay Home Cooking &amp; Caf&eacute;</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400..700;1,9..144,400&amp;family=Jost:wght@200;300;400;500&amp;family=Noto+Sans+Thai:wght@300;400;500;600&amp;family=Noto+Serif+Thai:wght@500;600;700&amp;display=swap" rel="stylesheet">
<style>
.veil{position:fixed;inset:0;z-index:1000;background:#F5F2E9}
.veil-core{opacity:0}
html.veil-on,html.veil-on body{overflow:hidden}
html.veil-skip .veil,html:not(.js) .veil{display:none}
</style>
<style>
$css
$routeCss
</style>
<script>
document.documentElement.classList.add('js');
addEventListener('error', function (e) {
  if (e && e.target && e.target !== window) return;
  document.documentElement.classList.remove('js');
  document.documentElement.classList.remove('veil-on');
}, true);
try {
  document.documentElement.classList.add(
    sessionStorage.getItem('rosebay.seen') ? 'veil-skip' : 'veil-on');
} catch (e) { document.documentElement.classList.add('veil-on'); }
setTimeout(function () {
  document.documentElement.classList.remove('veil-on');
}, 5000);
</script>

<a class="skip" href="#main" data-th="ข้ามไปเนื้อหาหลัก">Skip to content</a>
$veilHtml
$navHtml
$sheetHtml

<main id="main">
  <div class="apage is-on" id="page-index">
$mainIndex
  </div>
  <div class="apage" id="page-menu">
$mainMenu
  </div>
  <div class="apage" id="page-home">
$mainHome
  </div>
  <div class="apage" id="page-visit">
$mainVisit
  </div>
</main>

$dialog
$footHtml
$ubarHtml
$ld

<script>
window.RB_IMG = $imgJson;
window.RB_MENU = $menuJson;
</script>
<script>
$jsApp
</script>
<script>
$bootJs
</script>
<script>
$jsPan
</script>
<script>
$jsMenu
</script>
<script>
$jsGallery
</script>
"@

[IO.File]::WriteAllText($Out, $doc, [Text.UTF8Encoding]::new($false))
$mb = (Get-Item $Out).Length / 1MB
Write-Host ("wrote {0}  ({1:N2} MB of a 16 MB ceiling)" -f $Out, $mb)
Write-Host ("images inlined: {0}" -f $map.Count)
