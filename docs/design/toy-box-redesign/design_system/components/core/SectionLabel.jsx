import React from 'react';

export function SectionLabel({ children, loose = false, tone = 'muted' }) {
  const colors = { muted: 'var(--text-muted)', gold: 'var(--gold-label)', onPark: 'rgba(255,255,255,.78)' };
  return (
    <span style={{
      fontFamily: 'var(--font-ui)', fontSize: 12, fontWeight: 700,
      letterSpacing: loose ? 'var(--tracking-label-loose)' : 'var(--tracking-label)',
      textTransform: 'uppercase', color: colors[tone]
    }}>{children}</span>
  );
}
