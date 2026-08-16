(function () {
  var S = window.KitShared, h = S.h;
  window.KitEmpty = function Empty(p) {
    return h('div', null,
      h(S.Header, { title:'Countdown to Magic', right: h('span', { style:{ display:'flex', gap:8 } },
        h(S.Ib, { glyph:'+', loud:true, onClick: function () { p.go('add'); } }),
        h(S.Ib, { glyph:'•••', onClick: function () { p.go('settings'); } })) }),
      S.Col(12, [
        h('div', { key:'e', style:{ background:'var(--surface)', borderRadius:'var(--radius-hero)', padding:'30px 26px' } },
          h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:96, fontWeight:800, letterSpacing:'-6px', lineHeight:.84, color:'var(--text-faint)' } }, '00'),
          h('div', { style:{ marginTop:16, fontFamily:'var(--font-ui)', fontSize:26, fontWeight:700, letterSpacing:'-.6px', lineHeight:1.2, color:'var(--text-primary)' } }, 'Nothing to count down to — yet.'),
          h('div', { style:{ marginTop:10, fontFamily:'var(--font-prose)', fontSize:16, lineHeight:1.55, color:'var(--text-muted)' } }, 'Pick your park and your dates. Everything else fills itself in.'),
          h('div', { onClick: function () { p.go('add'); }, style:{ marginTop:20, background:'var(--text-primary)', color:'var(--bg)', borderRadius:20, padding:18, textAlign:'center', fontFamily:'var(--font-ui)', fontSize:17, fontWeight:600, cursor:'pointer' } }, 'Add a trip')),
        h('div', { key:'stats', style:{ display:'flex', gap:12 } },
          h(S.Tile, { label:'PARKS', value:12, caption:'across 6 resorts' }),
          h(S.Tile, { label:'TIPS', value:'1/day', caption:'once a trip exists' }))
      ]));
  };
})();
