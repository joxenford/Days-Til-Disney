(function () {
  var S = window.KitShared, h = S.h;
  var SECTIONS = [
    { name:'ESSENTIALS', items:['Sunscreen (SPF 50+)','Comfortable walking shoes','Portable phone charger','Reusable water bottle'] },
    { name:'PARK DAY', items:['Park bag / day pack','Poncho or rain jacket','Themed ears / headband'] }
  ];
  window.KitSections = SECTIONS;

  window.KitPackingList = function PackingList(p) {
    var total = SECTIONS.reduce(function (n, s) { return n + s.items.length; }, 0);
    var done = 0;
    SECTIONS.forEach(function (s) { s.items.forEach(function (i) { if (p.checked[i]) done++; }); });
    return h('div', null,
      h(S.Header, { title:'Packing list', left: h(S.Ib, { glyph:'‹', onClick: function () { p.go('detail'); } }), right: h(S.Ib, { glyph:'+', loud:true }) }),
      S.Col(12, [
        h('div', { key:'sum', style:{ background: p.trip.park, borderRadius:'var(--radius-card)', padding:'22px 24px', color:'#fff' } },
          h('div', { style:{ display:'flex', alignItems:'flex-end', justifyContent:'space-between' } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:64, fontWeight:800, letterSpacing:'-4px', lineHeight:.86 } },
              done, h('span', { style:{ fontSize:28, color:'rgba(255,255,255,.7)' } }, '/' + total)),
            h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:14, fontWeight:600, color:'rgba(255,255,255,.8)', paddingBottom:6 } }, (total - done) + ' to go')),
          h(S.Bar, { value: done, total: total, h:10, tone:'var(--gold)', track:'rgba(255,255,255,.22)' })),
        SECTIONS.map(function (s) {
          var sDone = s.items.filter(function (i) { return p.checked[i]; }).length;
          return h('div', { key:s.name, style:{ background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:'18px 20px' } },
            h('div', { style:{ display:'flex', alignItems:'center', justifyContent:'space-between' } },
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.4px', color:'var(--text-muted)' } }, s.name),
              h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:13, fontWeight:600, color:'var(--text-muted)' } }, sDone + '/' + s.items.length)),
            h('div', { style:{ marginTop:12, display:'flex', flexDirection:'column', gap:12 } }, s.items.map(function (i) {
              var on = !!p.checked[i];
              return h('div', { key:i, onClick: function () { p.toggle(i); }, style:{ display:'flex', alignItems:'center', gap:12, cursor:'pointer' } },
                h('span', { style:{ width:24, height:24, flex:'0 0 24px', borderRadius:'var(--radius-check)', background: on ? 'var(--accent-interactive)' : 'transparent', border: on ? 'none' : '2px solid var(--hairline)', color:'var(--on-accent)', display:'grid', placeItems:'center', fontSize:12, fontWeight:800 } }, on ? '✓' : ''),
                h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:16, color: on ? 'var(--text-done)' : 'var(--text-primary)', textDecoration: on ? 'line-through' : 'none' } }, i));
            })));
        })
      ]));
  };
})();
