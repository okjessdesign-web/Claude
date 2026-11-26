    // The hover trail uses only the animated projects (the ones whose Selected Works picture is a video).
    // Three hidden "master" videos play; each trail tile paints the current frame onto its own canvas, so many tiles cost no extra downloads.
    var items = [].filter.call(document.querySelectorAll('.work'), function (w) { return w.querySelector('video'); }).map(function (w) {
      return { title: w.querySelector('.t').textContent, img: w.querySelector('.shot').style.getPropertyValue('--img').trim(), src: w.querySelector('video').getAttribute('src'), v: null };
    });
    if (!items.length) return;
    var painting = [];                               // tiles currently on screen: { c: canvas, it: item }
    function master(it) {                            // start loading/playing that project's video the first time it is needed
      if (it.v) return it.v;
      var v = document.createElement('video');
      v.muted = true; v.loop = true; v.playsInline = true; v.preload = 'auto'; v.setAttribute('aria-hidden', 'true');
      v.style.cssText = 'position:fixed;left:0;top:0;width:2px;height:2px;opacity:.01;pointer-events:none;z-index:-1';   // kept on the page (iPhones stop a video that is taken off it), outside the trail so clearing old tiles never removes it
      v.src = it.src; document.body.appendChild(v);
      var p = v.play(); if (p) p.catch(function () {});
      return (it.v = v);
    }
    function paint() {
      painting = painting.filter(function (t) { return t.c.isConnected; });
      painting.forEach(function (t) {
        var v = t.it.v, c = t.c;
        if (!v || v.readyState < 2) return;
        if (v.paused) { var p = v.play(); if (p) p.catch(function () {}); }
        var cw = c.width, ch = c.height, vw = v.videoWidth, vh = v.videoHeight, s = Math.max(cw / vw, ch / vh);
        var w = cw / s, h = ch / s;
        c.getContext('2d').drawImage(v, (vw - w) / 2, (vh - h) / 2, w, h, 0, 0, cw, ch);   // cover the tile, centred
      });
      if (painting.length) requestAnimationFrame(paint); else items.forEach(function (it) { if (it.v) it.v.pause(); });
    }
    items.forEach(master);                           // warm up all three as soon as the trail is first used (see below)
