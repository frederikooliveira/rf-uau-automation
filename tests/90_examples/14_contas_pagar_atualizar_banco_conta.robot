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
Atualizar Dados Bancarios Do Pagamento
    [Documentation]    Atualiza os dados bancarios do pagamento no grid de Processos de pagamento.
    ...                Considera a tela ja aberta com dados carregados.
    Log    [CONTAS_PAGAR] Iniciando atualizacao dos dados bancarios na linha ${LINHA_ALVO}...    console=True
    Alterar Banco Do Processo    ${LINHA_ALVO}    ${CODIGO_BANCO}
    Alterar Conta Do Processo    ${LINHA_ALVO}    ${CODIGO_CONTA}
    Log    [CONTAS_PAGAR] Dados bancarios atualizados com sucesso na linha ${LINHA_ALVO}.    console=True
