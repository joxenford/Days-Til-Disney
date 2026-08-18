import React from 'react';

const FILLS = {
  primary: { background: 'var(--text-primary)', color: 'var(--bg)' },
  secondary: { background: 'var(--surface)', color: 'var(--text-primary)' },
  onPark: { background: 'var(--bg)', color: 'var(--text-primary)' },
  outlineOnPark: { background: 'transparent', color: '#FFFFFF', border: '1.5px solid rgba(255,255,255,.4)' }
};

export function Button({ children, variant = 'primary', full = true, disabled = false, onClick }) {
  return (
    <button
      onClick={disabled ? undefined : onClick}
      disabled={disabled}
      style={{
        ...FILLS[variant],
        width: full ? '100%' : 'auto',
        padding: full ? '19px 20px' : '15px 22px',
        borderRadius: 'var(--radius-tile-sm)',
        border: FILLS[variant].border || 'none',
        fontFamily: 'var(--font-ui)',
        fontSize: 'var(--size-body-strong)',
        fontWeight: 700,
        letterSpacing: '-.2px',
        textAlign: 'center',
        cursor: disabled ? 'default' : 'pointer',
        opacity: disabled ? 0.45 : 1,
        minHeight: 'var(--tap-min)'
      }}>
      {children}
    </button>
  );
}
