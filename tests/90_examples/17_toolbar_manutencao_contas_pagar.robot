*** Settings ***
Documentation       Exemplo de click no botão "Manutenção" da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Manutenção" para abrir a
...                 tela de manutenção do processo de pagamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Resource            ../../resources/data/contas_pagar_data.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    manutencao-toolbar


*** Variables ***
${LINHA_ALVO}                        1


*** Test Cases ***
Selecionar Linha E Abrir Manutencao Via Toolbar
    [Documentation]    Seleciona a linha ${LINHA_ALVO} (0-based) do grid Processos de pagamento
    ...                e clica no botão "Manutenção" da toolbar para abrir a tela de manutenção.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando acionamento de Manutencao na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TOOLBAR_MANUTENCAO_INDEX}
    Pausa Controlada    1s    Aguardando tela de manutencao abrir
    Log    [CONTAS_PAGAR] Tela de Manutencao acionada para linha ${LINHA_ALVO}.    console=True
