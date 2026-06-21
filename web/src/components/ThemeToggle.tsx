import { useTheme } from '../contexts/ThemeContext';

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      className="btn-small"
      onClick={toggleTheme}
      title={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
    >
      {theme === 'dark' ? '☀️' : '🌙'}
    </button>
  );
}
