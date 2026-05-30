*** Settings ***
Documentation       Dados e locators para o dominio Contas a Pagar.
...                 Responsabilidade: centralizar variaveis, locators e constantes.


*** Variables ***
# --- Colunas do grid Processos de pagamento (0-based) ---
${CONTAS_PAGAR_COLUNA_CONFIRMADO}             5
${CONTAS_PAGAR_COLUNA_BANCO}                  15
${CONTAS_PAGAR_COLUNA_CONTA}                  16

# --- Locators do popup de selecao de empresa/obra ---
${CONTAS_PAGAR_POPUP_EMPRESA_LOCATOR}         id:frmSelecaoEmpresaObra
${CONTAS_PAGAR_GRID_EMPRESA_HEADER_LOCATOR}   id:gridEmpresaObra > name:Empresa and type:HeaderControl
${CONTAS_PAGAR_BOTAO_EMPRESA_OBRA_LOCATOR}    id:ucContainer > path:1|1|1|2|1

# --- Locators dos campos de periodo ---
${CONTAS_PAGAR_CAMPO_DATA_INICIAL_LOCATOR}    id:ucContainer > id:mskDataInicial
${CONTAS_PAGAR_CAMPO_DATA_FINAL_LOCATOR}      id:ucContainer > id:mskDataFinal
${CONTAS_PAGAR_BOTAO_BUSCAR_LOCATOR}          id:ucContainer > id:23

# --- Timeouts e delays ---
${CONTAS_PAGAR_TIMEOUT_PADRAO}                15s
${CONTAS_PAGAR_DATA_INICIAL_PADRAO}           01/01/2022
