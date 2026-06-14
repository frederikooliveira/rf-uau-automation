---
description: "Mapeia uma nova tela do UauXT com baixo custo e saida estruturada em JSON para posterior geracao de apps/data/domain/teste. Use quando o usuario informar nome da tela e caminho de acesso."
name: "Mapear Tela UauXT (Baixo Custo)"
argument-hint: "Ex.: Contas a Receber > Financeiro > Titulo a receber"
agent: "agent"
---

Objetivo: mapear rapidamente uma tela nova do UauXT com custo baixo e saida estruturada.

## Entrada minima

Se faltar informacao, pergunte de forma objetiva:
1. nome_tela (obrigatorio)
2. caminho_acesso (obrigatorio)
3. contexto_janela (principal|popup, default: principal)
4. tipo_tela (grid|formulario|mista, default: mista)

## Regras de custo e execucao

- Priorizar descoberta por Win32 (RPA.Windows + probe oficial quando aplicavel)
- Nao usar OCR, imagem ou screenshot matching
- Evitar narrativa longa; coletar fatos tecnicos objetivos
- Nao criar arquivos nesta etapa
- Se algo nao puder ser confirmado, marcar como PENDENTE em vez de inventar
- Nao duplicar estrategia tecnica ja existente em resources/apps/uauxt_grid.resource
- Mapear inventario minimo da tela: toolbars, grids, sstabs e controles principais

## Saida obrigatoria

Responder somente com JSON valido no schema abaixo (sem markdown, sem comentario):

{
  "ok": true,
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
        "list-toolbar-buttons",
        "print-tree-targeted"
      ],
      "reuso_keywords": [
        "Registrar Grid UauXT Por Win32",
        "Listar Botoes Toolbar Via Probe",
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
  "proximo_passo_prompt": "Scaffold Tela UauXT"
}

## Qualidade minima

- Nomear variaveis no padrao do projeto
- Separar claramente confirmado vs pendente
- Sugerir no maximo 5 proximas acoes de validacao pratica
- Sugerir `tests/90_examples/` somente quando o usuario pedir explicitamente um exemplo/diagnostico
- Nao listar todas as colunas do grid como obrigatorias; registrar apenas colunas candidatas criticas
- Sempre registrar todos os grids detectados e todos os sstabs detectados
