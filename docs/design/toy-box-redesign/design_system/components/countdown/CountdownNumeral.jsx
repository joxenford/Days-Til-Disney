import React from 'react';

const SIZES = {
  hero: { fontSize: 118, letterSpacing: '-7px' },
  screen: { fontSize: 96, letterSpacing: '-6px' },
  milestone: { fontSize: 172, letterSpacing: '-12px' }
};

export function CountdownNumeral({ value, unit, size = 'hero', onPark = true }) {
  const s = SIZES[size];
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 14 }}>
      <span style={{
        ...s, fontFamily: 'var(--font-ui)', fontWeight: 800, lineHeight: .84,
        color: onPark ? '#FFFFFF' : 'var(--text-primary)'
      }}>{value}</span>
      {unit && <span style={{
        fontFamily: 'var(--font-ui)', fontSize: 22, fontWeight: 600,
        color: onPark ? 'rgba(255,255,255,.82)' : 'var(--text-muted)'
      }}>{unit}</span>}
    </div>
  );
}
