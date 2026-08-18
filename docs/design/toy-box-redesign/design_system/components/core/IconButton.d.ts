export interface IconButtonProps {
  /** single character or short glyph run: '+', '‹', '•••', '↻' */
  glyph: string;
  /** loud = ink fill (primary add action), quiet = tile fill */
  tone?: 'loud' | 'quiet';
  label: string;
  onClick?: () => void;
}
export function IconButton(props: IconButtonProps): JSX.Element;
