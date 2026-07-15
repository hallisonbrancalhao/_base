# trace-execution — Trace de Runtime Passo-a-Passo

> **Quando:** precisa entender **o que acontece em runtime** ao acionar X (click, request, evento).
> Diferente de `explain-code` que é estático: aqui é temporal.

## Contexto Mínimo
- @`.agent/Prompts/_context/output_format.md`

## Prompt

````markdown
Trace de execução.

## Cenário
- **Entry point**: [ex: "click no botão 'Login' em login.component.ts:42"]
- **Trigger**: [ex: "POST /auth/login com email+senha"]
- **Quero saber**: [ex: "tudo que acontece até o token chegar no localStorage"]

## Output

```
T+0  [arquivo:linha]  evento inicial
T+1  [arquivo:linha]  → chama X(args)
T+2  [arquivo:linha]  → emite signal Y
...
T+N  [arquivo:linha]  estado final
```

Para cada passo:
- Estado dos signals/streams envolvidos
- Side effects (HTTP, storage, navigation)
- Pontos onde async/await suspende
- Possíveis fail points

## Regras
- ✅ Linear na ordem cronológica
- ✅ Marque pontos de concorrência (`⚡ paralelo` ou `🔀 race possível`)
- ✅ Marque side effects com emoji (`🌐 HTTP`, `💾 storage`, `🧭 nav`, `🔔 toast`)
- ❌ Não invente passos — se não souber, marque `?`
````
