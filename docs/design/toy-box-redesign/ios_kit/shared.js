/* Plain-JS primitives for the kit (no build step, no Babel).
   Mirrors components/core + components/countdown. */
var h = React.createElement;

function Header(p) {
  return h('div', { style: { display:'flex', alignItems:'center', justifyContent:'space-between', padding:'8px 20px 18px', gap:12 } },
    p.left || null,
    h('div', { style: { flex:1, minWidth:0, whiteSpace:'nowrap', fontFamily:'var(--font-ui)', fontSize: p.title === 'Countdown to Magic' ? 19 : 17, fontWeight:700, letterSpacing:'-.3px', color:'var(--text-primary)', textAlign: p.left ? 'center' : 'left' } }, p.title || ''),
    p.right || null);
}
function Ib(p) {
  return h('span', { onClick: p.onClick, style: { width:36, height:36, flex:'0 0 36px', borderRadius:'var(--radius-control)', background: p.loud ? 'var(--text-primary)' : 'var(--surface-control)', color: p.loud ? 'var(--bg)' : 'var(--text-primary)', display:'grid', placeItems:'center', fontFamily:'var(--font-ui)', fontSize: p.glyph.length > 1 ? 14 : 20, fontWeight: p.glyph.length > 1 ? 700 : 600, cursor:'pointer' } }, p.glyph);
}
function Panel(p) {
  return h('div', { style: { background: p.park, borderRadius: p.radius || 'var(--radius-hero)', padding:'24px 26px 26px', color:'#fff' } },
    h('div', { style: { display:'flex', alignItems:'center', justifyContent:'space-between', gap:12 } },
      h('span', { style: { fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.6px', color:'rgba(255,255,255,.78)' } }, p.label),
      p.badge ? h('span', { style: { background:'rgba(255,255,255,.18)', borderRadius:999, padding:'5px 11px', fontFamily:'var(--font-ui)', fontSize:11, fontWeight:700, letterSpacing:'.8px' } }, p.badge) : null),
    p.children);
}
function Tile(p) {
  return h('div', { onClick: p.onClick, style: { flex:1, background:'var(--surface)', borderRadius:'var(--radius-tile)', padding:'18px 20px', cursor: p.onClick ? 'pointer' : 'default' } },
    h('div', { style: { fontFamily:'var(--font-ui)', fontSize:12, fontWeight:700, letterSpacing:'1.2px', color:'var(--text-muted)' } }, p.label),
    h('div', { style: { marginTop:8, fontFamily:'var(--font-ui)', fontSize:40, fontWeight:800, letterSpacing:'-2px', lineHeight:1, color:'var(--text-primary)' } },
      p.value, p.sub ? h('span', { style: { fontSize:20, color:'var(--text-faint)' } }, p.sub) : null),
    p.caption ? h('div', { style: { marginTop:8, fontFamily:'var(--font-prose)', fontSize:13, fontWeight:500, color:'var(--text-muted)' } }, p.caption) : null,
    p.children);
}
function Bar(p) {
  var height = p.h || 8;
  var pct = p.total ? Math.round(p.value / p.total * 100) : 0;
  return h('div', { style: { marginTop: p.flush ? 0 : 12, height: height, borderRadius:999, background: p.track || 'var(--hairline)', overflow:'hidden' } },
    h('div', { style: { width: pct + '%', height: height, borderRadius:999, background: p.tone || 'var(--accent)' } }));
}
function Wait(p) {
  if (p.status && p.status !== 'operating') {
    return h('span', { style: { background:'var(--surface-raised)', color:'var(--text-muted)', borderRadius:999, padding:'6px 11px', fontFamily:'var(--font-ui)', fontSize:11, fontWeight:700, letterSpacing:'.6px' } },
      p.status === 'refurbishment' ? 'REFURB' : p.status.toUpperCase());
  }
  var m = p.minutes;
  var tone = (m == null || m < 20) ? 'var(--wait-short)' : m < 45 ? 'var(--wait-mid)' : 'var(--wait-long)';
  return h('span', { style: { color: tone, background:'rgba(127,127,127,.10)', borderRadius:999, padding:'4px 12px', fontFamily:'var(--font-ui)', fontSize:19, fontWeight:700, whiteSpace:'nowrap' } },
    m == null ? 'Walk-on' : m + ' min');
}
function Col(gap, children) {
  return h('div', { style: { padding:'0 20px', display:'flex', flexDirection:'column', gap: gap } }, children);
}
window.KitShared = { h: h, Header: Header, Ib: Ib, Panel: Panel, Tile: Tile, Bar: Bar, Wait: Wait, Col: Col };
