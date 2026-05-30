---
description: "Use when creating or editing tests/resources that interagem com o grid Win32 do UauXT (Processos de pagamento, Contas a Pagar, grids TG80/C1Grid). Cobre keywords disponíveis, parâmetros de delay, regras 0-based/1-based e anti-patterns."
applyTo: ["resources/apps/uauxt_grid.resource", "resources/data/uauxt_grid_data.resource", "tests/**/*.robot"]
---

# UauXT Grid — Referência de automação

## Resource obrigatório
```robot
Resource    ../../resources/apps/uauxt_grid.resource
```
O `uauxt_grid.resource` já importa `uauxt_grid_data.resource` — não importar separadamente nos testes.

## Probe Win32
O grid é controlado via `resources/scripts/uauxt_grid_probe.py` (subprocesso 32-bit).  
Nunca chamar o probe diretamente nos testes — usar apenas as keywords do resource.

---

## Keywords por operação

### Localizar grid
```robot
${grid}=    Registrar Grid UauXT Por Win32
...    target_text=Processos de pagamento
...    grid_index=0
# Retorna dict: handle, left, top, right, bottom, width, height
```

### Ler célula (0-based)
```robot
${valor}=    Ler Valor Da Celula No Grid UauXT
...    target_text=Processos de pagamento
...    row_index=0    col_index=5

# Atalho fixo para grid Processos de pagamento (converte 1-based internamente):
${valor}=    Ler Valor Da Celula No Grid Processos Pagamento
...    row_index=1    col_index=5
```

### Alterar célula única
```robot
${payload}=    Alterar Celula No Grid UauXT
...    row_index=0    col_index=5    value=DVQ

# Atalho:
${payload}=    Alterar Celula No Grid Processos Pagamento
...    row_index=0    col_index=5    value=DVQ
```

### Alterar faixa de linhas (mais eficiente para múltiplas linhas)
```robot
# Interpreta linha_inicial/final como 1-based se >= 1, 0-based se = 0
${payload}=    Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas
...    col_index=5    value=DVQ
...    linha_inicial=1    linha_final=3
```

### Alterar lista de índices específicos
```robot
# row_indexes é @{} — últimos argumentos posicionais
${payload}=    Alterar Celulas No Grid Processos Pagamento Por Indices De Linha
...    col_index=5    value=DVQ    1    3    7
```

### Acionar botão de célula (ex.: Vínculos NF, dropdown)
```robot
# interaction_mode: right-corner-click (default) ou alt-down
${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
...    row_index=0    col_index=13    interaction_mode=alt-down

# Atalho para Alt+Down:
${payload}=    Ciclar Opcao Da Celula No Grid Processos Pagamento
...    row_index=0    col_index=13
```

### Ler preview de linhas (clipboard)
```robot
${rows}=    Ler Preview De Linhas Do Grid Por Handle    ${handle}    max_rows=40

# Validar texto em qualquer linha:
Validar Texto Em Linhas Do Grid Por Handle    ${handle}    texto=DVQ
```

### Contar registros pelo rodapé
```robot
${qtd}=    Contabilizar Processos No Grid Contas A Pagar    min_registros=1
```

---

## Regra 0-based / 1-based

| Keyword | Base padrão |
|---------|-------------|
| `Alterar Celula No Grid UauXT` | 0-based |
| `Alterar Celula No Grid Processos Pagamento` | 0-based |
| `Ler Valor Da Celula No Grid UauXT` | 0-based |
| `Ler Valor Da Celula No Grid Processos Pagamento` | **1-based** (converte internamente) |
| `Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas` | **1-based se >= 1**, 0-based se = 0 |
| `Alterar Celulas No Grid Processos Pagamento Por Indices De Linha` | 0-based |

---

## Delays configuráveis (em `uauxt_grid_data.resource`)

| Variável | Default | Significado |
|----------|---------|-------------|
| `${UAUXT_GRID_BATCH_MOVE_DELAY_MS}` | 300ms | Pausa entre teclas DOWN de navegação |
| `${UAUXT_GRID_BATCH_TYPE_DELAY_MS}` | 250ms | Pausa após digitar o valor |
| `${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}` | 350ms | Pausa após DOWN de commit |

Para ambientes lentos, sobrescrever na suite:
```robot
*** Variables ***
${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}    600
```

---

## Commit de célula

O preenchimento em lote usa `DOWN` após cada valor — inclusive na última linha — para garantir saída do modo edição. Não usar F12, Enter ou RIGHT/LEFT como estratégia de commit.

---

## Constantes úteis de `uauxt_grid_data.resource`

```robot
${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}    # "Processos de pagamento"
${UAUXT_GRID_PREFERRED_INDEX}                    # 0
${UAUXT_GRID_TIMEOUT_PROBE}                      # 90s
```

---

## Anti-patterns

- **Proibido**: hardcodar `target_text` ou `grid_index` diretamente no teste — usar as constantes do `uauxt_grid_data.resource` ou os atalhos `*Processos Pagamento`.
- **Proibido**: importar `uauxt_grid_data.resource` diretamente no teste.
- **Proibido**: chamar `Executar Probe Grid UauXT` diretamente nos testes ou domains.
- **Proibido**: automação por imagem (RPA.Images, OCR).
- **Evitar**: `Sleep` arbitrário — ajustar os delays via variáveis.
