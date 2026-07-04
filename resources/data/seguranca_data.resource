*** Settings ***
Documentation       Dados e locators para o módulo Segurança do UauXT.
...                 Responsabilidade: centralizar variáveis e locators de navegação e tela de usuários.


*** Variables ***
# --- Tela: Usuários ---
${SEGURANCA_USUARIOS_TELA_LOCATOR}         id:MainView and type:WindowControl
${SEGURANCA_USUARIOS_GRID_LOCATOR}         class:TG80.C1GridOleDB32.20
${SEGURANCA_USUARIOS_SSTAB_LOCATOR}        class:SSTabCtlWndClass
${SEGURANCA_USUARIOS_TOOLBAR_CLASS}        msvb_lib_toolbar
${SEGURANCA_USUARIOS_TOOLBAR_IDX}          0
# Toolbar da tela de usuários (mapeamento via hover+tooltip): Novo, Programa, Departamento, Cargo.
${SEGURANCA_USUARIOS_TB_BTN_NOVO_IDX}       0
${SEGURANCA_USUARIOS_TB_BTN_PROGRAMA_IDX}  1
${SEGURANCA_USUARIOS_TB_BTN_DPTO_IDX}     2
${SEGURANCA_USUARIOS_TB_BTN_CARGO_IDX}     3

