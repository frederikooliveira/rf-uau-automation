*** Settings ***
Documentation       Exemplo de click em botão de ação da toolbar de Contas a Pagar.
...                 Seleciona uma linha no grid e aciona o botão "Vínculo PL" para abrir a
...                 tela Vínculo com Planejamento.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    vinculo-pl


*** Variables ***
${LINHA_ALVO}                        1


*** Test Cases ***
Abrir Vinculo Com Planejamento
    [Documentation]    Abre a tela Vínculo com Planejamento a partir do grid de Processos de pagamento.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando abertura de Vinculo com Planejamento na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Clicar Toolbar    ${LINHA_ALVO}    ${CONTAS_PAGAR_TLB_VINCULO_PL_IDX}
    Pausa Controlada    1s    Aguardando tela Vinculo com Planejamento abrir
    Log    [CONTAS_PAGAR] Tela Vinculo com Planejamento aberta para linha ${LINHA_ALVO}.    console=True
