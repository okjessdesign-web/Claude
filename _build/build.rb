# Builds every project page from the Noko template (head/CSS, header, footer and scripts are copied as-is).
# Usage: ruby build.rb <site folder>
SITE = ARGV[0] or abort 'site folder?'
CDN  = 'https://framerusercontent.com/images/'

# Changes applied to both the homepage and the project-page template (shared CSS and scripts)
PATCHES = [
  # bigger arrows on the pill buttons (Link, email)
  ["  .pill:hover { background: var(--fg); color: var(--bg); }\n",
   "  .pill:hover { background: var(--fg); color: var(--bg); }\n" \
   "  .pill .arw { display: block; width: 1.3em; height: 0.8em; flex: none; }   /* the arrow, drawn bold and larger than the text */\n"],
  # cursor: the arrow only shows on an image or in the gap between images, never over the header/menu
  ["      var inWorks = !!(el && el.closest && el.closest('#works, .arrow-zone'));     // the arrow stays an arrow through the whole works section\n" \
   "      var a = !!(el && el.closest && el.closest('.shot'));             // ...and blends ('difference') over the images\n",
   "      var inHead = py <= headerBar.getBoundingClientRect().bottom + 6;   // never an arrow over the logo, tagline or menu\n" \
   "      var a = !inHead && !!(el && el.closest && el.closest('.shot'));   // on an image: arrow, blended ('difference')\n" \
   "      var onText = !!(el && el.closest && el.closest('.t, .tags, .whead, .lab, .body-copy, .pill, .meta, a.work .t'));\n" \
   "      var inWorks = !inHead && (a || (!onText && betweenShots()));       // ...and in the gap between two images\n" \
   "      if (worksLine && py <= worksLine.getBoundingClientRect().bottom) { a = false; inWorks = false; }   // homepage: always a dot above the line under Selected Works\n"],
  # bigger footer links and project tags
  ["  .f-info a:hover { text-decoration: underline; text-underline-offset: 3px; }\n",
   "  .f-info a:hover { text-decoration: underline; text-underline-offset: 3px; }\n" \
   "  .f-info { font-size: 13px; gap: 7px; }\n" \
   "  .work .tags, .g .meta .tags, body .more .work .tags { font-size: 12px; gap: 0 12px; margin-top: 4px; }\n"],
  ["    function check() {\n",
   "    var headerBar = document.querySelector('header');\n" \
   "    var worksLine = document.querySelector('#works > .whead');\n" \
   "    function betweenShots() {                       // is the pointer in the gap with an image on both sides (left+right or above+below)?\n" \
   "      var G = Math.max(24, window.innerWidth * 0.02), shots = document.querySelectorAll('.shot');\n" \
   "      var L = false, R = false, U = false, D = false;\n" \
   "      for (var i = 0; i < shots.length; i++) {\n" \
   "        var r = shots[i].getBoundingClientRect();\n" \
   "        if (py >= r.top && py <= r.bottom) { if (r.right <= px && px - r.right <= G) L = true; if (r.left >= px && r.left - px <= G) R = true; }\n" \
   "        if (px >= r.left && px <= r.right) { if (r.bottom <= py && py - r.bottom <= G) U = true; if (r.top >= py && r.top - py <= G) D = true; }\n" \
   "      }\n" \
   "      return (L && R) || (U && D);\n" \
   "    }\n" \
   "    function check() {\n"],
]
ARROW_SVG = %(<svg class="arw" viewBox="0 0 34 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="square" aria-hidden="true"><path d="M1 10h30M22 2l9 8-9 8"/></svg>)
MENU_LINK = %(\n        <li><a href="agency-client-work.html">Agency + Client</a></li>)
def arrows(s)
  s.gsub(%(<span aria-hidden="true">&rarr;</span>), ARROW_SVG)
   .sub(%r{(<li><a href="(?:index\.html)?#works">Works</a></li>)}) { $1 + MENU_LINK }   # menu link to the Agency + Client Work page
   .sub(%r{\n *<li><a href="(?:index\.html)?#info">Info</a></li>}, '')
   .sub('</body>') { VIDEO_JS + '</body>' }   # Info taken out of the menu
end
def patch(src)
  PATCHES.reduce(src) { |s, (from, to)| s.include?(from) ? s.sub(from, to) : abort("patch not found: #{from[0, 60]}") }
end

TPL = patch(File.read(File.join(SITE, 'noko-blind-box_1.html')))

# Homepage: same patches, and project links point at the local pages
home = patch(File.read(File.join(SITE, 'index_1.html')))
  .gsub(%r{https://okjess\.com/(beyond-the-trails|solis|atelier-co|mind-motion|framed-together|collective-moments|corbeau-mocktail-lounge)"}, '\1.html"')

EXTRA_CSS = <<CSS

  /* ===== Added for the other project pages ===== */
  .body-copy + .body-copy { margin-top: 1.1em; }   /* paragraphs that follow each other get a gap */
  h1.wmbox .ch { transition-delay: var(--d, 0ms); }   /* page titles rise as one piece, not letter by letter */
  /* pictures and videos run to the edges of the screen (small gap kept between paired pictures) */
  .hero-media { margin-left: 0; margin-right: 0; }
  .g { padding-left: 0; padding-right: 0; }
  .more .work .t, .more .work .tags { padding-left: 1.95vw; padding-right: 1vw; }   /* the text under the More works pictures stays in line with the page text */
  .ident .lab { font-size: 18px; margin-bottom: 18px; }   /* About / Visual identity / Design */
  .g.one { grid-template-columns: 1fr; }
  .g.nat { display: flex; align-items: flex-start; }
  .g.nat .shot { flex: var(--r) 1 0; min-width: 0; }
  .g.one .shot, .g.nat .shot { background-size: cover; }
  .g.solo { justify-items: center; }
  .g.solo .shot { width: min(100%, calc(100vh * var(--r))); }   /* a squarer picture on its own: at most one screen tall */
  @media (max-width: 760px) {
    .hero-media { margin-left: 0; margin-right: 0; }
    .g { padding-left: 0; padding-right: 0; }
    .more .work .t, .more .work .tags { padding-left: var(--pad); }
    .ident .lab { font-size: 16px; margin-bottom: 12px; }
    .g.nat { flex-direction: column; }
    .g.nat .shot { flex: none; width: 100%; }
    .g.solo .shot { width: 100%; }
  }
CSS

# Click a picture on a work page to see it full size. Arrow keys / side arrows move between pictures, Esc or a click closes.
LIGHTBOX_CSS = <<CSS
  .hero-media[style] { background-image: var(--img); }   /* the top box shows its photo */
  .zoomable { cursor: zoom-in; }
  .lb { position: fixed; inset: 0; z-index: 9000; background: rgba(218, 218, 218, .96); display: grid; place-items: center;
        opacity: 0; visibility: hidden; transition: opacity .35s ease, visibility 0s .35s; }
  .lb.open { opacity: 1; visibility: visible; transition: opacity .35s ease; }
  .lb img { max-width: calc(100vw - 160px); max-height: calc(100vh - 120px); object-fit: contain; display: block;
            transform: scale(.97); transition: transform .5s cubic-bezier(.2, .7, .2, 1); }
  .lb.open img { transform: none; }
  .lb button { position: absolute; background: none; border: 0; padding: 18px; color: var(--fg); font: inherit; font-size: 12px; text-transform: uppercase; letter-spacing: .02em; }
  .lb .x { top: 14px; right: 14px; }
  .lb .pv, .lb .nx { top: 50%; transform: translateY(-50%); }
  .lb .pv { left: 10px; } .lb .nx { right: 10px; }
  .lb .pv svg, .lb .nx svg { width: 34px; height: 20px; display: block; }
  .lb .pv svg { transform: scaleX(-1); }
  .lb .n { position: absolute; bottom: 22px; left: 50%; transform: translateX(-50%); font-size: 12px; color: var(--fg); }
  @media (max-width: 760px) { .lb img { max-width: calc(100vw - 32px); max-height: calc(100vh - 160px); } .lb .pv, .lb .nx { top: auto; bottom: 8px; transform: none; } }
CSS

LIGHTBOX_HTML = <<~H.chomp
  <div class="lb" id="lb" role="dialog" aria-modal="true" aria-label="Picture" aria-hidden="true">
    <img alt="">
    <button class="x" type="button">Close</button>
    <button class="pv" type="button" aria-label="Previous picture">#{ARROW_SVG}</button>
    <button class="nx" type="button" aria-label="Next picture">#{ARROW_SVG}</button>
    <span class="n"></span>
  </div>
  <script>
  (function () {
    var lb = document.getElementById('lb'), im = lb.querySelector('img'), n = lb.querySelector('.n');
    var shots = [].slice.call(document.querySelectorAll('main .shot')).filter(function (s) { return !s.closest('a') && (s.getAttribute('style') || '').indexOf('url(') > -1; });
    var at = 0;
    function src(s) { var u = s.getAttribute('style'); u = u.slice(u.indexOf('http')); u = u.slice(0, u.search(/['")]/)); return u.split('?scale-down-to=')[0] + '?scale-down-to=2048'; }
    function show(i) { at = (i + shots.length) % shots.length; im.src = src(shots[at]); n.textContent = (at + 1) + ' / ' + shots.length; }
    function open(i) { show(i); lb.classList.add('open'); lb.setAttribute('aria-hidden', 'false'); document.documentElement.classList.add('lb-on'); }
    function close() { lb.classList.remove('open'); lb.setAttribute('aria-hidden', 'true'); document.documentElement.classList.remove('lb-on'); }
    shots.forEach(function (s, i) { s.classList.add('zoomable'); s.addEventListener('click', function () { open(i); }); });
    lb.querySelector('.pv').addEventListener('click', function (e) { e.stopPropagation(); show(at - 1); });
    lb.querySelector('.nx').addEventListener('click', function (e) { e.stopPropagation(); show(at + 1); });
    lb.addEventListener('click', close);
    document.addEventListener('keydown', function (e) {
      if (!lb.classList.contains('open')) return;
      if (e.key === 'Escape') close(); else if (e.key === 'ArrowLeft') show(at - 1); else if (e.key === 'ArrowRight') show(at + 1);
    });
    window.addEventListener('wheel', function (e) { if (lb.classList.contains('open')) { e.stopImmediatePropagation(); e.preventDefault(); } }, { capture: true, passive: false });
  })();
  </script>
H

head   = TPL[/\A.*?(?=<\/style>)/m]
header = TPL[/<header>.*?<\/header>/m]
tail   = TPL[/<footer id="contact">.*\z/m]

# id => [width, height]
def img(id, w, h, max = 2048)
  q = w > max ? "?scale-down-to=#{max}" : ''
  { url: CDN + id + q, r: w.to_f / h }
end

P = {
  'noko-blind-box' => {
    title: 'Noko Blind Box', thumb: 'images/noko-blind-box.jpg', tags: %w[Packaging Branding Storytelling], lab2: 'Visual identity',
    link: 'https://obvious-badger-308709.framer.app/',
    about: "Noko represents the intersection of art, animal rehabilitation, and simplicity. It is a blind box series that focuses on one area of rehabilitation at a time, highlighting a curated group of endangered animals. With every purchase, 30% is donated directly toward conservation efforts supporting these species. What sets Noko apart is its approach to the blind box format. These are not mass produced collectibles; each figure is individually hand sculpted and painted, positioning the project firmly within the realm of art. Every piece is created with intention, skill, and time, elevating the figures into high end, collectible artworks rather than disposable novelties. Noko is designed to be a one time, meaningful interaction, an experience that extends beyond the purchase itself. It offers a lasting sense of connection, allowing the buyer to feel part of a greater mission rooted in care, awareness, and impact.",
    ident: "Noko’s visual identity blends hand drawn logos, headers, and iconography with clean minimalism to reflect both playfulness and the seriousness of animal rehabilitation. Gradients, made using personal photography, paired with black and white backgrounds create a sense of clarity and cleanliness.  Animal icons function as modular logos, used alongside the Noko name to give each species its own distinct identity. The consistent square palettes across deliverables reinforce the idea of a limited, curated collection. Within this project, the Seaside Collection is the current drop, while others remain archived.  A recurring motif is “blob tracking,” seen in connecting square elements across the website. This acts as an abstract, modern visualization of rehabilitation; linking the purchase to the animal, the animal to its rehabilitator, and ultimately back to nature. It also nods to the reality of these species being so rare that they must be carefully tracked and monitored.",
    process: 'Process: Spanning September 1st-April 17',
    four: [['zhPPJS3ymrXa8C1k9OmlylJk4.png',1452,1428],['PQa88D9IjPAQpluMvKxLK2oFMU.png',1452,1432],['6HQBccjd2L7K6vzQIW1lGSsDrk.png',1214,1214],['TYAGzbZZjw9sOtofVdI8T2q86yA.png',1536,1366]],
    two:  [['WxfSwRuSGW96nqkYvz0MiJ7JoQ.png',1942,1090],['5wdKvjyPXQ9V5ylH11YoUAWDkJA.png',1758,1512]],
    strip:[['gLpfsoqFLWqz6B3sjWm0MLleNE.png',1838,1220],['P31JwueR6hdPjYsHDjKG2JMsd0.png',1834,1220],['L2J6on1uPXWQBpqwcZVKEccn4Zs.png',1836,1216],['zqJR88mW7nDlPouPc4kJNK2bA.png',1834,1220],['atUAQNyHEifW9AmUl7UrxIqgw.png',2070,1374]],
  },
  'beyond-the-trails' => {
    title: 'St. Jacobs Antiques Market', thumb: 'images/st-jacobs-antiques-market.jpg', tags: %w[Branding Storytelling Print], lab2: 'Visual identity',
    link: 'https://www.stjacobsantiquesmarket.com/',
    about: "For St. Jacobs Market, refined and minimal brand collateral was designed, including business cards, merchandise, and a website, working within an existing brand identity. The goal was to apply the system in a clean, modern way across print, signage, and digital touchpoints while preserving the character, charm, and uniqueness of the market. Rooted in discovery, history, and curiosity, the collateral reflects the market’s layered identity in a contemporary and approachable way.",
    ident: "The existing colour palette was applied consistently across all deliverables to create a cohesive system for print, merchandise, and digital collateral. The dark, muted base establishes a sense of depth and refinement that supports the market’s atmosphere of discovery, while orange accents are used strategically to draw attention and add energy within a minimal layout. Clean, modern sans serif typography ensures clarity and legibility across business cards, merchandise, signage, and the website. The website incorporates motion and interaction to echo the experience of exploring the market, guiding users through content while maintaining readability and visual impact. Together, these elements allow the collateral to feel modern and functional while still aligning with the market’s historic character.",
    process: 'Process- ad, apparel',
    four: [['2IeBml8NLuZLpEXWqPm5Bohs.jpg',4000,3000],['4MISSi7GskVUY1B09sI2AgbCLg.jpg',2179,2178],['DDkUl6kRrayUWHmO3xDbfNmdFnY.png',4000,3000],['Bna8O8q7j995EUAmSjo1JeZ3tbY.jpg',3000,2250]],
    two:  [['ugTk4wfaEe8cGEmCP9GTwx4Tv8.jpg',2880,1620],['l5koY4IX1v4JmjrOQD41Sv7Fst4.jpg',2210,1711]],
    strip:[['eNh3O7kfGblF7HZPNznLsK7Ao8.jpg',2030,1252],['tRAM07JN8PA0KvwFWSBqMNSD8I.jpg',986,928]],
  },
  'solis' => {
    title: 'Control Room', thumb: 'images/control-room.jpg', tags: ['Title Sequence','Motion','Illustration','Storytelling'], lab2: 'Design',
    link: 'https://www.youtube.com/watch?v=262m5Q-wdHc',
    about: "The title sequence for Control Room introduces viewers to a world of growing paranoia, where a man (Donald Glover) realizes he is being watched and anyone he tells mysteriously disappears. Through minimalist visuals and symbolic imagery, the sequence hints at surveillance, disappearance, and the character’s spiraling uncertainty, drawing the audience into the unsettling and mysterious tone of the show. Music used in sequence is 'I Killed You' by Tyler the Creator, 2024.",
    ident: "The sequence uses simple illustrations, icons, and typography to make the fast pace of the story digestible while maintaining a sense of unease. A restricted palette of off-white, black, and red reinforces tension and urgency. Symbolic elements like cameras, eyes, birds, and signals hint at surveillance and disappearance, creating a visual language that supports the narrative while keeping the viewer engaged. The design balances clarity with suspense, making complex themes approachable without losing the show’s eerie, offbeat tone.",
    process: 'Process- storyboards, illustration, logo + cast ideas',
    four: [['SzsDJHPAmNKsB4VsCI4iDhI3tWU.png',4000,4000],['yxBPnNso02DScQP0h6bRcIZaDtc.png',5092,5123],['SXb6fmJaPSQd1OdnqWJ3VKv8NPo.png',3000,2300],['cRrBoQvUI4f7AIlOp5rFugeBi4.png',3823,3823]],
    two:  [['qpXKkR5m9VQgPHJWZgKHY9Is4zA.png',10007,5123],['2A2LMbmpBpAZjxBuE1iiOwRR4J8.png',9151,5842]],
    strip:[['z9mK2lrSM3LmBLChxFEuj1mMHRY.jpg',2002,1600],['NpEBCn3suUiRCa9HUn1MkYgzoi0.jpg',795,708],['3DhOo99Km1dVdGOBnkTvcwEv2g.jpg',1110,726],['ygKZhsdonDect7dj47nZSFhXc.jpg',1632,907]],
  },
  'atelier-co' => {
    title: 'Tipsy Tonic Kombucha', thumb: 'images/tipsy-tonic-kombucha.jpg', tags: %w[Branding Packaging Illustration], lab2: 'Visual identity',
    link: nil,
    about: "Tipsy Tonic is a hard kombucha packaging concept designed to bring playful storytelling and clean ingredients together in a crowded alcohol market. The brand balances fun and purity, using bold visuals to stand out on shelf while staying aligned with Lobo Co’s values of artisanal quality, vibrant narratives, and natural refreshment. Each can introduces a flavour as its own small story, inviting curiosity and a sense of lighthearted adventure.",
    ident: "The packaging system combines bright mesh gradients, playful animal illustrations, and hand drawn fruit motifs to create a cohesive yet expressive visual family. Saturated colours and wavy, energetic typography reinforce the brand’s youthful and spirited tone, while illustrated fruits add appetite appeal and vibrancy. Animal characters interact with the ingredients to introduce motion and personality, making each flavour feel alive. Visual cues also tie flavours to their regions of origin through researched symbolism, adding depth and intention to the storytelling. The design balances clarity and boldness, turning each can into a lively, sensory experience rather than just a label.",
    process: 'Process- original idea, sketches, refined idea, mockup example',
    four: [['alPzAolEgDiwT5C067gqOMRIxc.png',888,888],['AwzBWDder3tUyuHNNoFWpxzE2Y.png',1032,1068],['SQpTSrJjf0mOXow2BKxFVl2qFU.png',1516,1494],['IzYhYRDgo5eaVXAiHn6EzK2t2A.png',4000,2668]],
    two:  [['qXT2mj9AnOc9z98lDacys84ZI.png',2374,1506],['ryY0u6HtSVzwKD3fvHy7XFMjgTc.png',1831,1693]],
    strip:[['vGRDP7dXnsy2FFsV2qG68mO30.jpg',1068,1064],['LW1l0a03ByxtJbmAggCxIH3XJs.jpeg',3024,4032],['h2KNWowqLB5X2C2Yoo7OSFOiF5w.png',4000,4000],['6l5WMn2Xr8c9Zfn2wIG9HQmqwc.jpg',4000,3000]],
  },
  'mind-motion' => {
    title: 'Rationed Recipes Cookbook', thumb: 'images/rationed-recipes-cookbook.jpg', tags: %w[Print Photography Editorial], lab2: 'Design',
    link: nil,
    about: "Rationed Recipes is more than a cookbook, it's an immersive exploration of Polish cuisine and history under communism. Inspired by 1970s Polish food newspapers, it showcases traditional dishes while tracing the evolution of rationing and the broader political landscape from the post World War II era to the late 1980s, including the Solidarity movement. The book is structured around Kartki, the ration cards that dictated what families could eat, highlighting resilience and creativity in the face of scarcity.",
    ident: "The design balances brutalist layouts with precise typography and a monochrome palette, punctuated by selective pops of colour in stamps and numbers. The physical book features a translucent vellum cover, allowing Polish translations and underlying details to peek through, creating a layered, tactile experience. Each spread maintains historical accuracy while remaining visually clear, turning recipes and archival context into a cohesive, immersive experience that is both authentic and striking.",
    process: 'Process- original concept, photography, layout',
    four: [['VUym0uT3rZ6XYMUNhwBQEU8lNpI.jpg',4000,3000],['v8OzxTYLAihAxJr3wJcx6iCMpUQ.jpg',4000,3000],['PEs10xalvp4xdRoBc9FAzIZCcgY.jpg',4000,3000],['fGWSVznKQo7PMrNUOb57Hllv47g.jpg',4000,3000]],
    two:  [['uawJ4DmHYMVtqWM3PEd334Prjw.jpg',4000,3000],['Iu43CzAN0dBzyXM1DNT6uNHnSpA.jpg',7052,5870]],
    strip:[['IiWwMYxSbTipTlgjZ1vbIAYVg80.jpg',2448,1330],['dYPRBec4qmRdhIzZNX6fU3Had48.jpg',5184,3456],['TDJrn1Uo5KIazmSnksCNhOivXE.jpg',2424,1554],['FtCnWPvt9vNpGlFFX4sNj2lT85w.jpeg',3024,4032]],
  },
  'framed-together' => {
    title: 'Forme Magazine', thumb: 'images/forme-magazine.jpg', tags: ['Photography + Branding','Editorial','Web'], lab2: 'Design',
    link: 'https://www.figma.com/proto/F06HMTQ8OTbR3jCjiYIqTQ/FINAL-FORME-APP?node-id=17-29&t=2sdUy4GaW9O25smD-1',
    about: "FORME Magazine celebrates art, antiques, and Canadiana through storytelling that reveals the history and beauty behind each object. Each issue explores a different theme, from decaying artifacts to sentimental treasures, creating an experience that is both educational and visually engaging. The magazine invites readers to discover the stories behind these pieces while enjoying a dynamic and thoughtfully curated visual journey. Extending this experience, the app prototype offers a more immersive way to engage with each artifact beyond the printed page. Users can explore objects in 360 degrees, uncover additional context, and examine details that might otherwise go unnoticed. The platform itself allows for the creation of personalized collections, encouraging deeper connections with selected pieces, while intuitive navigation by issue keeps the archive organized and accessible. With updates on newly released editions, the app ensures readers remain connected to the evolving world of FORME.",
    ident: "The magazine combines bold typography, dramatic photography, and intentionally offbeat layouts to balance clarity with visual intrigue. Some spreads feature singular, cut-out images paired with playful type, while others use unique layouts to maintain reader engagement and deliver information in a clean, approachable way. Each design choice reinforces FORME’s mission to be educational, visually compelling, and fun, transforming every feature into a striking exploration of history and aesthetics.",
    process: 'Covers + spreads close up',
    four: [['YnkxT0DIwTVpRA2o8RiOpUNMAM.png',2099,2099],['GJBQuZo4G19OCk63tP3KKQgJwY.png',3441,3193],['sIiiPURt9Jfhlu4tvO1Cews2p0.png',3321,3042],['j4JDmNE9ryEYcEMDWp8smq7NbcQ.png',2751,2751]],
    two:  [['nghEKHyQVOvnwvRgpaEYH38aTLs.png',5000,3335],['XvPmvAN9y0URA1Fd4gPjj2Fxcuc.jpg',1725,1294]],
    strip:[['aUrKFYo7E6AliI3getxusRjGg.jpg',2700,3675],['QY2PBLyqIADGSgG0e6isu1VN0.jpg',2700,3675],['tkwSXd8wRNZRJaJqjXKgejPWODI.jpg',5400,3675],['lyfzwT6TG8TvHeSVW3S0sLF4jA.jpg',5400,3675],['3EZ4yHVeRXgjwu0x1efL2BRmy7E.jpg',5400,3675]],
  },
  'collective-moments' => {
    title: 'Seekers Ageless Expo', thumb: 'images/seekers-ageless-expo.jpg', tags: %w[Motion Branding Web], lab2: 'Visual identity',
    link: 'https://static-methodologies-326185.framer.app/',
    about: "Seekers is a travel expo designed for adults 55+ who are adventurous and eager to explore. The event brings together travel partners, inspiring speakers, and unique vendors to spark curiosity and make planning new adventures easy and enjoyable. With a clean, modern identity utilizing a modern logo, bold type, iconography, and a fresh palette, Seekers celebrates meaningful travel, connection, and the joy of discovering the world.",
    ident: "For Seekers, the design spans web, motion, and iconography to create a cohesive and modern visual experience. Original travel photography adds authenticity and a sense of adventure while legibility and clean layouts ensure clarity. The design contrasts with traditional branding for this demographic by embracing a modern, fun, and adventurous tone. Every element from motion interactions to icons and typography feels approachable, inspiring, and judgement free, reflecting the spirit of exploration at any age.",
    process: 'Process- user personas, email, signage, socials',
    four: [['Ay4TyzhHZJuTPuc8rs5uoXIsA.png',4000,3000],['gIWj5KOxO2HmG4lUTJikEI.png',1542,1944],['D9x29X7ls4JDwvl0UiwOjWotWEY.jpg',2226,1538],['LtpGSFxHvmYRAmp3GytcTAXONsQ.png',2024,1672]],
    two:  [['nkzeqA9d1wNhqYAZrPoLls7xNo.png',4000,3000],['pjt0nLXiuBuprTngSwpXqG5gM.png',2211,1821]],
    strip:[['MmGgJsMvBhgRBp0MfPQsSObSBjM.png',4032,2322],['pc5Z0ibGJoNJBfvGkJZZuKXhQ.png',1728,1508],['Zkbfl9FrOhx7TVTzstUzeR3eA.png',1936,978],['FowQ04OyRy45W6l76CBhkcNOt6o.png',4000,3364]],
  },
  'corbeau-mocktail-lounge' => {
    title: 'Corbeau Lounge', thumb: 'images/corbeau-lounge.jpg', tags: %w[Branding Illustration Print], lab2: 'Visual identity',
    link: 'https://familiar-balance-204707.framer.app/',
    about: "Corbeau is an alcohol free 18+ lounge designed as an alternative to traditional nightlife. This project includes branding, print, and web deliverables that support both the physical space and its online presence. Deliverables include the core brand identity, printed menus, signage, and supporting brand materials, along with a website that reflects the tone of the lounge. Together, these elements create a consistent experience across in person and digital touchpoints, clearly communicating what Corbeau is and who it is for.",
    ident: "The visual identity was designed to feel calm, simple, and welcoming. The hand drawn crow icon and watercolor style illustrations were chosen to give the brand a more human and approachable feel. Thin, all caps typography keeps the logo light and understated, while the script style tagline adds softness and personality. These choices were made to reflect the slower, more intentional atmosphere of the lounge and to distinguish Corbeau from louder, more overstimulating nightlife spaces.",
    process: 'Full menu',
    four: [['jC5N3LSAbz6A4A0o2iMos44fDM.png',1440,1922],['YFFD62Q74NHQHZsQT6dY7c4St2g.png',2032,1520],['ZEfY8l2KCGs3EGNvBQByqnGmBDo.png',4000,3000],['RVii4LOMkVWDYcJTV2o7X3rtEM.png',3659,3254]],
    two:  [['A5KqjHA2DelDENFcqqUuaCvC7v8.jpg',2928,3516],['mMJUascu7zbrYJjGQR5zEqJqo.jpg',2839,3435]],
    strip:[['BgD0LQn6a71vKMzEhAIZtxDxFWI.jpg',3024,4032],['FGV5ECMxNvtObdDtYZHEMJLK1o.jpg',3024,4032],['K4F3uFqgUp94ykxuJXVDQKr8M.jpg',3024,4032],['mMJUascu7zbrYJjGQR5zEqJqo.jpg',2839,3435],['dQgF7oBZsTZAi9eo9nVcjUZI3bE.jpg',3024,4032]],
  },
}
ORDER = P.keys
LOCAL_THUMB = P.map { |slug, p| [p[:thumb], slug] }.to_h          # images/x.jpg => slug (homepage used local copies)
P.each_value { |p| p[:thumb] = img(*p[:four][0], 1024)[:url] }    # project thumbnails now load from Framer, like the galleries
# the photo for the big box at the top of a work page: the widest picture from that project
# The preview Framer shows for each project on the homepage (3 are videos). Used on the homepage, in "More works" and at the top of work pages.
ASSETS = 'https://framerusercontent.com/assets/'
PREVIEW = {
  'noko-blind-box'          => [:video, 'Rrg2qJAJHJRopyiIjcKx4pVZ3Ik.mp4', 1920, 1080],
  'beyond-the-trails'       => [:img, 'DZmC0t4OYP21Zn4DN8l0dzW8.jpg', 3000, 2000],
  'solis'                   => [:video, 'mvYza2nC32CUGuQwNNQlFFz6rk.mp4', 1920, 1080],
  'atelier-co'              => [:img, 'znXA7V9IoNEE2ITK3fjLTN8prs.png', 1497, 1089],
  'mind-motion'             => [:img, '0sZoU4Ke1XH732egCRi9G3xR8g.jpg', 4000, 3000],
  'framed-together'         => [:img, 'ESk5wRPZ5dlmidwPPnPVawuwemE.png', 5000, 3335],
  'collective-moments'      => [:video, 'WghI96voPXWWEbDOpue8WxsqISc.mp4', 1000, 1000],
  'corbeau-mocktail-lounge' => [:img, 'ZEfY8l2KCGs3EGNvBQByqnGmBDo.png', 4000, 3000],   # the store sign (Jess's pick; Framer used the pomegranates)
}
def video_tag(id) %(<video src="#{ASSETS}#{id}" muted loop playsinline preload="none" data-auto aria-hidden="true"></video>) end
# a picture box showing the project's preview: still image as the background (also used by the homepage cursor trail), video on top when there is one
def preview_shot(slug, cls = 'shot', max = 1024)
  kind, id, w, h = PREVIEW[slug]
  r = w.to_f / h
  shape = cls.include?('hero-media') && r > LANDSCAPE ? "; aspect-ratio:#{format('%.3f', r)}; height:auto" : ''   # landscape top picture: its own shape, not cropped
  if kind == :video
    %(<div class="#{cls}" style="--img:url('#{P[slug][:thumb]}')#{shape}">#{video_tag(id)}</div>)
  else
    %(<div class="#{cls}" style="--img:url('#{img(id, w, h, max)[:url]}')#{shape}"></div>)
  end
end

# Videos play only while on screen, so the page doesn't download all of them at once
VIDEO_JS = <<~H
  <style>.shot > video { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; display: block; }</style>
  <script>
  (function () {
    var vids = document.querySelectorAll('video[data-auto]');
    if (!vids.length) return;
    var still = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        var v = e.target; v._on = e.isIntersecting;
        if (e.isIntersecting) { if (v.preload === 'none') v.preload = 'auto'; if (!still) { var p = v.play(); if (p) p.catch(function () {}); } }
        else v.pause();
      });
    }, { rootMargin: '200px' });
    function go(v) { if (v._on && v.paused && !still) { var p = v.play(); if (p) p.catch(function () {}); } }
    [].forEach.call(vids, function (v) { io.observe(v); v.addEventListener('canplay', function () { go(v); }); });
    setInterval(function () { [].forEach.call(vids, go); }, 2000);   // in case the browser paused one that is on screen
  })();
  </script>
H
def hero_img(p) img(*(p[:four] + p[:two]).max_by { |_, w, h| w.to_f / h })[:url] end

def esc(s)
  s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
end
# keep the last two words together so a single word is never left alone on the last line
def nowidow(s)
  s.sub(/ (\S+)\z/, '&nbsp;\1')
end
def paras(text, extra = '')
  text.split(/ {2,}/).map { |t| %(<p class="body-copy#{extra}">#{nowidow(esc(t.strip))}</p>) }
end

def wordmark(title)
  chars = title.chars.map { |c| %(<span class="ch">#{c == ' ' ? '&nbsp;' : esc(c)}</span>) }.join
  %(<h1 class="wmbox" aria-label="#{esc(title)}"><span class="wm" aria-hidden="true">#{chars}<i class="bl"></i></span></h1>)
end

# two pictures side by side, cropped to the same shape so they line up
def pair(a, b, ind = '    ')
  x, y = img(*a), img(*b)
  ar = format('%.3f', Math.sqrt(x[:r] * y[:r]))
  [x, y].map { |i| %(#{ind}  <div class="shot" style="--img:url('#{i[:url]}'); aspect-ratio:#{ar}"></div>) }
    .then { |s| "#{ind}<div class=\"g two\">\n#{s.join("\n")}\n#{ind}</div>" }
end

# Gallery rows, in the Framer order. A landscape picture (wider than 1.25:1) gets a full-width row at its own shape.
# Other pictures go two to a row, sized so both show uncropped at the same height; a leftover one gets its own row.
LANDSCAPE = 1.25
def shot_nat(i) %(<div class="shot" style="--img:url('#{i[:url]}'); aspect-ratio:#{format('%.3f', i[:r])}; --r:#{format('%.3f', i[:r])}"></div>) end
def rows(list, ind = '    ')
  out, buf = [], []
  flush = lambda do
    if buf.size == 2 then out << "#{ind}<div class=\"g nat\">\n#{ind}  #{shot_nat(buf[0])}\n#{ind}  #{shot_nat(buf[1])}\n#{ind}</div>"
    elsif buf.size == 1 then out << "#{ind}<div class=\"g one#{buf[0][:r] > LANDSCAPE ? '' : ' solo'}\">\n#{ind}  #{shot_nat(buf[0])}\n#{ind}</div>"
    end
    buf.clear
  end
  list.each do |a|
    i = img(*a)
    if i[:r] > LANDSCAPE then flush.call; buf << i; flush.call
    else buf << i; flush.call if buf.size == 2
    end
  end
  flush.call
  out.join("\n")
end

# The four pictures: a 2 x 2 grid. Each pair sits at one height, both pictures uncropped.
def grid4(list, ind = '    ')
  list.each_slice(2).map do |a, b|
    x, y = img(*a), img(*b)
    "#{ind}<div class=\"g nat\">\n#{ind}  #{shot_nat(x)}\n#{ind}  #{shot_nat(y)}\n#{ind}</div>"
  end.join("\n")
end
# The last two pictures: each gets its own full-width row at its own shape (a squarer one is capped at one screen tall)
def singles(list, ind = '    ')
  list.map do |a|
    i = img(*a)
    "#{ind}<div class=\"g one#{i[:r] > LANDSCAPE ? '' : ' solo'}\">\n#{ind}  #{shot_nat(i)}\n#{ind}</div>"
  end.join("\n")
end

def strip(list)
  ims = list.map { |a| img(*a, 1200) }
  width = ims.sum { |i| 32 * i[:r] + 1 }            # in vw, at the strip's height
  reps = (160 / width).ceil                          # enough copies that the strip never shows a gap while looping
  half = ims * reps
  dur = (width * reps * 0.9).round                   # same drifting speed on every page
  shots = (half * 2).each_with_index.map do |i, n|
    hidden = n >= half.size ? ' aria-hidden="true"' : ''
    %(          <div class="shot"#{hidden} style="--img:url('#{i[:url]}'); aspect-ratio:#{format('%.3f', i[:r])}"></div>)
  end
  [dur, shots.join("\n")]
end

def more(slug)
  others = ORDER.reject { |s| s == slug }.first(3)   # the Framer site shows the first three other projects
  cards = others.map do |s|
    p = P[s]
    tags = p[:tags].map { |t| "<span>#{esc(t)}</span>" }.join
    <<~H.chomp
      <a class="work" href="#{s}.html">
        #{preview_shot(s)}
        <span class="t">#{esc(p[:short] || p[:title])}</span>
        <span class="tags">#{tags}</span>
      </a>
    H
  end
  cards.join("\n").gsub(/^/, '      ')
end

ORDER.each do |slug|
  p = P[slug]
  pill = p[:link] ? %(\n      <a class="pill" href="#{esc(p[:link])}" target="_blank" rel="noopener"><span>Link</span><span aria-hidden="true">&rarr;</span></a>) : ''
  title_tag = "#{p[:short] || p[:title]} | Okjess"
  page_head = head.sub(%r{<title>.*?</title>}, "<title>#{esc(title_tag)}</title>")
                  .sub(/(<meta property="og:title" content=")[^"]*/, "\\1#{esc(title_tag)}")
  html = <<~HTML
    #{page_head.rstrip}
    #{EXTRA_CSS.rstrip}
    #{LIGHTBOX_CSS.rstrip}
    </style>
    </head>
    <body>

    #{header}

    <main id="top">
      <!-- Picture/video box in the white space, with the title along the bottom of the first screen -->
      <section class="hero">
        #{wordmark(p[:title])}
        <!-- Placeholder for an image or video: replace the contents with <img src="..."> or <video src="..." autoplay muted loop playsinline></video> -->
        #{preview_shot(slug, 'hero-media shot arrow-zone', 2048)}
      </section>

      <section class="intro ident" data-reveal>
        <div class="lab fade">About</div>
        <div class="idesc fade">
          #{paras(p[:about]).join("\n      ")}#{pill}
        </div>
      </section>

      <!-- Big pictures: two across, both cropped to the same shape so they line up -->
      <div class="arrow-zone prow">
    #{grid4(p[:four])}

        <div class="ident" data-reveal>
          <div class="lab fade">#{p[:lab2]}</div>
          <div class="fade">
            #{paras(p[:ident]).join("\n        ")}
          </div>
        </div>

    #{singles(p[:two])}

        <div class="whead"><span>More works</span><a href="index.html#works">See all</a></div>
        <div class="g more">
    #{more(slug)}
        </div>
      </div>
    </main>

    #{LIGHTBOX_HTML}

    #{tail}
  HTML
  File.write(File.join(SITE, "#{slug}.html"), arrows(html))
  puts "#{slug}.html  #{html.bytesize / 1024} KB"
end

# ===== Agency + Client Work: one page of floating tiles (not clickable). Hover enlarges a tile and shows its title + description =====
# [left %, top vw, width vw, aspect ratio (w/h), title, description]   Swap the placeholder text, and set a picture with --img in the style when ready.
LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
TILES = [
  [ 6,   4, 22, 4.0/5, 'Project One'],
  [40,  14, 16, 1.0,   'Project Two'],
  [66,   2, 26, 3.0/2, 'Project Three'],
  [62,  34, 14, 3.0/4, 'Project Four'],
  [14,  44, 30, 16.0/9,'Project Five'],
  [48,  58, 20, 1.0,   'Project Six'],
  [78,  62, 16, 4.0/5, 'Project Seven'],
  [ 4,  78, 18, 3.0/4, 'Project Eight'],
  [32,  86, 24, 4.0/3, 'Project Nine'],
  [64,  94, 28, 3.0/2, 'Project Ten'],
  [12, 114, 20, 1.0,   'Project Eleven'],
  [44, 120, 14, 4.0/5, 'Project Twelve'],
  [68, 128, 22, 4.0/3, 'Project Thirteen'],
]
TONES = %w[#c4c4c4 #bdbdbd #c9c9c9 #b8b8b8]
field_h = TILES.map { |l, t, w, ar| t + w / ar }.max + 12

ACW_CSS = <<CSS

  /* ===== Agency + Client Work: floating tiles ===== */
  .field { position: relative; transition: height .6s cubic-bezier(.2, .7, .2, 1); height: #{format('%.1f', field_h)}vw; margin: 4vw 0 8vw; }
  .ft { position: absolute; left: var(--l); top: var(--t); width: var(--w); z-index: 1;
        animation: drift var(--dur) ease-in-out var(--del) infinite alternate; transition: opacity .5s ease, transform .6s cubic-bezier(.2, .7, .2, 1); }
  .ft:hover { z-index: 5; animation-play-state: paused; }
  .ft .pic { aspect-ratio: var(--ar); background: var(--tone) center / cover no-repeat; display: grid; place-items: center;
             transform-origin: var(--ox) 50%; transition: transform .7s cubic-bezier(.2, .7, .2, 1); }
  .ft .pic > span { font-family: var(--mono); font-size: 11px; letter-spacing: .04em; text-transform: uppercase; color: rgba(0, 0, 0, .4); }
  .ft:hover .pic { transform: scale(1.45); }
  .ft .cap { position: absolute; left: calc(var(--w) * var(--cx)); top: calc(100% + var(--h) * .225 * var(--cy) + 14px); width: max(calc(var(--w) * 1.45), 260px);
             opacity: 0; transform: translateY(-6px); transition: opacity .35s ease, transform .5s cubic-bezier(.2, .7, .2, 1); pointer-events: none;
             background: var(--bg); padding: 6px 0; }
  .ft:hover .cap { opacity: 1; transform: none; transition-delay: .15s; }
  .ft .cap b { display: block; font-family: var(--label); font-weight: 500; text-transform: uppercase; font-size: 14px; color: var(--ink); }
  .ft .cap p { margin-top: 4px; font-family: var(--mono); font-size: 12px; line-height: 1.5; color: var(--fg); }
  .field:has(.ft:hover) .ft:not(:hover) { opacity: .35; }
  @keyframes drift { from { translate: 0 0; } to { translate: var(--dx) var(--dy); } }
  @media (prefers-reduced-motion: reduce) { .ft { animation: none; } }
  @media (max-width: 760px) {
    .field { height: auto; display: flex; flex-direction: column; gap: 48px; padding: 0 var(--pad); }
    .ft { position: relative; left: auto; top: auto; width: 72%; animation: none; }
    .ft:nth-child(even) { align-self: flex-end; width: 58%; }
    .ft:hover .pic { transform: none; }
    .ft .cap { position: static; opacity: 1; transform: none; width: auto; margin-top: 10px; }
  }
CSS

tiles = TILES.each_with_index.map do |(l, t, w, ar, title, desc), i|
  right = l + w / 2 > 50                                       # captions on right-hand tiles line up with the tile's right edge
  ox = l < 12 ? '0%' : (l + w > 88 ? '100%' : '50%')           # tiles near an edge grow inward so they stay on screen
  style = format('--l:%d%%; --t:%gvw; --w:%gvw; --h:%.2fvw; --ar:%.3f; --tone:%s; --ox:%s; --cx:%s; --cy:1; --dur:%ds; --del:-%ds; --dx:%dpx; --dy:%dpx',
                 l, t, w, w / ar, ar, TONES[i % 4], ox, {"0%" => "0", "50%" => "-.225", "100%" => "-.45"}[ox], 6 + (i * 7) % 5, (i * 3) % 7, [-8, 6, -5, 9][i % 4], [-14, 12, -10, 16][(i + 1) % 4])
  <<~H.chomp
        <div class="ft#{right ? ' r' : ''}" style="#{style}">
          <div class="pic"><span>Image</span></div>
          <div class="cap"><b>#{esc(title)}</b><p>#{esc(desc || LOREM)}</p></div>
        </div>
  H
end.join("\n")

acw_title = 'Agency + Client Work | Okjess'
acw_head = head.sub(%r{<title>.*?</title>}, "<title>#{esc(acw_title)}</title>")
               .sub(/(<meta property="og:title" content=")[^"]*/, "\\1#{esc(acw_title)}")
acw = <<~HTML
  #{acw_head.rstrip}
  #{EXTRA_CSS.rstrip}
  #{ACW_CSS.rstrip}
  </style>
  </head>
  <body>

  #{header}

  <main id="top">
    <section class="hero">
      #{wordmark('Agency + Client Work')}
    </section>

    <!-- Floating tiles: positions and sizes are set in TILES in _build/build.rb -->
    <div class="field">
  #{tiles}
    </div>
    <script>
    // Hover push: tiles keep their spots; when one is hovered, any tile in the way of its enlarged picture
    // or caption slides down (and anything that then bumps into, too). Everything slides back on leave.
    (function () {
      var field = document.querySelector('.field');
      var tiles = [].slice.call(field.querySelectorAll('.ft'));
      var M = 28, S = 1.45;                          // breathing room (also covers the gentle drift); hover scale
      var top = [], baseH = 0;
      var phone = window.matchMedia('(max-width: 760px)');
      function box(i, dy) { var t = tiles[i], p = t.firstElementChild, y = top[i] + (dy || 0); return { l: t.offsetLeft, r: t.offsetLeft + p.offsetWidth, t: y, b: y + p.offsetHeight }; }
      function hit(a, b) { return a.l < b.r + M && a.r > b.l - M && a.t < b.b + M && a.b > b.t - M; }
      function big(i) {                              // the hovered picture at full size, plus its caption
        var t = tiles[i], p = t.firstElementChild, c = t.querySelector('.cap'), a = box(i);
        var w = p.offsetWidth, h = p.offsetHeight, ox = getComputedStyle(p).transformOrigin.split(' ')[0];
        var o = parseFloat(ox) / w || 0, gw = w * (S - 1), gh = h * (S - 1) / 2;
        var cl = t.offsetLeft + c.offsetLeft;
        return { l: Math.min(a.l - gw * o, cl), r: Math.max(a.r + gw * (1 - o), cl + c.offsetWidth), t: a.t - gh, b: top[i] + c.offsetTop + c.offsetHeight };
      }
      function setOff(off) {
        var bottom = baseH;
        tiles.forEach(function (t, i) { t.style.transform = off[i] ? 'translateY(' + off[i] + 'px)' : ''; bottom = Math.max(bottom, box(i, off[i]).b + M * 2); });
        field.style.height = bottom + 'px';
      }
      function base() {                              // starting layout: only make sure no two pictures touch
        tiles.forEach(function (t) { t.style.top = ''; t.style.transform = ''; });
        field.style.height = '';
        if (phone.matches) return;
        top = tiles.map(function (t) { return t.offsetTop; });
        for (var pass = 0, moved = true; moved && pass < 60; pass++) {
          moved = false;
          for (var i = 0; i < tiles.length; i++) for (var j = 0; j < tiles.length; j++)
            if (i !== j && top[j] >= top[i] && hit(box(i), box(j))) { top[j] = box(i).b + M + 1; moved = true; }
        }
        baseH = field.offsetHeight;
        tiles.forEach(function (t, i) { t.style.top = top[i] + 'px'; baseH = Math.max(baseH, box(i).b + M * 2); });
        field.style.height = baseH + 'px';
      }
      function hover(i) {
        if (phone.matches) return;
        var off = tiles.map(function () { return 0; }), z = big(i);
        for (var j = 0; j < tiles.length; j++) if (j !== i && hit(z, box(j))) off[j] = z.b + M + 1 - top[j];
        for (var pass = 0, moved = true; moved && pass < 60; pass++) {   // pushed tiles push whatever they land on
          moved = false;
          for (var a = 0; a < tiles.length; a++) for (var b = 0; b < tiles.length; b++) {
            if (a === b || a === i || b === i) continue;
            var A = box(a, off[a]), B = box(b, off[b]);
            if (B.t >= A.t && hit(A, B)) { off[b] = A.b + M + 1 - top[b]; moved = true; }
          }
        }
        setOff(off);
      }
      var leaveT;
      tiles.forEach(function (t, i) {
        t.addEventListener('mouseenter', function () { clearTimeout(leaveT); hover(i); });
        t.addEventListener('mouseleave', function () { leaveT = setTimeout(function () { setOff(tiles.map(function () { return 0; })); }, 60); });
      });
      var timer;
      window.addEventListener('resize', function () { clearTimeout(timer); timer = setTimeout(base, 150); });
      (document.fonts ? document.fonts.ready : Promise.resolve()).then(base);
      base();
    })();
    </script>
  </main>

  #{tail}
HTML
File.write(File.join(SITE, 'agency-client-work.html'), arrows(acw))
puts "agency-client-work.html  #{acw.bytesize / 1024} KB"

# Homepage hover trail: only the animated projects, playing live (replaces the trail's image list and spawn step)
TRAIL_ITEMS_JS = File.read(File.join(__dir__, 'trail_items.js'), encoding: 'UTF-8')
def trail_videos(home)
  a = home.index("    // The images and titles come from the Selected Works list below") or abort 'trail items'
  b = home.index("    var ratios = ", a) or abort 'trail ratios'
  home = home[0...a] + TRAIL_ITEMS_JS.sub("    items.forEach(master);                           // warm up all three as soon as the trail is first used (see below)\n", '') + home[b..-1]
  spawn_old = "      el.style.setProperty('--img', it.loaded ? it.img : 'var(--ph)');   // placeholder picture until the real image exists\n"
  spawn_new = "      el.style.setProperty('--img', it.img);     // still picture underneath until the video frame is ready\n" \
              "      var c = document.createElement('canvas'); c.style.cssText = 'position:absolute;inset:0;width:100%;height:100%;display:block';\n" \
              "      el.appendChild(c); master(it);\n"
  home.sub!(spawn_old, spawn_new) or abort 'spawn'
  size_old = "      trail.appendChild(el);        // newest goes on top of the pile\n"
  size_new = "      trail.appendChild(el);        // newest goes on top of the pile\n" \
             "      var dpr = Math.min(2, window.devicePixelRatio || 1); c.width = Math.round(el.offsetWidth * dpr); c.height = Math.round(el.offsetHeight * dpr);\n" \
             "      painting.push({ c: c, it: it }); if (painting.length === 1) requestAnimationFrame(paint);\n"
  home.sub!(size_old, size_new) or abort 'size'
  # smaller tiles that appear more often
  [["    var GAP  = 120;", "    var GAP  = 55; "],
   ["    var MAX  = 6;  ", "    var MAX  = 12; "],
   ["    var STAY = 900;", "    var STAY = 700;"],
   ["position: absolute; width: clamp(120px, 14vw, 280px);", "position: absolute; width: clamp(70px, 8vw, 160px);"]].each do |a, b|
    home.sub!(a, b) or abort "trail size: #{a}"
  end
  home
end

# Homepage: project pictures load from Framer too (same photos as before)
home = home.gsub(%r{<div class="shot" style="--img:url\('(images/[a-z-]+\.jpg)'\)"></div>}) { LOCAL_THUMB[$1] ? preview_shot(LOCAL_THUMB[$1]) : $& }
# first row: St. Jacobs small on the left, Noko big on the right (the row keeps its small-left / big-right layout; the two swap places)
home = home.sub(%r{(<div class="row">\n)(\s*<a class="work" href="noko-blind-box\.html">.*?</a>\n)(\s*<a class="work" href="beyond-the-trails\.html">.*?</a>\n)}m) { $1 + $3 + $2 }
home = trail_videos(home)
# St. Jacobs and Tipsy Tonic swap places on the homepage
def swap_works(home, a, b)
  re = ->(slug) { %r{<a class="work" href="#{Regexp.escape(slug)}\.html">.*?</a>}m }
  x = home[re[a]] or abort "swap #{a}"
  y = home[re[b]] or abort "swap #{b}"
  home.sub(x, "\u0000A").sub(y, "\u0000B").sub("\u0000A", y).sub("\u0000B", x)
end
home = swap_works(home, 'beyond-the-trails', 'atelier-co')
File.write(File.join(SITE, 'index.html'), arrows(home))
puts "index.html  #{home.bytesize / 1024} KB"
