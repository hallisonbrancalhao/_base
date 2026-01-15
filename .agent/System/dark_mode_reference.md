# Dark Mode - Referência Rápida

## 📋 Visão Geral

Este projeto utiliza **PrimeNG v18 com tema Aura** customizado via Preset e **Tailwind CSS**.

A definição de cores, paletas e comportamento do Dark Mode é centralizada e dinâmica, configurada nos seguintes arquivos:
- **Definição do Tema (Preset):** `@apps/web/theme.ts`
- **Configuração da Aplicação:** `@apps/web/src/app/app.config.ts`

O suporte ao dark mode é ativado através da classe seletora `.p-dark` (configurada no preset), permitindo que componentes PrimeNG e utilitários Tailwind se adaptem automaticamente aos tokens definidos.

---

## ⚡ Regras Críticas

### ✅ SEMPRE USE (Tokens do Preset)

Utilize as classes do Tailwind que mapeiam para as variáveis CSS do PrimeNG geradas pelo Preset (`theme.ts`).

```html
<!-- Fundos: Mapeiam para a paleta 'surface' definida no theme.ts -->
<!-- Exemplo: surface-0/950 para corpo, surface-50/900 para containers -->
<div class="bg-surface-0 dark:bg-surface-950">
<div class="bg-white dark:bg-surface-900">

<!-- Textos: Usar a escala surface para contraste -->
<p class="text-surface-900 dark:text-surface-0">
<span class="text-surface-700 dark:text-surface-200">
<small class="text-surface-500 dark:text-surface-400">

<!-- Bordas -->
<div class="border border-surface-200 dark:border-surface-700">

<!-- Cores Primárias (Definidas no Preset) -->
<!-- A cor 'primary' adapta-se automaticamente (ex: 500 no light, 200 no dark) se configurado semanticamente -->
<i class="text-primary-600 dark:text-primary-400"></i>
```

### ❌ NUNCA USE

```html
<!-- ❌ Cores hardcoded do Tailwind (gray, slate, zinc, etc.) que ignoram o theme.ts -->
<div class="bg-gray-100 dark:bg-gray-800">
<p class="text-zinc-900 dark:text-zinc-100">

<!-- ❌ Cores arbitrárias ou hexadecimais diretos -->
<div class="bg-[#f5f5f5] dark:bg-[#1a1a1a]">

<!-- ❌ Style binding manual para cores do tema -->
<div [style.backgroundColor]="'var(--p-surface-0)'">
```

---

## 🎨 Padrões de Cores (Dinâmico)

As cores abaixo referenciam a paleta `surface` configurada no arquivo `theme.ts`. Os valores exatos (hexadecimais) devem ser consultados/alterados diretamente naquele arquivo.

### Backgrounds (Fundos)

| Contexto | Light Mode (Sugestão) | Dark Mode (Sugestão) |
|----------|-----------------------|----------------------|
| **Base / Body** | `bg-surface-0` ou `bg-white` | `dark:bg-surface-950` |
| **Cards / Containers** | `bg-white` | `dark:bg-surface-900` ou `800` |
| **Overlays / Modais** | `bg-white` | `dark:bg-surface-900` |
| **Hover** | `hover:bg-surface-50` | `dark:hover:bg-surface-800` |

### Textos e Conteúdo

| Contexto | Light Mode (Sugestão) | Dark Mode (Sugestão) |
|----------|-----------------------|----------------------|
| **Principal** | `text-surface-900` | `dark:text-surface-0` |
| **Secundário** | `text-surface-700` | `dark:text-surface-200` |
| **Desabilitado/Hint** | `text-surface-500` | `dark:text-surface-400` |

*Nota: A inversão de tonalidades (ex: 900 no light virar 0 no dark) é um padrão comum, mas verifique o contraste visual final conforme a paleta definida.*

---

## 🔧 Configuração Técnica

A implementação real do projeto encontra-se nos arquivos abaixo.

### 1. Definição do Preset (`apps/web/theme.ts`)

Define a paleta de cores (`primary`, `surface`) e as regras semânticas para light/dark mode.

```typescript
import { definePreset } from '@primeuix/themes';
import Aura from '@primeuix/themes/aura';

// Paleta customizada
const primary = {
  50: '#f0f9ff',
  // ... (definido no arquivo)
  900: '#0c4a6e',
};

const ThemePreset = definePreset(Aura, {
  semantic: {
    primary,
    colorScheme: {
      light: {
        // Mapeamento semântico light
        surface: { ... } // Opcional se usar default
      },
      dark: {
        // Mapeamento semântico dark
        surface: {
            0: '#ffffff', // Definições específicas da paleta
            // ...
            950: '#09090b',
        },
      },
    },
  },
});

export default {
  preset: ThemePreset,
  options: {
    darkModeSelector: '.p-dark', // ✅ Seletor CSS para ativar dark mode
  },
};
```

### 2. Injeção na Aplicação (`apps/web/src/app/app.config.ts`)

O preset é fornecido globalmente via `providePrimeNG`.

```typescript
import { ApplicationConfig } from '@angular/core';
import { providePrimeNG } from 'primeng/config';
import ThemePreset from '../../theme'; // Importa o preset definido acima
import { ptBR } from '../l18n/pt-br';

export const appConfig: ApplicationConfig = {
  providers: [
    // ... outros providers
    providePrimeNG({
      theme: ThemePreset,
      ripple: true,
      translation: ptBR,
    }),
  ],
};
```

### 3. Tailwind (`tailwind.config.js`)

Deve conter o plugin `tailwindcss-primeui` para gerar as classes utilitárias (`bg-surface-X`, `text-primary-X`) baseadas nas variáveis CSS do PrimeNG.

```javascript
module.exports = {
    darkMode: ['selector', '.p-dark'], // Deve corresponder ao darkModeSelector do theme.ts
    plugins: [require('tailwindcss-primeui')]
};
```

---

## ✅ Checklist de Implementação

Ao criar novas telas ou componentes:

1.  **Verifique `theme.ts`**: Entenda quais cores `surface` e `primary` estão disponíveis.
2.  **Use Classes Semânticas**: Prefira `bg-surface-*` a cores fixas.
3.  **Teste o Toggle**: Alterne a classe `.p-dark` no `<html>` (via ThemeService ou DevTools) para validar.
4.  **Componentes PrimeNG**: Eles se adaptam automaticamente. Foque no layout ao redor (divs, spans).

---

**Referências do Projeto**:
- `@apps/web/theme.ts`
- `@apps/web/src/app/app.config.ts`
