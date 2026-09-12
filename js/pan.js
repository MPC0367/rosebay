/* ==========================================================================
   ROSEBAY — FROM PAN TO PLATE
   The signature. A circle holds still while you scroll past it. It begins
   small, dark and hot — a pan in the middle of service — and ends wide,
   bright and calm: a plate on a table. Only real Rosebay photographs.

   Driven by measurement (getBoundingClientRect on a rAF-throttled scroll),
   not IntersectionObserver, for the same reason as the reveals.
   ========================================================================== */
(function () {
  'use strict';

  var pan = document.querySelector('[data-pan]');
  if (!pan) return;

  var sticky = pan.querySelector('.pan-sticky');
  var disc = pan.querySelector('.pan-disc');
  var shots = [].slice.call(pan.querySelectorAll('.pan-disc img'));
  var steps = [].slice.call(pan.querySelectorAll('.pan-step'));
  var ticks = [].slice.call(pan.querySelectorAll('.pan-ticks i'));
  var bar = pan.querySelector('.pan-rim .bar');
  if (!disc || !shots.length) return;

  var reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;

  var LEN = 0;
  if (bar) {
    var r = bar.r.baseVal.value;
    LEN = 2 * Math.PI * r;
    bar.style.strokeDasharray = LEN;
    bar.style.strokeDashoffset = LEN;
  }

  var n = shots.length;
  var current = -1;

  function setStage(i) {
    if (i === current) return;
    current = i;
    for (var k = 0; k < shots.length; k++) shots[k].classList.toggle('on', k === i);
    for (var s = 0; s < steps.length; s++) steps[s].classList.toggle('on', s === i);
    for (var t = 0; t < ticks.length; t++) ticks[t].classList.toggle('on', t <= i);
  }

  function frame() {
    var box = pan.getBoundingClientRect();
    var vh = window.innerHeight || document.documentElement.clientHeight || 800;
    // travel = how far through the pinned run we are, 0 → 1
    var total = box.height - vh;
    if (total <= 0) total = 1;
    var p = (-box.top) / total;
    p = p < 0 ? 0 : p > 1 ? 1 : p;

    // stage index across n stages
    var idx = Math.min(n - 1, Math.floor(p * n));
    setStage(idx);

    // the pan grows into a plate: 0.42 → 1
    var s = 0.42 + (1 - 0.42) * easeOut(p);
    disc.style.setProperty('--s', s.toFixed(4));

    // and it cools as it reaches the table
    disc.style.setProperty('--heat', (1 - p * 0.92).toFixed(3));

    if (bar) bar.style.strokeDashoffset = (LEN * (1 - p)).toFixed(2);
  }

  function easeOut(t) { return 1 - Math.pow(1 - t, 2.2); }

  if (reduced) {
    // no scrub: show the finished plate, full size, and list the stages
    disc.style.setProperty('--s', '1');
    disc.style.setProperty('--heat', '0.08');
    setStage(n - 1);
    pan.style.height = 'auto';
    if (sticky) { sticky.style.position = 'static'; sticky.style.height = 'auto'; sticky.style.paddingBlock = '4rem'; }
    for (var s2 = 0; s2 < steps.length; s2++) steps[s2].classList.add('on');
    if (bar) bar.style.strokeDashoffset = '0';
    return;
  }

  var ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(function () { ticking = false; frame(); });
  }

  frame();
  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', onScroll, { passive: true });
  window.addEventListener('wheel', onScroll, { passive: true });
  window.addEventListener('touchmove', onScroll, { passive: true });
  window.addEventListener('load', frame);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(frame);
})();
