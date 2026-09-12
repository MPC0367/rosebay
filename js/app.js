/* ==========================================================================
   ROSEBAY — site behaviour
   Reveals are MEASURED, never gated on IntersectionObserver. IO delivers its
   callbacks as part of the rendering lifecycle, so a host that is not
   painting normally (an embedded viewer, a throttled tab) can deliver
   nothing at all — and everything gated on it stays invisible forever.
   ========================================================================== */
(function () {
  'use strict';

  var root = document.documentElement;
  root.classList.add('js');

  /* One source runs as four pages or as a single inlined file. When the page
     carries its images as data URIs they live in window.RB_IMG, keyed by the
     original path; everywhere else this is the identity function. */
  window.RB_SRC = function (p) {
    return (window.RB_IMG && window.RB_IMG[p]) || p;
  };

  var reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* --- viewport unit, measured ------------------------------------------- */
  /* svh/vh resolve to 0px in any host that reports a zero-height viewport —
     an embedded artifact viewer, a backgrounded frame, some print paths.
     Anything sized purely in svh then collapses and disappears. --vhpx
     carries a static fallback in CSS and is refined here only when the
     measurement is actually plausible. */

  function setVh() {
    var h = window.innerHeight || root.clientHeight || 0;
    if (h > 320) root.style.setProperty('--vhpx', (h / 100) + 'px');
  }
  setVh();

  /* --- reveal on scroll, by measurement ---------------------------------- */

  var watched = [];
  function collect() {
    watched = [].slice.call(document.querySelectorAll('[data-rv]'));
  }

  function sweep() {
    // a zero-height viewport report would otherwise reveal nothing
    var vh = window.innerHeight || root.clientHeight || 800;
    for (var i = watched.length - 1; i >= 0; i--) {
      var el = watched[i];
      var r = el.getBoundingClientRect();
      // in view once its top passes 88% of the viewport, or it already
      // covers the middle of the screen (tall sections, first paint)
      if (r.top < vh * 0.88 && r.bottom > 0) {
        el.classList.add('is-in');
        watched.splice(i, 1);
      }
    }
  }

  function openAll() {
    for (var i = 0; i < watched.length; i++) watched[i].classList.add('is-in');
    watched.length = 0;
  }

  var ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(function () { ticking = false; sweep(); navState(); });
  }

  /* --- nav --------------------------------------------------------------- */

  var nav = document.querySelector('.nav');
  var solidNav = nav && nav.classList.contains('is-solid');

  function navState() {
    // read the class rather than the cached value: the single-file build
    // turns it on and off as the route changes
    if (!nav || nav.classList.contains('is-solid')) return;
    // body rect, not scrollY — true for real scrolling AND for the
    // margin-shift used by the screenshot harness
    var top = document.body.getBoundingClientRect().top;
    nav.classList.toggle('is-stuck', top < -40);
  }

  /* --- mobile sheet ------------------------------------------------------ */

  var burger = document.querySelector('.burger');
  var sheet = document.querySelector('.sheet');
  if (burger && sheet) {
    burger.addEventListener('click', function () {
      var open = burger.getAttribute('aria-expanded') === 'true';
      burger.setAttribute('aria-expanded', String(!open));
      sheet.classList.toggle('is-open', !open);
      // the nav paints over the sheet, so its white-on-photo colours would
      // leave the wordmark invisible against the sheet's paper ground
      nav && nav.classList.toggle('is-over-sheet', !open);
      document.body.style.overflow = !open ? 'hidden' : '';
    });
    sheet.addEventListener('click', function (e) {
      if (e.target.closest('a')) {
        burger.setAttribute('aria-expanded', 'false');
        sheet.classList.remove('is-open');
        nav && nav.classList.remove('is-over-sheet');
        document.body.style.overflow = '';
      }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && sheet.classList.contains('is-open')) burger.click();
    });
  }

  /* --- language ---------------------------------------------------------- */
  /* English lives in the DOM. Thai lives in data-th. The English is captured
     off the DOM the first time Thai is asked for, so it is never duplicated
     in the markup and never drifts out of sync. */

  var LANG_KEY = 'rosebay.lang';

  function applyLang(lang) {
    var nodes = document.querySelectorAll('[data-th]');
    for (var i = 0; i < nodes.length; i++) {
      var el = nodes[i];
      if (el.dataset.en === undefined) el.dataset.en = el.innerHTML;
      el.innerHTML = lang === 'th' ? el.dataset.th : el.dataset.en;
    }
    // attribute translations: data-th-attr="aria-label:ข้อความ|title:..."
    var attrs = document.querySelectorAll('[data-th-attr]');
    for (var j = 0; j < attrs.length; j++) {
      var node = attrs[j];
      var pairs = node.dataset.thAttr.split('|');
      for (var k = 0; k < pairs.length; k++) {
        var bits = pairs[k].split(':');
        var name = bits.shift();
        var val = bits.join(':');
        var store = 'en' + name.replace(/[^a-z]/gi, '');
        if (node.dataset[store] === undefined) node.dataset[store] = node.getAttribute(name) || '';
        node.setAttribute(name, lang === 'th' ? val : node.dataset[store]);
      }
    }
    root.lang = lang === 'th' ? 'th' : 'en';
    root.classList.toggle('is-th', lang === 'th');
    var btns = document.querySelectorAll('.lang button');
    for (var m = 0; m < btns.length; m++) {
      btns[m].setAttribute('aria-pressed', String(btns[m].dataset.lang === lang));
    }
    try { localStorage.setItem(LANG_KEY, lang); } catch (e) {}
    // the split heading measures itself; let it re-run after a swap
    document.dispatchEvent(new CustomEvent('rosebay:lang', { detail: { lang: lang } }));
  }

  /* --- the language swipe ------------------------------------------------ */
  /* Switching language repaints almost every string on the page at once,
     which reads as a glitch if it happens in front of you. A band in Rosebay
     green crosses the screen and the swap happens underneath it, while it has
     the page covered. Direction follows the toggle: EN sits left of ไทย, so
     going to Thai sweeps in from the right and leaves to the left. */

  var swipeEl = null;
  var swiping = false;

  function swipeNode() {
    if (swipeEl) return swipeEl;
    swipeEl = document.createElement('div');
    swipeEl.className = 'lswipe';
    swipeEl.setAttribute('aria-hidden', 'true');
    swipeEl.innerHTML = '<span class="lswipe-tag"></span>';
    document.body.appendChild(swipeEl);
    return swipeEl;
  }

  function switchLang(lang) {
    if (lang === root.lang || swiping) return;
    if (reduced) { applyLang(lang); return; }

    swiping = true;
    var el = swipeNode();
    var tag = el.querySelector('.lswipe-tag');
    tag.textContent = lang === 'th' ? 'ไทย' : 'English';
    tag.setAttribute('lang', lang);
    el.style.setProperty('--from', lang === 'th' ? 1 : -1);
    el.classList.remove('is-out');

    // force a reflow so the reset transform is the animation's start point
    void el.offsetWidth;
    el.classList.add('is-in');

    var swapped = false;
    var swap = function () {
      if (swapped) return;
      swapped = true;
      applyLang(lang);
      el.classList.remove('is-in');
      el.classList.add('is-out');
      var done = function () {
        el.classList.remove('is-out');
        el.removeAttribute('style');
        swiping = false;
      };
      // the transitionend may never arrive if the tab is backgrounded
      el.addEventListener('transitionend', done, { once: true });
      setTimeout(done, 700);
    };

    // swap the moment the band has the page covered, with a timer backstop
    el.addEventListener('transitionend', function (e) {
      if (e.propertyName === 'transform') swap();
    }, { once: true });
    setTimeout(swap, 520);
  }

  document.addEventListener('click', function (e) {
    var b = e.target.closest('.lang button');
    if (!b) return;
    switchLang(b.dataset.lang);
  });

  var saved = null;
  try { saved = localStorage.getItem(LANG_KEY); } catch (e) {}
  if (saved === 'th') applyLang('th'); else applyLang('en');

  /* --- staggered delays -------------------------------------------------- */

  function stagger() {
    var groups = document.querySelectorAll('[data-stagger]');
    for (var i = 0; i < groups.length; i++) {
      var step = parseInt(groups[i].dataset.stagger, 10) || 80;
      var kids = groups[i].children;
      for (var j = 0; j < kids.length; j++) {
        kids[j].style.setProperty('--d', (j * step) + 'ms');
      }
    }
    // line-mask headings stagger their own lines
    var lines = document.querySelectorAll('.lines, .rosebay');
    for (var k = 0; k < lines.length; k++) {
      var spans = lines[k].querySelectorAll(':scope > span');
      for (var s = 0; s < spans.length; s++) {
        spans[s].style.setProperty('--d', (s * 90) + 'ms');
        var inner = spans[s].firstElementChild;
        if (inner) inner.style.setProperty('--d', (s * 90) + 'ms');
      }
    }
  }

  /* --- deep links -------------------------------------------------------- */

  function landOnHash() {
    if (!location.hash) return;
    var t = document.getElementById(location.hash.slice(1));
    if (!t) return;
    var y = t.getBoundingClientRect().top + window.pageYOffset - 70;
    window.scrollTo({ top: y, behavior: 'instant' in document.body.style ? 'instant' : 'auto' });
  }

  /* --- boot -------------------------------------------------------------- */

  function boot() {
    collect();
    stagger();
    setVh();
    if (reduced) { openAll(); navState(); return; }
    sweep();
    navState();
  }

  boot();
  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', function () { setVh(); onScroll(); }, { passive: true });
  // an outer document may be the thing scrolling
  window.addEventListener('wheel', onScroll, { passive: true });
  window.addEventListener('touchmove', onScroll, { passive: true });
  window.addEventListener('load', function () { boot(); landOnHash(); });
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(function () { boot(); landOnHash(); });
  }
  // backstop: if no scroll signal ever arrives — an embedded viewer, a
  // backgrounded frame — show everything rather than leave the page blank
  setTimeout(function () { if (watched.length) openAll(); }, 2500);

  /* --- screenshot settle mode -------------------------------------------- */
  /* ?shot=1            reveal everything, kill transitions
     &y=1200            move the page up by 1200px
     &to=%23cafe        move so that selector sits just under the nav
     &sheet=1           open the mobile menu
     &lang=th           render Thai
     Headless capture fires near load and lays out at a shorter viewport
     first, so the positioning has to be idempotent and re-applied on
     resize — otherwise the shift is computed against the wrong height and
     lands hundreds of pixels short. */

  var q = new URLSearchParams(location.search);
  if (q.get('shot')) {
    var css = document.createElement('style');
    css.textContent =
      '*,*::before,*::after{transition:none !important;animation:none !important}' +
      '.rv,.lines>span>i,.rosebay b,.rosebay .gloss{opacity:1 !important;transform:none !important}' +
      '.rv-img>img{clip-path:none !important;transform:none !important}' +
      'html{scroll-behavior:auto !important}';
    document.head.appendChild(css);

    var applyShot = function () {
      openAll();
      var els = document.querySelectorAll('[data-rv]');
      for (var i = 0; i < els.length; i++) els[i].classList.add('is-in');
      document.body.style.marginTop = '0px';
      var off = 0;
      if (q.get('to')) {
        var t = document.querySelector(q.get('to'));
        if (t) off = Math.round(t.getBoundingClientRect().top + window.pageYOffset - 72);
      } else if (q.get('y')) {
        off = parseInt(q.get('y'), 10) || 0;
      }
      if (off) {
        document.body.style.marginTop = (-off) + 'px';
        if (nav && !solidNav) nav.classList.add('is-stuck');
      }
      if (q.get('sheet') && burger && burger.getAttribute('aria-expanded') !== 'true') burger.click();
      // &swipe=th|en freezes the language band mid-sweep so it can be seen
      if (q.get('swipe')) {
        var sw = swipeNode();
        var to = q.get('swipe') === 'th' ? 'th' : 'en';
        sw.querySelector('.lswipe-tag').textContent = to === 'th' ? 'ไทย' : 'English';
        sw.querySelector('.lswipe-tag').setAttribute('lang', to);
        sw.style.setProperty('--from', to === 'th' ? 1 : -1);
        sw.classList.add('is-in');
      }
    };

    // deterministic captures: shot mode ignores any saved preference
    applyLang(q.get('lang') === 'th' ? 'th' : 'en');
    applyShot();
    window.addEventListener('resize', applyShot);
    window.addEventListener('load', applyShot);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(applyShot);
    document.addEventListener('rosebay:rendered', applyShot);

    /* &probe=1 writes a layout report into a hidden node so headless
       --dump-dom can read it. Used for the overflow and contrast checks. */
    if (q.get('probe')) {
      var inScrollerX = function (el) {
        var n = el.parentElement;
        while (n && n !== document.body) {
          var ox = getComputedStyle(n).overflowX;
          if (ox === 'hidden' || ox === 'clip' || ox === 'auto' || ox === 'scroll') return true;
          n = n.parentElement;
        }
        return false;
      };

      var report = function () {
        var W = document.documentElement.clientWidth;
        var over = [];
        var all = document.querySelectorAll('body *');
        for (var i = 0; i < all.length; i++) {
          var el = all[i];
          if (el.closest('.mpop')) continue;
          // Content inside a container that clips or scrolls its own x-axis
          // is meant to extend past the viewport — the marquee track is
          // 13,000px wide on purpose. Only unclipped overflow is a bug.
          if (inScrollerX(el)) continue;
          var r = el.getBoundingClientRect();
          if (r.width === 0 && r.height === 0) continue;
          if (r.right > W + 1.5 || r.left < -1.5) {
            over.push(
              (el.tagName + '.' + (el.className || '').toString().split(' ').slice(0, 2).join('.'))
              + ' L' + Math.round(r.left) + ' R' + Math.round(r.right)
            );
          }
        }
        var lum = function (c) {
          var m = c.match(/[\d.]+/g);
          if (!m) return null;
          var f = m.slice(0, 3).map(function (v) {
            v = v / 255;
            return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
          });
          return 0.2126 * f[0] + 0.7152 * f[1] + 0.0722 * f[2];
        };
        var groundOf = function (el) {
          var n = el;
          while (n && n !== document.documentElement) {
            var bg = getComputedStyle(n).backgroundColor;
            // Only an effectively opaque layer counts as the ground. A
            // translucent tint would otherwise be read as solid black and
            // report a contrast failure that does not exist.
            var am = bg && bg.match(/rgba?\(([^)]+)\)/);
            var alpha = am ? parseFloat(am[1].split(',')[3] || '1') : 0;
            if (bg && alpha >= 0.9) return bg;
            n = n.parentElement;
          }
          return 'rgb(255,255,255)';
        };
        var low = [];
        var text = document.querySelectorAll('p, li, dd, dt, .label, .lede, a, h1, h2, h3, figcaption, .mrow-en, .mrow-th, .mrow-p');
        for (var j = 0; j < text.length; j++) {
          var t = text[j];
          if (!t.textContent.trim()) continue;
          if (t.closest('.hero, .table-shot')) continue; // over photography
          var cs = getComputedStyle(t);
          var l1 = lum(cs.color), l2 = lum(groundOf(t));
          if (l1 === null || l2 === null) continue;
          var ratio = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
          var px = parseFloat(cs.fontSize);
          var big = px >= 24 || (px >= 18.66 && parseInt(cs.fontWeight, 10) >= 700);
          var need = big ? 3 : 4.5;
          if (ratio < need) {
            low.push(t.tagName + '.' + (t.className || '').toString().split(' ')[0] +
              ' ' + ratio.toFixed(2) + '<' + need + ' "' + t.textContent.trim().slice(0, 26) + '"');
          }
        }
        var NL = String.fromCharCode(10);
        var box = document.getElementById('probe-out') || document.createElement('div');
        box.id = 'probe-out';
        box.style.cssText = 'position:fixed;inset:0;z-index:9999;background:#0b0d0a;color:#c8f2c8;' +
          'font:12px/1.5 ui-monospace,monospace;padding:14px;white-space:pre-wrap;overflow:auto';
        box.textContent =
          'PAGE ' + location.pathname + '  viewport ' + W +
          '  scrollWidth ' + document.documentElement.scrollWidth +
          (document.documentElement.scrollWidth > W + 1 ? '   *** HORIZONTAL OVERFLOW ***' : '   (no h-overflow)') +
          NL + NL + 'OVERFLOWING ELEMENTS (' + over.length + '):' + NL +
          (over.length ? over.slice(0, 14).join(NL) : '  none') +
          NL + NL + 'CONTRAST BELOW AA (' + low.length + '):' + NL +
          (low.length ? low.slice(0, 16).join(NL) : '  none');
        document.body.appendChild(box);
      };
      report();
      window.addEventListener('load', function () { report(); setTimeout(report, 300); });
      if (document.fonts && document.fonts.ready) document.fonts.ready.then(report);
      setTimeout(report, 1000);
    }
  }

  /* --- the veil (loading) ------------------------------------------------- */
  /* Progress is real: each signal below is an asset actually resolving. The
     bar also creeps on a timer so it never looks stalled, but it can only
     ever reach 100% when the work is genuinely done — or when the hard cap
     fires, because a page must never be held hostage by one slow image. */

  (function veil() {
    var el = document.querySelector('.veil');
    if (!el) return;

    var bar = el.querySelector('.veil-line i');
    var q = new URLSearchParams(location.search);

    var drop = function () {
      if (el.parentNode) el.parentNode.removeChild(el);
      root.classList.remove('veil-on');
    };

    var lift = function () {
      if (el.dataset.gone) return;
      el.dataset.gone = '1';
      el.classList.add('is-out');
      root.classList.remove('veil-on');
      try { sessionStorage.setItem('rosebay.seen', '1'); } catch (e) {}
      setTimeout(drop, 1000);
      // the page under it has been sitting at scroll 0 — measure it now
      boot();
    };

    // Already seen this session, or the screenshot harness wants the page
    // rather than the front door. `&veil=hold` keeps it up so the loading
    // state itself can be looked at; `&p=` sets the progress shown.
    var hold = q.get('veil') === 'hold';
    if (root.classList.contains('veil-skip') || (q.get('shot') && !hold)) { drop(); return; }
    if (hold) {
      if (bar) bar.style.setProperty('--p', q.get('p') || '0.62');
      return;
    }

    var signals = [];
    var add = function (p) { signals.push(p); };

    add(new Promise(function (res) {
      if (document.readyState === 'complete') return res();
      window.addEventListener('load', res, { once: true });
    }));
    if (document.fonts && document.fonts.ready) add(document.fonts.ready);
    var hero = document.querySelector('.hero-media img, .phero img');
    if (hero) {
      add(new Promise(function (res) {
        if (hero.complete) return res();
        hero.addEventListener('load', res, { once: true });
        hero.addEventListener('error', res, { once: true });
      }));
    }

    var total = signals.length;
    var done = 0;
    var creep = 0;
    var started = Date.now();

    function paint() {
      // real progress, floored by a slow creep so the line always moves
      var real = total ? done / total : 1;
      var p = Math.max(real, Math.min(creep, 0.92));
      if (bar) bar.style.setProperty('--p', p.toFixed(3));
    }

    signals.forEach(function (p) {
      Promise.resolve(p).then(function () { done++; paint(); });
    });

    var tick = setInterval(function () {
      creep += 0.045;
      paint();
    }, 90);

    function finish() {
      clearInterval(tick);
      if (bar) bar.style.setProperty('--p', '1');
      // let the full line be seen, and hold a beat so it never just blinks
      var waited = Date.now() - started;
      setTimeout(lift, Math.max(0, 620 - waited) + 260);
    }

    Promise.all(signals.map(function (p) { return Promise.resolve(p); })).then(finish);
    // hard cap: whatever is still loading, the visitor gets the page
    setTimeout(finish, 2600);
  })();

  window.Rosebay = {
    sweep: sweep, openAll: openAll, applyLang: applyLang,
    switchLang: switchLang, recollect: boot
  };
})();
