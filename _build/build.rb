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
def arrows(s) s.gsub(%(<span aria-hidden="true">&rarr;</span>), ARROW_SVG) end
def patch(src)
  PATCHES.reduce(src) { |s, (from, to)| s.include?(from) ? s.sub(from, to) : abort("patch not found: #{from[0, 60]}") }
end

TPL = patch(File.read(File.join(SITE, 'noko-blind-box_1.html')))

# Homepage: same patches, and project links point at the local pages
home = patch(File.read(File.join(SITE, 'index_1.html')))
  .gsub(%r{https://okjess\.com/(beyond-the-trails|solis|atelier-co|mind-motion|framed-together|collective-moments|corbeau-mocktail-lounge)"}, '\1.html"')
File.write(File.join(SITE, 'index.html'), arrows(home))

EXTRA_CSS = <<CSS

  /* ===== Added for the other project pages ===== */
  .body-copy + .body-copy { margin-top: 1.1em; }   /* paragraphs that follow each other get a gap */
CSS

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
        <div class="shot" style="--img:url('#{p[:thumb]}')"></div>
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
    </style>
    </head>
    <body>

    #{header}

    <main id="top">
      <!-- Picture/video box in the white space, with the title along the bottom of the first screen -->
      <section class="hero">
        #{wordmark(p[:title])}
        <!-- Placeholder for an image or video: replace the contents with <img src="..."> or <video src="..." autoplay muted loop playsinline></video> -->
        <div class="hero-media shot arrow-zone"><span>Image or video</span></div>
      </section>

      <section class="intro ident" data-reveal>
        <div class="lab fade">About</div>
        <div class="idesc fade">
          #{paras(p[:about]).join("\n      ")}#{pill}
        </div>
      </section>

      <!-- Big pictures: two across, both cropped to the same shape so they line up -->
      <div class="arrow-zone prow">
    #{pair(p[:four][0], p[:four][1])}
    #{pair(p[:four][2], p[:four][3])}

        <div class="ident" data-reveal>
          <div class="lab fade">#{p[:lab2]}</div>
          <div class="fade">
            #{paras(p[:ident]).join("\n        ")}
          </div>
        </div>

    #{pair(p[:two][0], p[:two][1])}

        <div class="whead"><span>More works</span><a href="index.html#works">See all</a></div>
        <div class="g more">
    #{more(slug)}
        </div>
      </div>
    </main>

    #{tail}
  HTML
  File.write(File.join(SITE, "#{slug}.html"), arrows(html))
  puts "#{slug}.html  #{html.bytesize / 1024} KB"
end
