(function () {
  var S = window.KitShared, h = S.h;

  window.KitHome = function Home(p) {
    var trip = p.trip;
    return h('div', null,
      h(S.Header, { title:'Countdown to Magic', right: h('span', { style:{ display:'flex', gap:8 } },
        h(S.Ib, { glyph:'+', loud:true, onClick: function () { p.go('add'); } }),
        h(S.Ib, { glyph:'•••', onClick: function () { p.go('settings'); } })) }),
      S.Col(12, [
        h('div', { key:'hero', onClick: function () { p.go('detail'); }, style:{ cursor:'pointer' } },
          h(S.Panel, { park: trip.park, label: trip.parkName.toUpperCase(), badge:'PRIMARY' },
            h('div', { style:{ marginTop:14, display:'flex', alignItems:'baseline', gap:10 } },
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:118, fontWeight:800, letterSpacing:'-7px', lineHeight:.84 } }, trip.daysOut),
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:22, fontWeight:600, color:'rgba(255,255,255,.82)' } }, 'days')),
            h('div', { style:{ marginTop:16, fontFamily:'var(--font-ui)', fontSize:24, fontWeight:600, letterSpacing:'-.4px', lineHeight:1.2 } }, trip.name),
            h('div', { style:{ marginTop:6, fontFamily:'var(--font-prose)', fontSize:13, fontWeight:500, color:'rgba(255,255,255,.78)' } }, trip.dates + ' · ' + trip.nights + ' nights'))),
        h('div', { key:'stats', style:{ display:'flex', gap:12 } },
          h(S.Tile, { label:'PACKED', value: trip.packed, sub:'/' + trip.total, onClick: function () { p.go('packing'); } },
            h(S.Bar, { value: trip.packed, total: trip.total, tone:'var(--accent-interactive)' })),
          h(S.Tile, { label:'NEXT UP', value:30, caption:'days → one month to go', onClick: function () { p.go('milestone'); } })),
        h('div', { key:'fact', style:{ background:'var(--surface-raised)', borderRadius:'var(--radius-card)', padding:'22px 24px' } },
          h('div', { style:{ display:'flex', alignItems:'center', gap:10 } },
            h('span', { style:{ width:26, height:26, borderRadius:999, background:'var(--gold)' } }),
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.4px', color:'var(--gold-label)' } }, "TODAY'S FACT")),
          h('div', { style:{ marginTop:12, fontFamily:'var(--font-ui)', fontSize:23, fontWeight:700, letterSpacing:'-.4px', lineHeight:1.25, color:'var(--text-primary)' } }, 'Cinderella Castle has no bricks'),
          h('div', { style:{ marginTop:8, fontFamily:'var(--font-prose)', fontSize:15, lineHeight:1.55, color:'var(--text-muted)' } }, 'Fibreglass and steel the whole way up — the top windows are small on purpose so it reads taller.')),
        h('div', { key:'other', onClick: function () { p.go('park'); }, style:{ display:'flex', alignItems:'center', gap:14, background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'16px 18px', cursor:'pointer' } },
          h('span', { style:{ width:44, height:44, flex:'0 0 44px', borderRadius:'var(--radius-chip)', background:'var(--park-panel-tokyo-disneyland)' } }),
          h('span', { style:{ flex:1, display:'flex', flexDirection:'column', gap:2 } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:17, fontWeight:600, color:'var(--text-primary)' } }, 'Tokyo Adventure'),
            h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:13, color:'var(--text-muted)' } }, "Day 3 of 7 — you're there!")),
          h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:20, color:'var(--text-faint)' } }, '›')),
        h('div', { key:'theme', onClick: p.toggleTheme, style:{ textAlign:'center', fontFamily:'var(--font-prose)', fontSize:13, fontWeight:600, color:'var(--text-muted)', padding:'4px 0', cursor:'pointer' } },
          p.theme === 'dark' ? 'Switch to light' : 'Switch to dark')
      ]));
  };
})();
