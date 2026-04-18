# NextInventory

Aplicativo Flutter para gestao de inventario, com interface responsiva, fluxo basico de autenticacao e persistencia local com SQLite.

Este projeto foi desenvolvido no contexto academico da disciplina de Desenvolvimento Mobile (Faculdade Anchieta), mas ja possui uma base organizada para evolucao em cenarios reais.

## Sumario

- Visao geral
- Funcionalidades
- Tecnologias e arquitetura
- Estrutura do projeto
- Fluxo de navegacao
- Persistencia de dados (SQLite)
- Como executar o projeto
- Comandos uteis
- Qualidade e padroes
- Troubleshooting
- Melhorias sugeridas

## Visao geral

O NextInventory permite:

- Acesso a uma tela de login (navegacao inicial)
- Recuperacao de senha em duas etapas (simulada)
- Cadastro, listagem, edicao e exclusao de itens de inventario
- Armazenamento local dos itens em banco SQLite

O foco da aplicacao e oferecer uma experiencia simples para controle de ativos, com codigos patrimoniais gerados automaticamente.

## Funcionalidades

### 1. Login

- Tela inicial da aplicacao
- Campos de usuario/e-mail e senha
- Botao para entrar (redireciona para inventario)
- Atalho para recuperacao de senha

Observacao: nesta versao, o login ainda nao valida credenciais em backend.

### 2. Recuperacao de senha

Fluxo com duas etapas:

- Etapa 1: envio de codigo de verificacao por e-mail (simulado)
- Etapa 2: validacao de codigo e definicao de nova senha (simulado)

### 3. Inventario (CRUD)

- Listagem de itens cadastrados
- Cadastro de novo item com:
    - Nome
    - Codigo patrimonial gerado automaticamente
    - Localizacao
    - Status
- Edicao de item existente
- Exclusao com confirmacao

### 4. Tela Sobre

- Informacoes resumidas do aplicativo
- Versao atual exibida na interface

## Tecnologias e arquitetura

### Stack principal

- Flutter (UI)
- Dart
- SQLite local com sqflite
- sqflite_common_ffi para desktop (Windows/Linux)
- path para montagem de caminho do banco

### Dependencias (pubspec)

- flutter
- cupertino_icons
- sqflite
- sqflite_common_ffi
- path
- flutter_lints (dev)

### Organizacao por camadas

- Presentation: telas em lib/screens e componentes em lib/widgets
- Domain model: entidade InventoryItem em lib/models
- Data access: InventoryDatabaseService em lib/services

## Estrutura do projeto

```text
lib/
    main.dart
    models/
        inventory_item.dart
    screens/
        about_screen.dart
        inventory_screen.dart
        login_screen.dart
        password_recovery_screen.dart
    services/
        inventory_database_service.dart
    widgets/
        custom_text_field.dart
        inventory_item_card.dart

assets/
    images/
```

Resumo dos principais arquivos:

- lib/main.dart: inicializacao do app, tema e registro das rotas
- lib/services/inventory_database_service.dart: singleton de acesso ao SQLite
- lib/screens/inventory_screen.dart: tela principal e dialogo de cadastro/edicao
- lib/models/inventory_item.dart: modelo de dados do item de inventario

## Fluxo de navegacao

Rotas registradas:

- /login
- /inventory
- /about
- /password-recovery

Fluxo principal:

1. App inicia em /login
2. Ao entrar, navega para /inventory
3. A partir do inventario, o usuario pode abrir /about
4. Na tela de login, o usuario pode seguir para /password-recovery

## Persistencia de dados (SQLite)

### Banco e tabela

- Banco: nextinventory.db
- Tabela: inventory_items

Schema da tabela:

- id: TEXT PRIMARY KEY
- name: TEXT NOT NULL
- code: TEXT NOT NULL UNIQUE
- location: TEXT NOT NULL
- status: TEXT NOT NULL
- created_at: INTEGER NOT NULL

Indice:

- idx_inventory_items_created_at em created_at DESC

### Regras importantes implementadas

- Codigo patrimonial unico (restricao UNIQUE)
- Mensagens de erro amigaveis para violacoes de constraints
- Ordenacao da listagem por data de criacao (mais novos primeiro)


### 1. Executar

```bash
flutter run
```
