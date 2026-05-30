*** Settings ***
Documentation       Exemplo de abertura da tela de manutenção de processo via duplo clique em linha do grid.
...                 Pré-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    manutencao-processo    duplo-clique


*** Variables ***
${LINHA_ALVO}                        0


*** Test Cases ***
Abrir Tela De Manutencao De Processo Via Duplo Clique
    [Documentation]    Executa duplo clique na linha ${LINHA_ALVO} do grid Processos de pagamento
    ...                para abrir a tela de manutenção do processo.
    ...                Pré-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando abertura de manutenção na linha ${LINHA_ALVO}...    console=True
    ${payload}=    Duplo Clique Na Linha Do Grid Processos Pagamento    ${LINHA_ALVO}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Duplo clique na linha ${LINHA_ALVO} falhou — verifique se o grid esta visivel.
    Pausa Controlada    1s    Aguardando tela de manutencao abrir
    Log    [CONTAS_PAGAR] Tela de manutenção aberta para o processo na linha ${LINHA_ALVO}.    console=True
