(function () {
  var S = window.KitShared, h = S.h;
  var ROWS = [
    { name:"Pooh's Hunny Hunt", minutes:10, meta:'Open · updated 14:12' },
    { name:'Haunted Mansion', minutes:35, meta:'Lightning Lane 15:40 — 16:40', gold:true },
    { name:'Jungle Cruise', minutes:25, meta:'Lightning Lane 16:05 — 17:05', gold:true },
    { name:'Beauty and the Beast', minutes:90, meta:'Premier Access ¥2,500', gold:true },
    { name:'Splash Mountain', minutes:null, status:'refurbishment' },
    { name:'Star Tours', minutes:15 }
  ];

  window.KitParkDashboard = function ParkDashboard(p) {
    var rows = ROWS.slice();
    if (p.sort === 'Wait') rows.sort(function (a, b) { return (a.minutes == null ? 999 : a.minutes) - (b.minutes == null ? 999 : b.minutes); });
    if (p.sort === 'Name') rows.sort(function (a, b) { return a.name.localeCompare(b.name); });
    var stats = [['38','OPEN'], ['42','AVG MIN'], ['10','SHORTEST']];
    return h('div', null,
      h(S.Header, { title:'Wait times', left: h(S.Ib, { glyph:'‹', onClick: function () { p.go('home'); } }), right: h(S.Ib, { glyph:'↻' }) }),
      S.Col(12, [
        h('div', { key:'parks', style:{ display:'flex', gap:8 } },
          h('span', { style:{ background:'var(--text-primary)', color:'var(--bg)', borderRadius:999, padding:'9px 16px', fontFamily:'var(--font-ui)', fontSize:13, fontWeight:700 } }, 'Tokyo Disneyland'),
          h('span', { style:{ background:'var(--surface)', color:'var(--text-muted)', borderRadius:999, padding:'9px 16px', fontFamily:'var(--font-ui)', fontSize:13, fontWeight:600 } }, 'DisneySea')),
        h('div', { key:'sum', style:{ background:'var(--park-panel-tokyo-disneyland)', borderRadius:'var(--radius-card)', padding:'20px 24px', display:'flex', color:'#fff' } },
          stats.map(function (s) {
            return h('div', { key:s[1], style:{ flex:1 } },
              h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:34, fontWeight:800, letterSpacing:'-1.5px' } }, s[0]),
              h('div', { style:{ fontFamily:'var(--font-prose)', fontSize:12, fontWeight:600, color:'rgba(255,255,255,.8)' } }, s[1]));
          })),
        h('div', { key:'sort', style:{ display:'flex', gap:8 } }, ['Wait','Name','Status'].map(function (s) {
          var on = p.sort === s;
          return h('span', { key:s, onClick: function () { p.setSort(s); }, style:{ background: on ? 'var(--gold)' : 'var(--surface)', color: on ? 'var(--gold-ink)' : 'var(--text-muted)', borderRadius:999, padding:'8px 14px', fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, cursor:'pointer' } }, s);
        })),
        h('div', { key:'rows', style:{ display:'flex', flexDirection:'column', gap:10 } }, rows.map(function (r) {
          return h('div', { key:r.name, style:{ background:'var(--surface)', borderRadius:'var(--radius-tile-sm)', padding:'16px 18px', display:'flex', alignItems:'center', gap:12 } },
            h('span', { style:{ flex:1, display:'flex', flexDirection:'column', gap:2 } },
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:16, fontWeight:600, color: r.status ? 'var(--text-faint)' : 'var(--text-primary)' } }, r.name),
              r.meta ? h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:12, color: r.gold ? 'var(--gold-label)' : 'var(--text-muted)' } }, r.meta) : null),
            h(S.Wait, { minutes:r.minutes, status:r.status }));
        }))
      ]));
  };
})();
