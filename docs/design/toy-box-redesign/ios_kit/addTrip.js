(function () {
  var S = window.KitShared, h = S.h;
  var PARKS = ['Magic Kingdom', 'EPCOT', 'Hollywood Studios', 'Animal Kingdom'];
  var OTHER = ['Disneyland Resort', 'Tokyo Disney', 'Paris', 'Hong Kong', 'Shanghai'];

  window.KitAddTrip = function AddTrip(p) {
    var picked = p.picked, toggle = p.togglePark, primary = p.primary, setPrimary = p.setPrimary;
    var valid = picked.length > 0;
    return h('div', null,
      h('div', { style:{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'8px 20px 16px' } },
        h('span', { onClick: function () { p.go('home'); }, style:{ fontFamily:'var(--font-ui)', fontSize:16, fontWeight:600, color:'var(--text-muted)', cursor:'pointer' } }, 'Cancel'),
        h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:17, fontWeight:700, color:'var(--text-primary)' } }, 'New trip'),
        h('span', { onClick: valid ? function () { p.go('home'); } : undefined, style:{ fontFamily:'var(--font-ui)', fontSize:16, fontWeight:600, color:'var(--text-primary)', opacity: valid ? 1 : .45, cursor: valid ? 'pointer' : 'default' } }, 'Save')),
      S.Col(12, [
        h('div', { key:'name', style:{ background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:'18px 20px' } },
          h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.2px', color:'var(--text-muted)' } }, 'TRIP NAME'),
          h('div', { style:{ marginTop:8, fontFamily:'var(--font-ui)', fontSize:22, fontWeight:700, letterSpacing:'-.4px', color:'var(--text-primary)' } }, 'Smith Family Magic',
            h('span', { style:{ color:'var(--accent-interactive)' } }, '|'))),
        h('div', { key:'dates', style:{ display:'flex', gap:12 } },
          [['FROM','30 Sep'], ['TO','7 Oct']].map(function (d) {
            return h('div', { key:d[0], style:{ flex:1, background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:'18px 20px' } },
              h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.2px', color:'var(--text-muted)' } }, d[0]),
              h('div', { style:{ marginTop:6, fontFamily:'var(--font-ui)', fontSize:22, fontWeight:700, letterSpacing:'-.5px', color:'var(--text-primary)' } }, d[1]));
          })),
        h('div', { key:'resort', style:{ background:'var(--park-panel-magic-kingdom)', borderRadius:'var(--radius-card)', padding:20, color:'#fff' } },
          h('div', { style:{ display:'flex', alignItems:'center', justifyContent:'space-between' } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:17, fontWeight:700 } }, 'Walt Disney World'),
            h('span', { style:{ background:'rgba(255,255,255,.18)', borderRadius:999, padding:'5px 10px', fontFamily:'var(--font-ui)', fontSize:11, fontWeight:700 } }, 'SELECTED')),
          h('div', { style:{ marginTop:4, fontFamily:'var(--font-prose)', fontSize:13, color:'rgba(255,255,255,.8)' } }, 'Orlando, Florida · 4 parks'),
          h('div', { style:{ marginTop:14, display:'flex', flexDirection:'column', gap:8 } }, PARKS.map(function (name) {
            var on = picked.indexOf(name) > -1;
            return h('div', { key:name, onClick: function () { toggle(name); }, style:{ background: on ? 'rgba(255,255,255,.16)' : 'transparent', border: on ? 'none' : '1.5px solid rgba(255,255,255,.35)', borderRadius:'var(--radius-chip)', padding: on ? '12px 14px' : '10.5px 14px', display:'flex', alignItems:'center', gap:12, cursor:'pointer' } },
              h('span', { style:{ width:20, height:20, flex:'0 0 20px', borderRadius:7, background: on ? '#fff' : 'transparent', border: on ? 'none' : '1.5px solid rgba(255,255,255,.55)', color:'var(--park-magic-kingdom)', display:'grid', placeItems:'center', fontFamily:'var(--font-ui)', fontSize:12, fontWeight:800 } }, on ? '✓' : ''),
              h('span', { style:{ flex:1, fontFamily:'var(--font-ui)', fontSize:15, fontWeight: on ? 600 : 500, color: on ? '#fff' : 'rgba(255,255,255,.85)' } }, name),
              on && picked[0] === name ? h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:11, fontWeight:700, letterSpacing:'.8px', color:'rgba(255,255,255,.8)' } }, 'THEME') : null);
          }))),
        h('div', { key:'other', style:{ display:'flex', gap:10, flexWrap:'wrap' } }, OTHER.map(function (o) {
          return h('span', { key:o, style:{ background:'var(--surface)', borderRadius:999, padding:'10px 16px', fontFamily:'var(--font-ui)', fontSize:14, fontWeight:600, color:'var(--text-primary)' } }, o);
        })),
        h('div', { key:'primary', style:{ background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:'16px 20px', display:'flex', alignItems:'center', gap:14 } },
          h('span', { style:{ flex:1, display:'flex', flexDirection:'column', gap:2 } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:16, fontWeight:600, color:'var(--text-primary)' } }, 'Primary countdown'),
            h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:13, color:'var(--text-muted)' } }, 'Shows big on the home screen')),
          h('span', { onClick: function () { setPrimary(!primary); }, style:{ width:50, height:30, flex:'0 0 50px', borderRadius:999, background: primary ? 'var(--accent-interactive)' : 'var(--hairline)', position:'relative', cursor:'pointer' } },
            h('span', { style:{ position:'absolute', top:3, left: primary ? 23 : 3, width:24, height:24, borderRadius:999, background:'var(--knob)' } })))
      ]));
  };
})();
