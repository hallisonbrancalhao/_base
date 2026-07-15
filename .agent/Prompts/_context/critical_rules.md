<!-- Bloco reutilizável: regras inegociáveis do projeto -->

## Regras Críticas (NUNCA QUEBRE)

### TypeScript
- Max 5 statements / função, max 3 parâmetros
- Strict mode, nomes auto-documentados
- Sem comentários óbvios (ver `.agent/System/typescript_clean_code.md`)

### Angular
- Standalone components (NO NgModules)
- Signals (NO BehaviorSubject)
- `input()` / `output()` (NO decoradores)
- `@if` / `@for` / `@switch` (NO `*ngIf`/`*ngFor`)
- `inject()` (NO constructor injection)

### PrimeNG
- Componentes: `p-button`, `p-select`, `p-inputtext`, `p-date-picker`, `p-table`
- Templates: `#header`, `#body` (NO `pTemplate=`)
- NUNCA: `pButton`, `pDropdown`, `pCalendar` (diretivas)

### Styling
- Surface tokens: `surface-0`..`surface-950`
- Dark mode: prefixo `dark:`
- NUNCA: `gray-*`, `slate-*`, cores hardcoded, inline styles

### Validação (FE)
- NUNCA usar `class-validator` / `class-transformer` no frontend
- DTOs com validators apenas no backend (`data-source`)
