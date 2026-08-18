(function () {
  var S = window.KitShared, h = S.h;
  /* Thresholds are Milestone.all from Core/Models/Milestone.swift. */
  var MILESTONES = [100, 50, 30, 14, 7, 3, 1, 0];

  window.KitMilestone = function Milestone(p) {
    var reached = MILESTONES.filter(function (m) { return p.daysOut <= m; }).length;
    return h('div', { style:{ height:'100%', background:'var(--park-panel-magic-kingdom)', display:'flex', flexDirection:'column', justifyContent:'center', padding:'0 24px', color:'#fff' } },
      h('div', { style:{ fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'2.4px', color:'rgba(255,255,255,.75)' } }, 'MILESTONE · MAGIC KINGDOM'),
      h('div', { style:{ marginTop:16, fontFamily:'var(--font-ui)', fontSize:172, fontWeight:800, letterSpacing:'-12px', lineHeight:.82 } }, '30'),
      h('div', { style:{ marginTop:12, fontFamily:'var(--font-ui)', fontSize:40, fontWeight:800, letterSpacing:'-1.4px', lineHeight:1.08, color:'var(--gold)' } }, 'One month', h('br'), 'to go!'),
      h('div', { style:{ marginTop:16, fontFamily:'var(--font-prose)', fontSize:17, lineHeight:1.55, color:'rgba(255,255,255,.88)' } }, "Time to start packing lists and dining plans. Thirty sleeps and you're through the gates."),
      h('div', { style:{ marginTop:26, display:'flex', gap:8 } }, MILESTONES.map(function (m, i) {
        return h('span', { key:m, style:{ flex:1, height:8, borderRadius:999, background: i < reached ? 'var(--gold)' : 'rgba(255,255,255,.28)' } });
      })),
      h('div', { style:{ marginTop:10, fontFamily:'var(--font-prose)', fontSize:13, fontWeight:600, color:'rgba(255,255,255,.8)' } }, reached + ' of 8 milestones reached'),
      h('div', { style:{ marginTop:30, display:'flex', flexDirection:'column', gap:10 } },
        h('div', { onClick: function () { p.go('home'); }, style:{ background:'var(--bg)', color:'var(--text-primary)', borderRadius:22, padding:19, textAlign:'center', fontFamily:'var(--font-ui)', fontSize:17, fontWeight:700, cursor:'pointer' } }, "Let's go"),
        h('div', { onClick: function () { p.go('home'); }, style:{ border:'1.5px solid rgba(255,255,255,.4)', borderRadius:22, padding:18, textAlign:'center', fontFamily:'var(--font-ui)', fontSize:17, fontWeight:600, cursor:'pointer' } }, 'Share it')));
  };
})();
