import React from 'react';

export function ParkPanel({ park = 'var(--park-panel-magic-kingdom)', label, badge, children, compact = false }) {
  return (
    <section style={{
      background: park, borderRadius: 'var(--radius-hero)',
      padding: compact ? '22px 26px 24px' : '24px 26px 26px', color: '#FFFFFF'
    }}>
      {(label || badge) && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
          {label && <span style={{ fontFamily: 'var(--font-ui)', fontSize: 12, fontWeight: 700, letterSpacing: '1.6px', color: 'rgba(255,255,255,.78)' }}>{label}</span>}
          {badge && <span style={{ background: 'rgba(255,255,255,.18)', borderRadius: 'var(--radius-pill)', padding: '5px 11px', fontFamily: 'var(--font-ui)', fontSize: 11, fontWeight: 700, letterSpacing: '.8px' }}>{badge}</span>}
        </div>
      )}
      {children}
    </section>
  );
}
