*** Settings ***
Documentation       Exemplo de filtro por empresa/obra e interação com grid de processos.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar


*** Variables ***
${EMPRESA_PADRAO}                    262
${VALOR_CONFIRMADO}                  DVQ


*** Test Cases ***
Preencher Confirmado No Grid De Processos De Pagamento
    [Documentation]    Preenche o campo Confirmado no grid de Processos de pagamento.
    ...                Pré-requisito: estar na tela de Contas a Pagar.
    Log    [EXEMPLO] Iniciando preenchimento do Confirmado no grid de Processos de pagamento...    console=True
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    ${EMPRESA_PADRAO}
    Pausa Controlada    1s    Aguardando processamento do filtro
    Configurar Periodo Prorrogacao
    Preencher Confirmado Por Faixa    ${VALOR_CONFIRMADO}    0    0
    Log    [EXEMPLO] Preenchimento do Confirmado no grid concluido com sucesso.    console=True
