/* ==========================================================================
   ROSEBAY — menu
   Renders data/menu.json. The menu is the page people open while they are
   already sitting in the restaurant, so it reads first and animates second:
   no entrance animation stands between a visitor and a price.
   ========================================================================== */
(function () {
  'use strict';

  var mount = document.querySelector('[data-menu]');
  var navMount = document.querySelector('[data-catnav]');
  if (!mount) return;

  var esc = function (s) {
    return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
    });
  };

  // The single-file build cannot fetch a sibling file, so it inlines the
  // same JSON as window.RB_MENU. Everything else fetches it as normal.
  (window.RB_MENU
    ? Promise.resolve(window.RB_MENU)
    : fetch('data/menu.json', { cache: 'no-store' }).then(function (r) {
        if (!r.ok) throw new Error('menu ' + r.status);
        return r.json();
      })
  ).then(render)
    .catch(function (err) {
      // The menu must never be a blank page. Point at the phone instead.
      mount.innerHTML =
        '<p class="lede" data-th="ไม่สามารถโหลดเมนูได้ในขณะนี้ กรุณาโทร 064-361-4569">' +
        'The menu could not be loaded just now. Please call 064-361-4569.</p>';
      console.error(err);
    });

  function render(data) {
    var cur = data.currency || '฿';
    var html = '';
    var navHtml = '';

    data.categories.forEach(function (cat) {
      navHtml +=
        '<a href="#cat-' + esc(cat.id) + '" data-cat="' + esc(cat.id) + '">' +
        '<i>' + esc(cat.no) + '</i>' +
        '<span data-th="' + esc(cat.name.th) + '">' + esc(cat.name.en) + '</span>' +
        '</a>';

      html += '<section class="mcat" id="cat-' + esc(cat.id) + '" data-rv>';
      html += '<div class="mcat-head">';
      html += '<h2 class="display d-md" data-th="' + esc(cat.name.th) + '">' + esc(cat.name.en) + '</h2>';
      html += '<p data-th="' + esc(cat.blurb.th) + '">' + esc(cat.blurb.en) + '</p>';
      html += '</div>';
      html += '<ul>';

      cat.items.forEach(function (it) {
        var feat = it.featured ? ' feat' : '';
        html += '<li class="mrow' + feat + '"' + (it.image ? ' data-shot="' + esc(it.image) + '"' : '') + '>';
        html += '<div class="mrow-n">';
        // the yolk dot must not be the only thing that says "house pick"
        var pick = it.featured
          ? '<span class="vh" data-th=" (ร้านแนะนำ)"> (house pick)</span>'
          : '';
        html += '<div class="mrow-en" data-th="' + esc(it.th) + '">' + esc(it.en) + pick + '</div>';
        html += '<div class="mrow-th" data-th="&nbsp;">' + esc(it.th) + '</div>';
        html += '</div>';
        html += '<div class="mrow-p"><sup>' + esc(cur) + '</sup>' + esc(it.price) + '</div>';
        if (it.image) {
          html += '<div class="mrow-shot"><img alt="" loading="lazy" decoding="async" data-src="' + esc(window.RB_SRC('img/' + it.image + '.jpg')) + '"></div>';
        }
        html += '</li>';
      });

      html += '</ul></section>';
    });

    // dishes we know are real but whose price we will not guess
    if (data.more) {
      navHtml +=
        '<a href="#cat-more" data-cat="more"><i>+</i>' +
        '<span data-th="' + esc(data.more.title.th) + '">' + esc(data.more.title.en) + '</span></a>';

      html += '<section class="mcat" id="cat-more" data-rv>';
      html += '<div class="mcat-head">';
      html += '<h2 class="display d-md" data-th="' + esc(data.more.title.th) + '">' + esc(data.more.title.en) + '</h2>';
      html += '<p data-th="' + esc(data.more.note.th) + '">' + esc(data.more.note.en) + '</p>';
      html += '</div><div class="more-groups">';
      data.more.groups.forEach(function (g) {
        html += '<div><h3 data-th="' + esc(g.name.th) + '">' + esc(g.name.en) + '</h3><ul>';
        g.items.forEach(function (it) {
          html += '<li data-th="' + esc(it.th) + '">' + esc(it.en) + '<span data-th="&nbsp;">' + esc(it.th) + '</span></li>';
        });
        html += '</ul></div>';
      });
      html += '</div></section>';
    }

    if (data.priceNote) {
      html +=
        '<p class="note" style="margin-top:clamp(2.5rem,6vw,4rem)" data-th="' +
        esc(data.priceNote.th) + '">' + esc(data.priceNote.en) + '</p>';
    }

    mount.innerHTML = html;
    if (navMount) navMount.innerHTML = navHtml;

    // language + reveals need to know about the nodes we just made
    if (window.Rosebay) {
      window.Rosebay.applyLang(document.documentElement.lang === 'th' ? 'th' : 'en');
      window.Rosebay.recollect();
    }

    wireCatNav();
    wireShots();
    document.dispatchEvent(new CustomEvent('rosebay:rendered'));

    // a #cat- deep link points at content that did not exist until now
    if (location.hash) {
      var t = document.getElementById(location.hash.slice(1));
      if (t) {
        window.scrollTo({
          top: t.getBoundingClientRect().top + window.pageYOffset - 120,
          behavior: 'auto'
        });
      }
    }
  }

  /* --- sticky category nav ----------------------------------------------- */

  function wireCatNav() {
    if (!navMount) return;
    var links = [].slice.call(navMount.querySelectorAll('a'));
    var sections = links.map(function (a) { return document.getElementById(a.getAttribute('href').slice(1)); });

    function mark() {
      var best = 0, bestTop = -Infinity;
      for (var i = 0; i < sections.length; i++) {
        if (!sections[i]) continue;
        var top = sections[i].getBoundingClientRect().top - 160;
        if (top <= 0 && top > bestTop) { bestTop = top; best = i; }
      }
      for (var j = 0; j < links.length; j++) links[j].classList.toggle('on', j === best);
      // keep the active chip in view on a narrow screen
      var on = links[best];
      if (on && navMount.scrollWidth > navMount.clientWidth) {
        var l = on.offsetLeft, w = on.offsetWidth, sl = navMount.scrollLeft, cw = navMount.clientWidth;
        if (l < sl + 8) navMount.scrollTo({ left: l - 8, behavior: 'smooth' });
        else if (l + w > sl + cw - 8) navMount.scrollTo({ left: l + w - cw + 8, behavior: 'smooth' });
      }
    }

    var ticking = false;
    window.addEventListener('scroll', function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () { ticking = false; mark(); });
    }, { passive: true });
    mark();
  }

  /* --- the dish photograph ----------------------------------------------- */

  function wireShots() {
    var rows = [].slice.call(mount.querySelectorAll('.mrow[data-shot]'));
    if (!rows.length) return;

    var canHover = matchMedia('(hover: hover)').matches;

    if (canHover) {
      var pop = document.createElement('div');
      pop.className = 'mpop';
      pop.innerHTML = '<img alt="">';
      document.body.appendChild(pop);
      var img = pop.querySelector('img');
      var loaded = {};

      rows.forEach(function (row) {
        var name = row.dataset.shot;
        row.addEventListener('pointerenter', function () {
          if (!loaded[name]) { loaded[name] = true; }
          img.src = window.RB_SRC('img/' + name + '.jpg');
          pop.classList.add('on');
        });
        row.addEventListener('pointerleave', function () { pop.classList.remove('on'); });
        row.addEventListener('pointermove', function (e) {
          // keep the photograph off the price column
          var priceLeft = row.querySelector('.mrow-p').getBoundingClientRect().left;
          var x = Math.min(e.clientX + 150, priceLeft - 150);
          x = Math.max(x, 150);
          var y = Math.max(180, Math.min(e.clientY, window.innerHeight - 180));
          pop.style.left = x + 'px';
          pop.style.top = y + 'px';
        });
      });
    } else {
      // no hover: light the row nearest the middle of the screen
      var ticking2 = false;
      function light() {
        var mid = window.innerHeight * 0.5;
        var best = null, bestD = Infinity;
        rows.forEach(function (row) {
          var r = row.getBoundingClientRect();
          var d = Math.abs((r.top + r.height / 2) - mid);
          if (d < bestD && r.bottom > 0 && r.top < window.innerHeight) { bestD = d; best = row; }
        });
        rows.forEach(function (row) {
          var on = row === best && bestD < window.innerHeight * 0.3;
          row.classList.toggle('lit', on);
          if (on) {
            var i = row.querySelector('.mrow-shot img');
            if (i && !i.src && i.dataset.src) i.src = i.dataset.src;
          }
        });
      }
      window.addEventListener('scroll', function () {
        if (ticking2) return;
        ticking2 = true;
        requestAnimationFrame(function () { ticking2 = false; light(); });
      }, { passive: true });
      light();
    }
  }
})();
