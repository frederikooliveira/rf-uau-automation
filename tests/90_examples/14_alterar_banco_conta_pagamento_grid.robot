*** Settings ***
Documentation       Exemplo de alteracao de banco e conta em pagamento no grid Processos de pagamento.
...                 Abre popup de banco (coluna 15), digita o codigo do banco, navega para coluna de conta e seleciona a conta.
Library             Collections
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar    banco-conta    grid-botao


*** Variables ***
${LINHA_ALVO}                        0
${COLUNA_BANCO}                      15
${COLUNA_CONTA}                      16
${CODIGO_BANCO}                      341
${CODIGO_CONTA}                      12345-6


*** Test Cases ***
Alterar Banco E Conta Do Pagamento No Grid
    [Documentation]    Considera a tela ja aberta com dados carregados no grid de Processos de pagamento.
    ...                Fluxo: abre popup de banco na coluna 15 da linha 1 -> digita codigo do banco ->
    ...                confirma -> move para coluna de conta -> digita codigo da conta -> confirma.
    Log    [CONTAS_PAGAR] Iniciando alteracao de banco e conta na linha ${LINHA_ALVO}...    console=True
    Abrir Popup Banco Na Linha
    Selecionar Conta Na Linha
    Log    [CONTAS_PAGAR] Banco e conta alterados com sucesso na linha ${LINHA_ALVO}.    console=True


*** Keywords ***
Abrir Popup Banco Na Linha
    [Documentation]    Aciona o botao da celula de banco (coluna ${COLUNA_BANCO}) na linha alvo e digita o codigo.
    Log    [CONTAS_PAGAR] Abrindo popup de banco na linha ${LINHA_ALVO} coluna ${COLUNA_BANCO}...    console=True
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${LINHA_ALVO}
    ...    ${COLUNA_BANCO}
    ...    alt-down
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel acionar popup de banco na celula alvo.
    Pausa Controlada    800ms    Aguardando abertura do popup de banco
    Log    [CONTAS_PAGAR] Digitando codigo do banco: ${CODIGO_BANCO}...    console=True
    Send Keys    keys=${CODIGO_BANCO}
    Pausa Controlada    300ms    Aguardando filtro do banco
    Send Keys    keys={ENTER}
    Pausa Controlada    500ms    Aguardando confirmacao do banco e retorno ao grid
    Log    [CONTAS_PAGAR] Banco ${CODIGO_BANCO} selecionado.    console=True

Selecionar Conta Na Linha
    [Documentation]    Aciona o botao da celula de conta (coluna ${COLUNA_CONTA}) na linha alvo e digita o codigo.
    Log    [CONTAS_PAGAR] Abrindo popup de conta na linha ${LINHA_ALVO} coluna ${COLUNA_CONTA}...    console=True
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${LINHA_ALVO}
    ...    ${COLUNA_CONTA}
    ...    alt-down
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel acionar popup de conta na celula alvo.
    Pausa Controlada    800ms    Aguardando abertura do popup de conta
    Log    [CONTAS_PAGAR] Digitando codigo da conta: ${CODIGO_CONTA}...    console=True
    Send Keys    keys=${CODIGO_CONTA}
    Pausa Controlada    300ms    Aguardando filtro da conta
    Send Keys    keys={ENTER}
    Pausa Controlada    500ms    Aguardando confirmacao da conta e retorno ao grid
    Log    [CONTAS_PAGAR] Conta ${CODIGO_CONTA} selecionada.    console=True
