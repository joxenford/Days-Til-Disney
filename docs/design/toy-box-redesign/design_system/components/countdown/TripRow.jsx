import React from 'react';

export function TripRow({ name, meta, park = 'var(--park-tokyo-disneyland)', dimmed = false, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 14,
      background: 'var(--surface)', borderRadius: 'var(--radius-tile)', padding: '16px 18px',
      opacity: dimmed ? .6 : 1, cursor: onClick ? 'pointer' : 'default'
    }}>
      <span style={{ width: 44, height: 44, flex: '0 0 44px', borderRadius: 'var(--radius-chip)', background: park }} />
      <span style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
        <span style={{ fontFamily: 'var(--font-ui)', fontSize: 17, fontWeight: 600, color: 'var(--text-primary)' }}>{name}</span>
        {meta && <span style={{ fontFamily: 'var(--font-prose)', fontSize: 13, color: 'var(--text-muted)' }}>{meta}</span>}
      </span>
      <span style={{ fontFamily: 'var(--font-ui)', fontSize: 20, color: 'var(--text-faint)' }}>›</span>
    </div>
  );
}
