import React from 'react';

export function Chip({ children, tone = 'onPark', selected = false }) {
  const tones = {
    onPark: { background: 'rgba(255,255,255,.18)', color: '#FFFFFF' },
    surface: { background: 'var(--surface)', color: 'var(--text-primary)' },
    selected: { background: 'var(--text-primary)', color: 'var(--bg)' }
  };
  const t = selected ? tones.selected : tones[tone];
  return (
    <span style={{
      ...t, borderRadius: 'var(--radius-pill)', padding: '9px 16px',
      fontFamily: 'var(--font-ui)', fontSize: 13, fontWeight: selected ? 700 : 600,
      whiteSpace: 'nowrap'
    }}>{children}</span>
  );
}
