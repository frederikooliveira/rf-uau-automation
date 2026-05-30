*** Settings ***
Documentation       Exemplo de click em botão de ação da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Vínculo PL" para abrir a
...                 tela Vínculo com Planejamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Resource            ../../resources/data/contas_pagar_data.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    vinculo-pl


*** Variables ***
${LINHA_ALVO}                        1


*** Test Cases ***
Selecionar Linha E Abrir Vinculo Com Planejamento
    [Documentation]    Seleciona a linha ${LINHA_ALVO} (0-based) do grid Processos de pagamento
    ...                e clica no botão "Vínculo PL" da toolbar para abrir a tela Vínculo com Planejamento.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando acionamento de Vinculo PL na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TOOLBAR_VINCULO_PL_INDEX}
    Pausa Controlada    1s    Aguardando tela Vinculo com Planejamento abrir
    Log    [CONTAS_PAGAR] Tela Vinculo com Planejamento acionada para linha ${LINHA_ALVO}.    console=True
