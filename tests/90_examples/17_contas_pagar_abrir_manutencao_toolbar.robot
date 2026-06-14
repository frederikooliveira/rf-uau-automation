*** Settings ***
Documentation       Exemplo de click no botão "Manutenção" da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Manutenção" para abrir a
...                 tela de manutenção do processo de pagamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    manutencao-toolbar


*** Variables ***
${LINHA_ALVO}                        1


*** Test Cases ***
Abrir Manutencao Do Processo
    [Documentation]    Abre a tela de manutencao do processo a partir do grid de Processos de pagamento.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando abertura da manutencao do processo na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TLB_MANUTENCAO_IDX}
    Pausa Controlada    1s    Aguardando tela de manutencao abrir
    Log    [CONTAS_PAGAR] Tela de manutencao aberta para linha ${LINHA_ALVO}.    console=True