# --- Tela: Grupo de Usuários ---
${SEGURANCA_GRP_USUARIOS_TELA_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_GRP_USUARIOS_TELA
${SEGURANCA_GRP_USUARIOS_GRID_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_GRP_USUARIOS_GRID
${SEGURANCA_GRP_BTN_INSERIR_LOCATOR}          automation_id:5
${SEGURANCA_GRP_BTN_CP_LOCATOR}               automation_id:4

# --- Tela: Manutenção de Usuários ---
${SEG_MNT_USR_TELA_LOCATOR}                  id:MainView and type:WindowControl
${SEG_MNT_USR_TELA_TITULO}                   Manutenção de usuários
${SEG_MNT_USR_GRID_LOCATOR}                  class:TG80.C1GridOleDB32.20
${SEG_MNT_USR_TOOLBAR_CLASS}                 msvb_lib_toolbar
${SEG_MNT_USR_TOOLBAR_IDX}                   0
# Ordem visual da toolbar (0-based) da barra principal: Gravar, Excluir (inativo), Separador, Anterior, Próximo, Separador, Sair.
${SEG_MNT_USR_TB_BTN_GRAVAR_IDX}             0
${SEG_MNT_USR_TB_BTN_EXCLUIR_IDX}            1
${SEG_MNT_USR_TB_BTN_SEP1_IDX}               2
${SEG_MNT_USR_TB_BTN_ANTERIOR_IDX}           3
${SEG_MNT_USR_TB_BTN_PROXIMO_IDX}            4
${SEG_MNT_USR_TB_BTN_SEP2_IDX}               5
${SEG_MNT_USR_TB_BTN_SAIR_IDX}               6

# --- Folder: Obras usuário ---
${SEG_MNT_USR_OBR_USR_FRM_LOCATOR}          automation_id:1

# --- Folder: Dados gerais ---
# IDs revalidados no Inspect.exe para os campos e folders da tela de manutenção de usuários:
# login -> 16, nome -> 15, e-mail -> 12; demais controles mantidos conforme a sequência do Inspect.
${SEG_MNT_USR_DG_FRM_LOCATOR}                automation_id:2
${SEG_MNT_USR_DG_BTN_LOCATOR}                automation_id:3
${SEG_MNT_USR_DG_TXT1_LOCATOR}               automation_id:16
${SEG_MNT_USR_DG_TXT2_LOCATOR}               automation_id:15
${SEG_MNT_USR_DG_CHK1_LOCATOR}               automation_id:6
${SEG_MNT_USR_DG_CBX_LOCATOR}                automation_id:7
${SEG_MNT_USR_DG_CHK2_LOCATOR}               automation_id:8
${SEG_MNT_USR_DG_TXT3_LOCATOR}               automation_id:9
${SEG_MNT_USR_DG_TXT4_LOCATOR}               automation_id:10
${SEG_MNT_USR_DG_CHK3_LOCATOR}               automation_id:11
${SEG_MNT_USR_DG_TXT5_LOCATOR}               automation_id:12
${SEG_MNT_USR_DG_OPT_INA_LOCATOR}            automation_id:13
${SEG_MNT_USR_DG_OPT_ATV_LOCATOR}            automation_id:14
${SEG_MNT_USR_DG_TXT6_LOCATOR}               automation_id:15
${SEG_MNT_USR_DG_TXT7_LOCATOR}               automation_id:16

# --- Folder: Departamentos usuários ---
${SEG_MNT_USR_DEP_FRM_LOCATOR}               automation_id:17
${SEG_MNT_USR_DEP_BTN_LOCATOR}               automation_id:18

# --- Folder: Permissão de criação ---
${SEG_MNT_USR_CRI_FRM_LOCATOR}               automation_id:19

# --- Folder: Usuários ---
${SEG_MNT_USR_USR_BTN_LOCATOR}               automation_id:20

# --- Folder: Empreendimentos por usuário ---
${SEG_MNT_USR_EMP_FRM_LOCATOR}               automation_id:21
${SEG_MNT_USR_EMP_BTN_LOCATOR}               automation_id:22

# --- Folder: Permissões ---
${SEG_MNT_USR_PERM_FRM_LOCATOR}              automation_id:23
${SEG_MNT_USR_PERM_CHK_GRP_LOCATOR}          automation_id:24
${SEG_MNT_USR_PERM_CHK_USR_LOCATOR}          automation_id:25
${SEG_MNT_USR_PERM_CHK_CFG_LOCATOR}          automation_id:26
${SEG_MNT_USR_PERM_CHK_ECOM_LOCATOR}         automation_id:27
${SEG_MNT_USR_PERM_CHK_DEP_LOCATOR}          automation_id:28
${SEG_MNT_USR_PERM_CHK_COP_LOCATOR}          automation_id:29
${SEG_MNT_USR_PERM_CHK_OBRA_LOCATOR}         automation_id:30
${SEG_MNT_USR_PERM_CHK_BANCO_LOCATOR}        automation_id:31
${SEG_MNT_USR_PERM_CHK_CONS_LOCATOR}         automation_id:32
${SEG_MNT_USR_PERM_CHK_ALC_LOCATOR}          automation_id:33

# --- Folder: Dados do comprador ---
${SEG_MNT_USR_COMPR_FRM_LOCATOR}             automation_id:34
${SEG_MNT_USR_COMPR_TXT1_LOCATOR}            automation_id:35
${SEG_MNT_USR_COMPR_TXT2_LOCATOR}            automation_id:36
${SEG_MNT_USR_COMPR_TXT3_LOCATOR}            automation_id:37

# --- Folder: Permissões gerais ---
${SEG_MNT_USR_GEN_FRM_LOCATOR}               automation_id:38
${SEG_MNT_USR_GEN_BTN_PROG_LOCATOR}          automation_id:40

# --- Folder: Permissão por obra ---
${SEG_MNT_USR_OBRA_FRM_LOCATOR}              automation_id:41

# --- Folder: Auto abrir telas ---
${SEG_MNT_USR_AUTO_CHK1_LOCATOR}             automation_id:43
${SEG_MNT_USR_AUTO_CHK2_LOCATOR}             automation_id:44

# --- Folder: Linhas do grid ---
${SEG_MNT_USR_GRD_FRM_LOCATOR}               automation_id:45
${SEG_MNT_USR_GRD_CBX_LOCATOR}               automation_id:46

# --- Folder: Cores ---
${SEG_MNT_USR_COL_FRM_LOCATOR}               automation_id:47
${SEG_MNT_USR_COL_BTN1_LOCATOR}              automation_id:48
${SEG_MNT_USR_COL_BTN2_LOCATOR}              automation_id:49
${SEG_MNT_USR_COL_TXT1_LOCATOR}              automation_id:50
${SEG_MNT_USR_COL_TXT2_LOCATOR}              automation_id:51
${SEG_MNT_USR_COL_TXT3_LOCATOR}              automation_id:52
${SEG_MNT_USR_COL_BTN3_LOCATOR}              automation_id:53
${SEG_MNT_USR_COL_TXT4_LOCATOR}              automation_id:54
${SEG_MNT_USR_COL_CHK1_LOCATOR}              automation_id:55
${SEG_MNT_USR_COL_CHK2_LOCATOR}              automation_id:56

# --- Folder: Fontes do grid ---
${SEG_MNT_USR_FNT_FRM_LOCATOR}               automation_id:57
${SEG_MNT_USR_FNT_TXT1_LOCATOR}              automation_id:59
${SEG_MNT_USR_FNT_TXT2_LOCATOR}              automation_id:63
${SEG_MNT_USR_FNT_TXT3_LOCATOR}              automation_id:64
${SEG_MNT_USR_FNT_TXT4_LOCATOR}              automation_id:65
${SEG_MNT_USR_FNT_BTN_SEL_LOCATOR}           automation_id:66
${SEG_MNT_USR_FNT_OPT_LIN_LOCATOR}           automation_id:67
${SEG_MNT_USR_FNT_OPT_POS_LOCATOR}           automation_id:68
${SEG_MNT_USR_FNT_BTN_RST_LOCATOR}           automation_id:69

# --- Folder: Envio OAuth ---
${SEG_MNT_USR_OAUTH_FRM_LOCATOR}             automation_id:70
${SEG_MNT_USR_OAUTH_CHK_LOCATOR}             automation_id:71
${SEG_MNT_USR_OAUTH_TXT1_LOCATOR}            automation_id:72
${SEG_MNT_USR_OAUTH_BTN_LOCATOR}             automation_id:73
${SEG_MNT_USR_OAUTH_TXT2_LOCATOR}            automation_id:74
${SEG_MNT_USR_OAUTH_TXT3_LOCATOR}            automation_id:75

# --- Folder: Datas / calendário ---
${SEG_MNT_USR_DAT_BTN_ELL_LOCATOR}           automation_id:77

# --- Folder: Financeiro ---
${SEG_MNT_USR_FIN_FRM_LOCATOR}               automation_id:78
${SEG_MNT_USR_FIN_CHK1_LOCATOR}              automation_id:79
${SEG_MNT_USR_FIN_CHK2_LOCATOR}              automation_id:80
${SEG_MNT_USR_FIN_CHK3_LOCATOR}              automation_id:81
${SEG_MNT_USR_FIN_CBX_LOCATOR}               automation_id:82

# --- Folder: Margens para relatórios ---
${SEG_MNT_USR_MRG_FRM_LOCATOR}               automation_id:83
${SEG_MNT_USR_MRG_TXT1_LOCATOR}              automation_id:84
${SEG_MNT_USR_MRG_TXT2_LOCATOR}              automation_id:85
${SEG_MNT_USR_MRG_TXT3_LOCATOR}              automation_id:86
${SEG_MNT_USR_MRG_TXT4_LOCATOR}              automation_id:87

# --- Folder: Alertas e comunicação ---
${SEG_MNT_USR_COM_CHK1_LOCATOR}              automation_id:88
${SEG_MNT_USR_COM_CHK2_LOCATOR}              automation_id:89
${SEG_MNT_USR_COM_CHK3_LOCATOR}              automation_id:90
${SEG_MNT_USR_COM_CBX_LOCATOR}               automation_id:91

# --- Locators pendentes compartilhados ---
${SEGURANCA_BTN_NOVO_LOCATOR}             TODO_CONFIGURAR_SEGURANCA_BTN_NOVO
${SEGURANCA_BTN_EDITAR_LOCATOR}           TODO_CONFIGURAR_SEGURANCA_BTN_EDITAR
${SEGURANCA_BTN_EXCLUIR_LOCATOR}          TODO_CONFIGURAR_SEGURANCA_BTN_EXCLUIR
${SEGURANCA_COLUNAS_GRID_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_COLUNAS_GRID
