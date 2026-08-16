export interface CheckboxProps {
  label: string;
  checked?: boolean;
  onToggle?: () => void;
}
export function Checkbox(props: CheckboxProps): JSX.Element;
