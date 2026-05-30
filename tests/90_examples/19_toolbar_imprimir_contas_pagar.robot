*** Settings ***
Documentation       Exemplo de click no botão "Imprimir" da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Imprimir" para abrir a
...                 solicitação de pagamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Resource            ../../resources/data/contas_pagar_data.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    imprimir-toolbar


*** Variables ***
${LINHA_ALVO}                        4


*** Test Cases ***
Selecionar Linha E Imprimir Solicitacao Via Toolbar
    [Documentation]    Seleciona a linha ${LINHA_ALVO} (0-based) do grid Processos de pagamento
    ...                e clica no botão "Imprimir" da toolbar para abrir a solicitação de pagamento.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando impressao de solicitacao na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TOOLBAR_IMPRIMIR_SOLICITACAO_INDEX}
    Pausa Controlada    1s    Aguardando tela de impressao abrir
    Log    [CONTAS_PAGAR] Impressao acionada para linha ${LINHA_ALVO}.    console=True
