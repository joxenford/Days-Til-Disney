(function () {
  var S = window.KitShared, h = S.h;
  window.KitSplash = function Splash(p) {
    return h('div', { style:{ height:'100%', display:'flex', flexDirection:'column', justifyContent:'center', padding:'0 40px' } },
      h('div', { style:{ width:132, height:132, borderRadius:44, background:'var(--park-panel-magic-kingdom)', display:'flex', alignItems:'flex-end', padding:16, boxSizing:'border-box' } },
        h('span', { style:{ fontFamily:'var(--font-ui)', fontSize:64, fontWeight:800, letterSpacing:'-4px', lineHeight:.8, color:'#fff' } }, '45')),
      h('div', { style:{ marginTop:32, fontFamily:'var(--font-ui)', fontSize:44, fontWeight:800, letterSpacing:'-1.6px', lineHeight:1.05, color:'var(--text-primary)' } }, 'Countdown', h('br'), 'to Magic'),
      h('div', { style:{ marginTop:14, fontFamily:'var(--font-prose)', fontSize:16, color:'var(--text-muted)' } }, 'Getting your trips…'),
      h('div', { style:{ marginTop:28, height:8, borderRadius:999, background:'var(--hairline)', overflow:'hidden' } },
        h('div', { style:{ width:'62%', height:8, borderRadius:999, background:'var(--accent-interactive)' } })),
      h('div', { onClick: function () { p.go('welcome'); }, style:{ marginTop:28, textAlign:'center', fontFamily:'var(--font-prose)', fontSize:13, fontWeight:600, color:'var(--text-faint)', cursor:'pointer' } }, 'Skip →'));
  };
})();
