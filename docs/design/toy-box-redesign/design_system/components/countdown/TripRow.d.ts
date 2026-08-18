/**
 * @startingPoint section="Countdown" subtitle="Secondary trip row with park swatch" viewport="390x80"
 */
export interface TripRowProps {
  name: string;
  /** 'Day 3 of 7 — you're there!' or '45 days away' */
  meta?: string;
  /** --park-* token for the swatch */
  park?: string;
  /** past trips render dimmed */
  dimmed?: boolean;
  onClick?: () => void;
}
export function TripRow(props: TripRowProps): JSX.Element;
