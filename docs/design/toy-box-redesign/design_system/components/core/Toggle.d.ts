export interface ToggleProps {
  on?: boolean;
  onChange?: () => void;
  label: string;
}
export function Toggle(props: ToggleProps): JSX.Element;
