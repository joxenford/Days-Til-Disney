Live standby wait. Thresholds copied from ParkDashboardView.swift: under 20 min green, under 45 gold, otherwise long-wait red.

```jsx
<WaitPill minutes={10} />
<WaitPill minutes={90} />
<WaitPill minutes={null} status="refurbishment" />
```

Colour comes from the theme-aware `--wait-short / --wait-mid / --wait-long` text roles — darker park primaries on light surfaces, the bright status values on dark. Set at 19px/700 so it also qualifies as large text. Never hard-code `--status-*` as text colour, and never colour the attraction name itself.
