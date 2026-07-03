---
description: "Mapeia uma nova tela do UauXT com baixo custo e saída estruturada em JSON para posterior geração de apps/data/domain/teste. Use quando o usuário informar o nome da tela e o caminho de acesso."
name: "Mapear Tela UauXT (Baixo Custo)"
argument-hint: "Ex.: Segurança > Gestão de Segurança > Usuários"
agent: "agent"
---

Objetivo: produzir um mapeamento técnico confiável de uma nova tela do UauXT com custo baixo e, a partir dele, gerar a ação de navegação para abrir essa tela.

## Entrada mínima

Se faltar informação, pergunte apenas o necessário e não produza o JSON final até que os dados mínimos estejam disponíveis:
1. nome_tela (obrigatório)
2. caminho_acesso (obrigatório)
3. contexto_janela (principal|popup, padrão: principal)
4. tipo_tela (grid|formulario|mista, padrão: mista)

## Fluxo de execução recomendado

1. Confirmar o contexto da tela, o caminho de acesso e o tipo de interação esperada.
2. Priorizar inspeção Win32 com o probe oficial do projeto.
3. Identificar a janela UauXT, o título e os controles principais.
4. Descobrir grids, toolbars, sstabs e controles de ação.
5. Para toolbars, preferir "map-toolbar-buttons" (hover + tooltip) em vez de listar apenas geometria.
6. Registrar apenas o que foi confirmado; tudo que não puder validar vira PENDENTE.
7. Não criar arquivos nem implementar automação nesta etapa.
8. A saída final deve incluir, além do mapeamento, a ação de navegação sugerida ou já estruturada para abrir a tela.

## Restrições e qualidade

- Priorizar descoberta por Win32 (RPA.Windows + probe oficial quando aplicável)
- Não usar OCR, imagem ou screenshot matching
- Evitar narrativa longa; coletar fatos técnicos objetivos
- Não inventar textos, índices, classes, nomes ou posições
- Não duplicar estratégia já existente em resources/apps/uauxt_grid.resource
- Mapear o inventário mínimo da tela: toolbars, grids, sstabs e controles principais
- Se houver mais de um grid ou toolbar, registrar todos
- Se um elemento for visível, mas sem nome semântico confirmado, registrar "name": "?" e observação
- Usar nomes de variáveis no padrão do projeto
- Separar claramente confirmado vs pendente
- Usar tests/90_examples somente se o usuário pedir explicitamente um exemplo ou diagnóstico
- Não listar todas as colunas do grid como obrigatórias; registrar apenas colunas candidatas críticas
- Registrar todos os grids detectados e todos os sstabs detectados
- Se uma seção não existir, usar [] ou {} vazio; não inventar dados
- Preencha todas as seções do schema com o mesmo rigor; a seção acao_navegacao deve ser sempre preenchida por completo, mesmo que outras seções contenham campos vazios ou pendentes

## Saída obrigatória

Se faltar informação que impeça a conclusão do mapeamento, pergunte apenas o necessário e não emita o JSON final até que a informação esteja disponível. Quando o mapeamento puder ser produzido, responder somente com JSON valido no schema abaixo (sem markdown, sem comentario). Se a inspeção Win32 falhar completamente e nenhum dado puder ser coletado, retornar "ok": false com um campo adicional "erro": "<descrição do problema>" e todos os demais campos como null ou [].

{
  "ok": true,
  "erro": null,
  "nome_tela": "",
  "caminho_acesso": "",
  "contexto_janela": "principal|popup",
  "tipo_tela": "grid|formulario|mista",
  "resumo": {
    "window_title": "",
    "main_controls": [
      {
        "class": "",
        "text": "",
        "rect": [0,0,0,0],
        "visible": true,
        "enabled": true
      }
    ],
    "toolbars": [
      {
        "toolbar_index": 0,
        "class": "msvb_lib_toolbar",
        "button_count": 0,
        "buttons": [
          {
            "index": 0,
            "name": "",
            "is_separator": false,
            "observacao": ""
          }
        ]
      }
    ],
    "grids": [
      {
        "target_text": "",
        "grid_index": 0,
        "handle": 0,
        "colunas_candidatas": [
          {
            "nome": "",
            "index": 0,
            "confianca": "alta|media|baixa"
          }
        ]
      }
    ],
    "sstabs": [
      {
        "class": "SSTabCtlWndClass",
        "text": "",
        "rect": [0,0,0,0],
        "visible": true,
        "enabled": true,
        "observacao": ""
      }
    ],
    "estrategia_descoberta": {
      "window_title_regex": "UAUXT",
      "class_tokens_grid_csv": "TG80,C1Grid,GridOleDB,grid",
      "toolbar_class": "msvb_lib_toolbar",
      "ordem_execucao": [
        "find-grid",
        "map-toolbar-buttons",
        "print-tree-targeted"
      ],
      "reuso_keywords": [
        "Registrar Grid UauXT Por Win32",
        "Mapear Botoes Toolbar Via Probe",
        "Clicar Botao Toolbar Por Indice Via Probe"
      ]
    ]
  },
  "locators_confirmados": [
    {
      "nome": "",
      "valor": ""
    }
  ],
  "locators_pendentes": [
    {
      "nome": "",
      "valor_placeholder": "TODO_CONFIGURAR_",
      "motivo": ""
    }
  ],
  "artefatos_sugeridos": {
    "data_file": "resources/data/<contexto>_data.resource",
    "apps_file": "resources/apps/<app>.resource",
    "domain_file": "resources/domains/<dominio>.resource",
    "test_file": "tests/flows/<contexto>/NN_<nome>.robot",
    "core_changes": [
      "somente se houver helper tecnico reutilizavel"
    ]
  },
  "acao_navegacao": {
    "nome_keyword": "Acessar <Tela> Via <Caminho>",
    "tipo": "menu|toolbar|shortcut|popup",
    "passos": [
      "passo 1",
      "passo 2"
    ],
    "observacao": ""
  },
  "proximo_passo_prompt": "Scaffold Tela UauXT"
}

