(function () {
  var S = window.KitShared, h = S.h;

  window.KitTripDetail = function TripDetail(p) {
    var trip = p.trip;
    var pillBtn = function (t) {
      return h('span', { key:t, style:{ height:36, padding:'0 14px', borderRadius:'var(--radius-control)', background:'var(--surface-control)', color:'var(--text-primary)', display:'grid', placeItems:'center', fontFamily:'var(--font-ui)', fontSize:13, fontWeight:600 } }, t);
    };
    var meta = [['START','30 Sep'], ['END','7 Oct'], ['NIGHTS', String(trip.nights)]];
    var tips = [['30d','Break in the shoes now — ten miles a day is an ordinary Tuesday here.'], ['14d','Check park hours again — they shift close to the date.']];
    return h('div', null,
      h(S.Header, { left: h(S.Ib, { glyph:'‹', onClick: function () { p.go('home'); } }),
        right: h('span', { style:{ display:'flex', gap:8 } }, pillBtn('Share'), pillBtn('Edit')) }),
      S.Col(12, [
        h(S.Panel, { key:'panel', park: trip.park, label: trip.parkName.toUpperCase() },
          h('div', { style:{ marginTop:10, display:'flex', alignItems:'baseline', gap:10 } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:96, fontWeight:800, letterSpacing:'-6px', lineHeight:.84 } }, trip.daysOut),
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:20, fontWeight:600, color:'rgba(255,255,255,.82)' } }, 'days')),
          h('div', { style:{ marginTop:14, fontFamily:'var(--font-ui)', fontSize:22, fontWeight:600, letterSpacing:'-.4px' } }, trip.name),
          h('div', { style:{ marginTop:12, display:'flex', gap:7, flexWrap:'wrap' } }, trip.parks.map(function (pk) {
            return h('span', { key:pk, style:{ background:'rgba(255,255,255,.18)', borderRadius:999, padding:'6px 12px', fontFamily:'var(--font-ui)', fontSize:12, fontWeight:600 } }, pk);
          }))),
        h('div', { key:'meta', style:{ display:'flex', gap:12 } }, meta.map(function (m) {
          return h('div', { key:m[0], style:{ flex:1, background:'var(--surface)', borderRadius:'var(--radius-tile-sm)', padding:'16px 18px' } },
            h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:11, fontWeight:700, letterSpacing:'1.2px', color:'var(--text-muted)' } }, m[0]),
            h('div', { style:{ marginTop:4, fontFamily:'var(--font-ui)', fontSize:20, fontWeight:700, color:'var(--text-primary)' } }, m[1]));
        })),
        h('div', { key:'pack', onClick: function () { p.go('packing'); }, style:{ display:'flex', alignItems:'center', gap:14, background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:'18px 20px', cursor:'pointer' } },
          h('span', { style:{ flex:1 } },
            h('span', { style:{ display:'flex', alignItems:'baseline', justifyContent:'space-between' } },
              h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:17, fontWeight:600, color:'var(--text-primary)' } }, 'Packing list'),
              h('span', { style:{ fontFamily:'var(--font-prose)', fontSize:14, fontWeight:600, color:'var(--text-muted)' } }, trip.packed + ' of ' + trip.total)),
            h(S.Bar, { value: trip.packed, total: trip.total })),
          h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:20, color:'var(--text-faint)' } }, '›')),
        h('div', { key:'notes', style:{ background:'var(--surface-raised)', borderRadius:'var(--radius-tile)', padding:20 } },
          h('div', { style:{ display:'flex', alignItems:'center', justifyContent:'space-between' } },
            h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.4px', color:'var(--text-muted)' } }, 'TRIP NOTES'),
            h('span', { style:{ width:8, height:8, borderRadius:999, background:'var(--gold)' } })),
          h('div', { style:{ marginTop:10, fontFamily:'var(--font-prose)', fontSize:15, lineHeight:1.6, color:'var(--text-primary)' } }, "Be Our Guest 8:10am day two. Grandma's scooter waits at Bay Lake. Rope drop Tron.")),
        h('div', { key:'tips', style:{ background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'18px 20px' } },
          h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.4px', color:'var(--text-muted)' } }, 'TIPS FOR THIS TRIP'),
          tips.map(function (t) {
            return h('div', { key:t[0], style:{ marginTop:12, display:'flex', gap:12, alignItems:'flex-start' } },
              h('span', { style:{ background:'var(--text-primary)', color:'var(--bg)', borderRadius:999, padding:'4px 9px', fontFamily:'var(--font-ui)', fontSize:11, fontWeight:700 } }, t[0]),
              h('span', { style:{ flex:1, fontFamily:'var(--font-prose)', fontSize:14, lineHeight:1.5, color:'var(--text-primary)' } }, t[1]));
          }))
      ]));
  };
})();
