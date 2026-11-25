    // Phones + tablets (no hover): the trail draws itself along a swoop when the page opens, then every 3 seconds:
    // right to left across the top, curving down on the left, then back to the right lower down.
    if (touch) {
      var PATH = [[0.95, 0.28], [0.72, 0.22], [0.48, 0.22], [0.25, 0.28], [0.08, 0.42], [0.12, 0.60],
                  [0.32, 0.72], [0.56, 0.72], [0.78, 0.64], [0.95, 0.56]];   // x = share of the width, y = share of the space above the tagline
      var EVERY = 3000, RUN = 1000, onScreen = true, timer = null;
      function cr(p0, p1, p2, p3, t) {             // smooth curve through the points (Catmull-Rom)
        var t2 = t * t, t3 = t2 * t;
        return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3);
      }
      function pointAt(u, w, h) {
        var n = PATH.length - 1, s = Math.min(n - 1e-6, u * n), i = Math.floor(s), t = s - i;
        var a = PATH[Math.max(0, i - 1)], b = PATH[i], c = PATH[i + 1], d = PATH[Math.min(n, i + 2)];
        return { x: cr(a[0], b[0], c[0], d[0], t) * w, y: cr(a[1], b[1], c[1], d[1], t) * h };
      }
      function run() {
        if (!onScreen || document.hidden) return;
        var tag = hero.querySelector('p'), r = trail.getBoundingClientRect();
        var w = r.width, h = tag ? tag.getBoundingClientRect().top - r.top : r.height * 0.6;
        var tile = Math.max(70, Math.min(160, w * 0.08));
        var start = performance.now(), prev = null, step = tile * 0.55;
        (function frame(now) {
          var u = Math.min(1, (now - start) / RUN), p = pointAt(u, w, h);
          if (!prev || Math.hypot(p.x - prev.x, p.y - prev.y) >= step) { spawn(p.x, p.y); prev = p; }
          if (u < 1) requestAnimationFrame(frame);
        })(start);
      }
      if ('IntersectionObserver' in window) new IntersectionObserver(function (e) { onScreen = e[0].isIntersecting; }).observe(hero);
      setTimeout(run, 150);                       // plays right away when the page opens
      timer = setInterval(run, EVERY);
      return;
    }
