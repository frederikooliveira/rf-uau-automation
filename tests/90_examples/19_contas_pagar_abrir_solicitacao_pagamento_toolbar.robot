*** Settings ***
Documentation       Exemplo de click no botão "Imprimir" da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Imprimir" para abrir a
...                 solicitação de pagamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    imprimir-toolbar


*** Variables ***
${LINHA_ALVO}                        4


*** Test Cases ***
Abrir Solicitacao De Pagamento
    [Documentation]    Abre a solicitacao de pagamento a partir do grid de Processos de pagamento.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando abertura da solicitacao de pagamento na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TLB_IMPRIMIR_SOLICITACAO_IDX}
    Pausa Controlada    1s    Aguardando tela de impressao abrir
    Log    [CONTAS_PAGAR] Solicitacao de pagamento aberta para linha ${LINHA_ALVO}.    console=True
