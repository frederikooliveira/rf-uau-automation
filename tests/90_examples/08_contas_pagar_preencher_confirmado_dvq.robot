*** Settings ***
Documentation       Exemplo unificado (03 + 04 + 06): login, acesso a Contas a Pagar, filtro e preenchimento DVQ.
Resource            ../../resources/domains/financeiro.resource
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar    dvq    fluxo-completo


*** Variables ***
${EMPRESA_PADRAO}                    262
${VALOR_CONFIRMADO}                  DVQ
${LINHA_INICIAL_DVQ}                 0
${LINHA_FINAL_DVQ}                   1


*** Test Cases ***
Preencher Confirmado No Grid De Processos De Pagamento
    [Documentation]    Preenche o campo Confirmado no grid de Processos de pagamento.
    Log    [EXEMPLO] Iniciando preenchimento do Confirmado no grid de Processos de pagamento...    console=True
    Abrir E Logar No UauXT
    Pausa Controlada    10s    Aguardando carregamento completo apos login
    Acessar Contas A Pagar Via Icone Capacete Obras
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    ${EMPRESA_PADRAO}
    Pausa Controlada    1s    Aguardando processamento do filtro de empresa
    Configurar Periodo Prorrogacao
    Preencher Confirmado Por Faixa    ${VALOR_CONFIRMADO}    ${LINHA_INICIAL_DVQ}    ${LINHA_FINAL_DVQ}
    Log    [EXEMPLO] Preenchimento do Confirmado no grid concluido com sucesso.    console=True
