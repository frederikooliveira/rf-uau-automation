*** Settings ***
Documentation       Exemplo de alteracao de banco e conta em pagamento no grid Processos de pagamento.
...                 Abre popup de banco (coluna 15), digita o codigo do banco, navega para coluna de conta e seleciona a conta.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    banco-conta    grid-botao


*** Variables ***
${LINHA_ALVO}                        0
${CODIGO_BANCO}                      341
${CODIGO_CONTA}                      12345-6


*** Test Cases ***
Alterar Banco E Conta Do Pagamento No Grid
    [Documentation]    Considera a tela ja aberta com dados carregados no grid de Processos de pagamento.
    ...                Fluxo: abre popup de banco na coluna 15 da linha 1 -> digita codigo do banco ->
    ...                confirma -> move para coluna de conta -> digita codigo da conta -> confirma.
    Log    [CONTAS_PAGAR] Iniciando alteracao de banco e conta na linha ${LINHA_ALVO}...    console=True
    Alterar Banco Do Processo    ${LINHA_ALVO}    ${CODIGO_BANCO}
    Alterar Conta Do Processo    ${LINHA_ALVO}    ${CODIGO_CONTA}
    Log    [CONTAS_PAGAR] Banco e conta alterados com sucesso na linha ${LINHA_ALVO}.    console=True
