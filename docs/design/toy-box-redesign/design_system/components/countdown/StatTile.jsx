import React from 'react';

export function StatTile({ label, value, sub, caption, children }) {
  return (
    <div style={{ flex: 1, background: 'var(--surface)', borderRadius: 'var(--radius-tile)', padding: '18px 20px' }}>
      <div style={{ fontFamily: 'var(--font-ui)', fontSize: 12, fontWeight: 700, letterSpacing: '1.2px', textTransform: 'uppercase', color: 'var(--text-muted)' }}>{label}</div>
      <div style={{ marginTop: 8, fontFamily: 'var(--font-ui)', fontSize: 40, fontWeight: 800, letterSpacing: '-2px', lineHeight: 1, color: 'var(--text-primary)' }}>
        {value}{sub && <span style={{ fontSize: 20, color: 'var(--text-faint)' }}>{sub}</span>}
      </div>
      {caption && <div style={{ marginTop: 8, fontFamily: 'var(--font-prose)', fontSize: 13, fontWeight: 500, color: 'var(--text-muted)' }}>{caption}</div>}
      {children}
    </div>
  );
}
