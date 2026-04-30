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
- Campos de usuario e senha
- Botao para entrar (redireciona para inventario apos autenticar)
- Atalho para recuperacao de senha

Observacao: por padrao, o app autentica no endpoint publico do DummyJSON em `https://dummyjson.com/auth/login`.

Credenciais de teste para a API real:

- Usuario: `emilys`
- Senha: `emilyspass`

Para manter o modo mock, use `--dart-define=NEXTINVENTORY_AUTH_MOCK=true`.

### 2. Recuperacao de senha

Fluxo com duas etapas:

- Etapa 1: envio de codigo de verificacao por e-mail (simulado)
- Etapa 2: validacao de codigo e definicao de nova senha (simulado)

### 3. Inventario (CRUD)

- Listagem de itens cadastrados
- Cadastro de novo item com:
    - Nome (pode ser gerado por IA)
    - Codigo patrimonial gerado automaticamente
    - Localizacao
    - Status
    - Descricao (pode ser gerada por IA)
- **NOVO:** Identificação de itens por foto (Câmera ou Galeria) utilizando a API do Google AI Studio (Gemini 1.5 Flash), preenchendo o nome e a descrição do item automaticamente.
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
- http
- sqflite
- sqflite_common_ffi
- path
- image_picker
- google_generative_ai
- flutter_dotenv
- mime
- flutter_lints (dev)

## Estrutura do projeto

```text
.env (não comitado)
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
        gemini_service.dart
        inventory_database_service.dart
    widgets/
        custom_text_field.dart
        inventory_item_card.dart

assets/
    images/
```

Resumo dos principais arquivos:

- lib/main.dart: inicializacao do app, carregamento do `.env`, tema e registro das rotas
- lib/services/inventory_database_service.dart: singleton de acesso ao SQLite
- lib/services/gemini_service.dart: integracao com Google AI Studio
- lib/screens/inventory_screen.dart: tela principal e dialogo de cadastro/edicao com suporte a imagens
- lib/models/inventory_item.dart: modelo de dados do item de inventario

## Fluxo de navegacao

Rotas registradas:

- /login
- /inventory
- /about
- /password-recovery

Fluxo principal:

1. App inicia em /login
2. Ao autenticar com sucesso, navega para /inventory
3. A partir do inventario, o usuario pode abrir /about
4. Na tela de login, o usuario pode seguir para /password-recovery

## Autenticacao

### Endpoint padrao

- `https://dummyjson.com/auth/login`

### Payload enviado

```json
{
    "username": "emilys",
    "password": "emilyspass"
}
```

### Resposta esperada

O app aceita `accessToken`, `access_token` ou `token` na resposta e segue para a tela de inventario quando a autenticacao retorna `200`.

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
- description: TEXT NOT NULL DEFAULT ''
- created_at: INTEGER NOT NULL

Indice:

- idx_inventory_items_created_at em created_at DESC

### Regras importantes implementadas

- Codigo patrimonial unico (restricao UNIQUE)
- Mensagens de erro amigaveis para violacoes de constraints
- Ordenacao da listagem por data de criacao (mais novos primeiro)
- Migrations automáticas no SQLite (via `onUpgrade`) para suportar novos campos como o `description`.

## Integracao com IA (Google Gemini)

O app permite tirar ou selecionar fotos e enviá-las para a API do Google AI Studio para preenchimento automático. 
Para que isso funcione, é necessário criar um arquivo na raiz do projeto chamado `.env` contendo a seguinte variável:

```env
GEMINI_API_KEY=sua_chave_de_api_aqui
```

*Nota: o arquivo `.env` deve ser adicionado ao `.gitignore` para nao vazar credenciais.*

## Como executar

### 1. Executar

```bash
flutter run
```

