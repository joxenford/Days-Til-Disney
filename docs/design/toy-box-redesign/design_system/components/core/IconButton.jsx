import React from 'react';

export function IconButton({ glyph, tone = 'quiet', label, onClick }) {
  const tones = {
    loud: { background: 'var(--text-primary)', color: 'var(--bg)' },
    quiet: { background: 'var(--surface-control)', color: 'var(--text-primary)' }
  };
  return (
    <button onClick={onClick} aria-label={label} style={{
      ...tones[tone],
      width: 36, height: 36, border: 'none',
      borderRadius: 'var(--radius-control)',
      display: 'grid', placeItems: 'center',
      fontFamily: 'var(--font-ui)', fontSize: glyph.length > 1 ? 14 : 20,
      fontWeight: glyph.length > 1 ? 700 : 600, cursor: 'pointer'
    }}>{glyph}</button>
  );
}
