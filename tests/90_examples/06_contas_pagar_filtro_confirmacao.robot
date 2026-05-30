*** Settings ***
Documentation       Exemplo de filtro por empresa/obra e interação com grid de processos.
Resource            ../../resources/domains/contas_pagar.resource
Test Tags           examples    uauxt    contas-pagar


*** Variables ***
${EMPRESA_PADRAO}                    262
${VALOR_CONFIRMADO}                  DVQ


*** Test Cases ***
Exemplo Filtro Empresa Obra E Confirmacao Grid
    [Documentation]    Demonstra seleção de empresa/obra, configuração de período e marca confirmação no grid.
    ...                Pré-requisito: estar na tela de Contas a Pagar.
    Log    [EXEMPLO] Iniciando exemplo completo de filtro, período e confirmação...    console=True
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    ${EMPRESA_PADRAO}
    Pausa Controlada    1s    Aguardando processamento do filtro
    Configurar Periodo Prorrogacao
    Preencher Confirmado Por Faixa    ${VALOR_CONFIRMADO}    0    0
    Log    [EXEMPLO] Exemplo completo de filtro, período e confirmação concluído com sucesso.    console=True
