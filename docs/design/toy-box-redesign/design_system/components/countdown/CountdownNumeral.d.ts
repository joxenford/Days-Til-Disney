export interface CountdownNumeralProps {
  value: number | string;
  /** 'days', 'of 7 days' — lower-case, sits on the numeral's baseline */
  unit?: string;
  size?: 'hero' | 'screen' | 'milestone';
  onPark?: boolean;
}
export function CountdownNumeral(props: CountdownNumeralProps): JSX.Element;
