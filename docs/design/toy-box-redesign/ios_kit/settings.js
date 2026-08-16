(function () {
  var S = window.KitShared, h = S.h;

  window.KitSettings = function Settings(p) {
    var rows = [
      ['Sync trips with iCloud', 'Syncing — last updated just now', true, null],
      ['Milestone notifications', '100 days, one week, and more', p.notifications, function () { p.setNotifications(!p.notifications); }]
    ];
    var about = [['Version','1.0.0 (1)'], ['Privacy policy','›'], ['Support','›']];
    return h('div', null,
      h(S.Header, { title:'Settings', left: h(S.Ib, { glyph:'‹', onClick: function () { p.go('home'); } }), right: h('span', { style:{ width:36 } }) }),
      S.Col(12, [
        h('div', { key:'appearance', style:{ background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'18px 20px' } },
          h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.4px', color:'var(--text-muted)' } }, 'APPEARANCE'),
          h('div', { style:{ marginTop:12, display:'flex', gap:8 } }, ['Light','Dark','System'].map(function (o) {
            var on = p.theme === o;
            return h('span', { key:o, onClick: function () { p.setTheme(o); }, style:{ flex:1, textAlign:'center', padding:'11px 0', borderRadius:'var(--radius-control)', background: on ? 'var(--text-primary)' : 'var(--surface-control)', color: on ? 'var(--bg)' : 'var(--text-muted)', fontFamily:'var(--font-ui)', fontSize:14, fontWeight: on ? 700 : 600, cursor:'pointer' } }, o);
          }))),
        rows.map(function (r) {
          return h('div', { key:r[0], style:{ background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'18px 20px', display:'flex', alignItems:'center', gap:14 } },
            h('span', { style:{ flex:1, display:'flex', flexDirection:'column', gap:2 } },
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:16, fontWeight:600, color:'var(--text-primary)' } }, r[0]),
              h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:13, color:'var(--text-muted)' } }, r[1])),
            h('span', { onClick: r[3] || undefined, style:{ width:50, height:30, flex:'0 0 50px', borderRadius:999, background: r[2] ? 'var(--accent-interactive)' : 'var(--hairline)', position:'relative', cursor: r[3] ? 'pointer' : 'default' } },
              h('span', { style:{ position:'absolute', top:3, left: r[2] ? 23 : 3, width:24, height:24, borderRadius:999, background:'var(--knob)' } })));
        }),
        h('div', { key:'about', style:{ background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'6px 20px' } }, about.map(function (a, i) {
          return h('div', { key:a[0], style:{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 0', borderBottom: i < 2 ? '1px solid var(--hairline)' : 'none' } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:16, color:'var(--text-primary)' } }, a[0]),
            h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:14, color:'var(--text-muted)' } }, a[1]));
        })),
        h('div', { key:'legal', style:{ padding:'4px 6px', fontFamily:'var(--font-prose)', fontSize:13, lineHeight:1.55, color:'var(--text-muted)' } },
          'Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company.')
      ]));
  };
})();
