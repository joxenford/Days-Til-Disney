(function () {
  var S = window.KitShared, h = S.h;
  var TILES = [
    { fill:'var(--park-panel-magic-kingdom)', n:'45', ink:'#fff' },
    { fill:'var(--surface)' },
    { fill:'var(--park-panel-tokyo-disneyland)', n:'7', ink:'#fff' },
    { fill:'var(--surface)' },
    { fill:'var(--gold)', n:'30', ink:'var(--gold-ink)' },
    { fill:'var(--surface)' }
  ];
  window.KitWelcome = function Welcome(p) {
    return h('div', { style:{ height:'100%', display:'flex', flexDirection:'column' } },
      h('div', { style:{ height:10 } }),
      h('div', { style:{ padding:'0 24px' } },
        h('div', { style:{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:10 } }, TILES.map(function (t, i) {
          return h('span', { key:i, style:{ aspectRatio:'1', borderRadius:22, background:t.fill, display:'grid', placeItems:'center', fontFamily:'var(--font-ui)', fontSize:26, fontWeight:800, color:t.ink } }, t.n || '');
        }))),
      h('div', { style:{ padding:'36px 24px 0' } },
        h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:38, fontWeight:800, letterSpacing:'-1.4px', lineHeight:1.08, color:'var(--text-primary)' } }, 'The best part', h('br'), 'starts early.'),
        h('div', { style:{ marginTop:16, fontFamily:'var(--font-prose)', fontSize:17, lineHeight:1.55, color:'var(--text-muted)' } }, "Add your trip and the countdown begins. A fact a day, a packing list that knows your park, and live waits once you're through the gates.")),
      h('div', { style:{ flex:1 } }),
      h('div', { style:{ padding:'0 24px 24px', display:'flex', flexDirection:'column', gap:12 } },
        h('div', { onClick: function () { p.go('add'); }, style:{ background:'var(--text-primary)', color:'var(--bg)', borderRadius:22, padding:20, textAlign:'center', fontFamily:'var(--font-ui)', fontSize:17, fontWeight:700, cursor:'pointer' } }, 'Create your first trip'),
        h('div', { onClick: function () { p.go('empty'); }, style:{ background:'var(--surface)', color:'var(--text-primary)', borderRadius:22, padding:20, textAlign:'center', fontFamily:'var(--font-ui)', fontSize:17, fontWeight:600, cursor:'pointer' } }, "I'll do this later")));
  };
})();
