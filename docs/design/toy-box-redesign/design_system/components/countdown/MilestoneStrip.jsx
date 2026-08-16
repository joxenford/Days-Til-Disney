import React from 'react';

const MILESTONES = [100, 50, 30, 14, 7, 3, 1, 0];

export function MilestoneStrip({ daysOut, onPark = true }) {
  return (
    <div style={{ display: 'flex', gap: 8 }}>
      {MILESTONES.map(m => {
        const reached = daysOut <= m;
        return <span key={m} style={{
          flex: 1, height: 8, borderRadius: 'var(--radius-pill)',
          background: reached
            ? (onPark ? 'var(--gold)' : 'var(--accent)')
            : (onPark ? 'rgba(255,255,255,.28)' : 'var(--hairline)')
        }} />;
      })}
    </div>
  );
}
