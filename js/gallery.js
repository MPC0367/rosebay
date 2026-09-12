/* ==========================================================================
   ROSEBAY — the running gallery
   The tiles live in the HTML so the section is a real gallery without
   JavaScript: a plain, scrollable strip of photographs. This adds the
   marquee (a second copy of the track, so the loop is seamless) and the
   lightbox.
   ========================================================================== */
(function () {
  'use strict';

  var ribbon = document.querySelector('[data-ribbon]');
  var track = ribbon && ribbon.querySelector('[data-ribbon-track]');
  var lb = document.getElementById('lightbox');
  if (!ribbon || !track) return;

  var reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
  var canHover = matchMedia('(hover: hover)').matches;

  /* --- the tiles ---------------------------------------------------------- */

  var tiles = [].slice.call(track.children);
  var shots = tiles.map(function (li) {
    var btn = li.querySelector('.gtile-btn');
    var img = li.querySelector('img');
    return {
      full: window.RB_SRC(btn.dataset.full),
      alt: img.getAttribute('alt') || '',
      cap: btn.dataset.cap || '',
      capTh: btn.dataset.capTh || ''
    };
  });

  /* --- the loop ----------------------------------------------------------- */
  /* A second copy of the track makes translateX(-50%) land exactly on the
     start of the original, so the seam is invisible. The copy is hidden
     from assistive tech and taken out of the tab order — it is the same
     twenty photographs, not forty. */

  function buildLoop() {
    if (track.dataset.looped) return;
    var copy = document.createDocumentFragment();
    tiles.forEach(function (li) {
      var clone = li.cloneNode(true);
      clone.setAttribute('aria-hidden', 'true');
      clone.classList.add('is-clone');
      var b = clone.querySelector('.gtile-btn');
      if (b) b.setAttribute('tabindex', '-1');
      copy.appendChild(clone);
    });
    track.appendChild(copy);
    track.dataset.looped = '1';
  }

  function setSpeed() {
    // constant travel, whatever the track measures: ~46px per second
    var one = 0;
    for (var i = 0; i < tiles.length; i++) {
      var r = tiles[i].getBoundingClientRect();
      one += r.width + parseFloat(getComputedStyle(tiles[i]).marginRight || 0);
    }
    if (one < 200) return; // nothing measurable yet (a hidden pane reports 0)
    ribbon.style.setProperty('--dur', Math.round(one / 46) + 's');
    ribbon.classList.add('is-live');
  }

  if (!reduced && canHover) {
    buildLoop();
    setSpeed();
    window.addEventListener('load', setSpeed);
    window.addEventListener('resize', setSpeed);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(setSpeed);
  }

  /* --- the lightbox ------------------------------------------------------- */

  if (!lb || typeof lb.showModal !== 'function') return; // links still work

  var lbImg = lb.querySelector('[data-lb-img]');
  var lbCap = lb.querySelector('[data-lb-cap]');
  var lbNow = lb.querySelector('[data-lb-now]');
  var lbAll = lb.querySelector('[data-lb-all]');
  var idx = 0;

  if (lbAll) lbAll.textContent = shots.length;

  function isThai() { return document.documentElement.lang === 'th'; }

  function show(i) {
    idx = (i + shots.length) % shots.length;
    var s = shots[idx];
    lbImg.classList.remove('ready');
    lbImg.alt = s.alt;
    lbImg.src = s.full;
    if (lbImg.complete) lbImg.classList.add('ready');
    if (lbCap) lbCap.textContent = (isThai() && s.capTh) ? s.capTh : s.cap;
    if (lbNow) lbNow.textContent = idx + 1;
    // warm the neighbours so arrowing through does not stall
    [idx + 1, idx - 1].forEach(function (n) {
      var p = new Image();
      p.src = shots[(n + shots.length) % shots.length].full;
    });
  }

  lbImg.addEventListener('load', function () { lbImg.classList.add('ready'); });

  function open(i) {
    show(i);
    ribbon.classList.add('is-paused');
    lb.showModal();
  }

  function close() {
    ribbon.classList.remove('is-paused');
    if (lb.open) lb.close();
  }

  // one delegated handler covers the clones too
  track.addEventListener('click', function (e) {
    var btn = e.target.closest('.gtile-btn');
    if (!btn) return;
    var li = btn.closest('.gtile');
    var all = [].slice.call(track.children);
    open(all.indexOf(li) % shots.length);
  });

  lb.addEventListener('click', function (e) {
    if (e.target.closest('[data-lb-close]')) return close();
    if (e.target.closest('[data-lb-prev]')) return show(idx - 1);
    if (e.target.closest('[data-lb-next]')) return show(idx + 1);
    // clicking the surround, but not the picture itself, closes
    if (!e.target.closest('.lb-fig, .lb-btn')) close();
  });

  lb.addEventListener('keydown', function (e) {
    if (e.key === 'ArrowRight') { e.preventDefault(); show(idx + 1); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); show(idx - 1); }
  });

  // <dialog> handles Esc itself; make sure the ribbon restarts either way
  lb.addEventListener('close', function () { ribbon.classList.remove('is-paused'); });

  // captions follow the language switch while the lightbox is open
  document.addEventListener('rosebay:lang', function () {
    if (lb.open && lbCap) {
      var s = shots[idx];
      lbCap.textContent = (isThai() && s.capTh) ? s.capTh : s.cap;
    }
  });
})();
