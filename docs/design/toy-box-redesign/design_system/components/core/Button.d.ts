export interface ButtonProps {
  children: React.ReactNode;
  /** primary = ink fill, secondary = tile fill, onPark/outlineOnPark sit on a park panel */
  variant?: 'primary' | 'secondary' | 'onPark' | 'outlineOnPark';
  /** full-width block button (the app default) */
  full?: boolean;
  disabled?: boolean;
  onClick?: () => void;
}
export function Button(props: ButtonProps): JSX.Element;
