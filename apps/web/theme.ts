import { definePreset } from '@primeuix/themes';
import Aura from '@primeuix/themes/aura';

// Define custom color palette
const primary = {
  50: '#f0f9ff',
  100: '#e0f2fe',
  200: '#bae6fd',
  300: '#7dd3fc',
  400: '#38bdf8',
  500: '#0ea5e9', // Base primary color
  600: '#0284c7',
  700: '#0369a1',
  800: '#075985',
  900: '#0c4a6e',
};

// Define custom Aura preset with color schemes
const ThemePreset = definePreset(Aura, {
  semantic: {
    primary,
    colorScheme: {
      light: {
        primary: {
          color: primary[500],
          contrastColor: '#ffffff',
          hoverColor: primary[600],
          activeColor: primary[700],
        },
        highlight: {
          background: primary[50],
          focusBackground: primary[100],
          color: primary[700],
          focusColor: primary[800],
        },
      },
      dark: {
        primary: {
          color: primary[200],
          contrastColor: primary[900],
          hoverColor: primary[100],
          activeColor: primary[50],
        },
        highlight: {
          background: 'rgba(14, 165, 233, 0.16)',
          focusBackground: 'rgba(14, 165, 233, 0.24)',
          color: 'rgba(186, 230, 253, 0.87)',
          focusColor: 'rgba(186, 230, 253, 0.87)',
        },
        surface: {
          0: '#ffffff',
          50: '#fafafa',
          100: '#f4f4f5',
          200: '#e4e4e7',
          300: '#d4d4d8',
          400: '#a1a1aa',
          500: '#71717a',
          600: '#52525b',
          700: '#3f3f46',
          800: '#27272a',
          900: '#18181b',
          950: '#09090b',
        },
      },
    },
  },
});

export default {
  preset: ThemePreset,
  options: {
    darkModeSelector: '.p-dark',
  },
};
