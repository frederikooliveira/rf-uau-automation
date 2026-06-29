*** Settings ***
Documentation       Exemplo de contagem de registros no grid de Processos (Contas a Pagar).
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar    grid-contagem


*** Test Cases ***
Contabilizar Processos No Grid Contas A Pagar
    [Documentation]    Considera a tela Contas a Pagar ja aberta e com registros carregados.
    ...                Requer configuracao dos locators de caption/rodape em resources/data/uauxt_grid_data.resource.
    Log    [EXEMPLO] Iniciando contagem de processos no grid de Contas a Pagar...    console=True
    ${qtd}=    Contabilizar Processos No Grid Contas A Pagar    1
    Should Be True    int(${qtd}) >= 1    Nenhum processo encontrado no grid de Contas a Pagar.
    Log    [EXEMPLO] Total de processos no grid: ${qtd}    console=True
