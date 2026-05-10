# NextInventory

Aplicativo Flutter para gestão de inventário, com autenticação via API real, assistente de IA integrado e persistência local com SQLite.

Desenvolvido no contexto acadêmico da disciplina de Desenvolvimento Mobile (Faculdade Anchieta), com arquitetura voltada para cenários reais de produção.

## Sumário

- [Visão geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Tecnologias e arquitetura](#tecnologias-e-arquitetura)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Autenticação](#autenticação)
- [Assistente de IA](#assistente-de-ia)
- [Fluxo de navegação](#fluxo-de-navegação)
- [Persistência de dados (SQLite)](#persistência-de-dados-sqlite)
- [Como executar o projeto](#como-executar-o-projeto)
- [Comandos úteis](#comandos-úteis)
- [Branches](#branches)

---

## Visão geral

O NextInventory é um aplicativo móvel multiplataforma (iOS/Android) que permite:

- Autenticação real via API REST dedicada
- Cadastro, listagem, edição e exclusão de itens de inventário com persistência local
- Chat com assistente de IA contextualizado para suporte ao inventário
- Recuperação de senha em duas etapas (simulada)

---

## Funcionalidades

### 1. Login

- Campos de usuário e senha
- Autenticação contra a API real: `https://mobile-ios-login.zani0x03.eti.br`
- Token de acesso salvo em memória via singleton (`AuthService`)
- Redirecionamento automático para a tela de inventário após sucesso

### 2. Registro de usuário

- Cadastro de novo usuário diretamente pela API
- Campos: nome, sobrenome, login, e-mail e senha
- Endpoint: `POST /api/register`

### 3. Recuperação de senha

Fluxo simulado em duas etapas:

- **Etapa 1:** envio de código de verificação por e-mail
- **Etapa 2:** validação do código e definição de nova senha

### 4. Inventário (CRUD)

- Listagem de itens cadastrados ordenada por data de criação (mais novos primeiro)
- Cadastro de novo item com:
  - Nome
  - Código patrimonial gerado automaticamente (único)
  - Localização
  - Status
- Edição de item existente
- Exclusão com diálogo de confirmação

### 5. Chat com IA

- Interface de chat com bolhas de mensagem diferenciadas (usuário / IA)
- Indicador de carregamento enquanto aguarda resposta
- Integração com endpoint de IA via `Bearer Token` herdado do login
- Aceita campos de resposta: `response`, `message`, `answer` ou `content`

### 6. Tela Sobre

- Informações resumidas do aplicativo
- Versão atual exibida na interface

---

## Tecnologias e arquitetura

### Stack principal

| Camada | Tecnologia |
|---|---|
| UI | Flutter / Dart |
| HTTP | `http ^1.6.0` |
| Banco local | `sqflite ^2.4.2` + `sqflite_common_ffi ^2.3.6` |
| Caminhos | `path ^1.9.1` |
| Ícones | `cupertino_icons ^1.0.8` |

### Padrões adotados

- **Singleton** para `AuthService`, `AiService` e `InventoryDatabaseService`
- Token de sessão gerenciado em memória via `AuthService.token` (estático)
- Separação clara entre camadas: `screens/`, `services/`, `widgets/`, `utils/`, `models/`
- Constantes centralizadas em `AppConstants` (`lib/utils/constants.dart`)

---

## Estrutura do projeto

```text
lib/
├── main.dart
├── models/
│   └── inventory_item.dart
├── screens/
│   ├── about_screen.dart
│   ├── chat_screen.dart
│   ├── inventory_screen.dart
│   ├── login_screen.dart
│   └── password_recovery_screen.dart
├── services/
│   ├── ai_service.dart
│   ├── auth_service.dart
│   └── inventory_database_service.dart
├── utils/
│   └── constants.dart
└── widgets/
    ├── chat_bubble.dart
    ├── custom_text_field.dart
    └── inventory_item_card.dart

assets/
└── images/
```

### Principais arquivos

| Arquivo | Responsabilidade |
|---|---|
| `main.dart` | Inicialização do app, tema, rotas e FFI para desktop |
| `utils/constants.dart` | URLs base e IDs de sistema |
| `services/auth_service.dart` | Login, registro e logout contra a API real; guarda o token |
| `services/ai_service.dart` | Envio de mensagens ao endpoint de IA com autenticação |
| `services/inventory_database_service.dart` | CRUD local via SQLite |
| `screens/chat_screen.dart` | Interface de chat com a IA |
| `widgets/chat_bubble.dart` | Componente de bolha de mensagem do chat |

---

## Autenticação

### Endpoints

| Operação | Método | Endpoint |
|---|---|---|
| Login | `POST` | `https://mobile-ios-login.zani0x03.eti.br/api/auth/login` |
| Registro | `POST` | `https://mobile-ios-login.zani0x03.eti.br/api/register` |

### Payload de login

```json
{
  "username": "seu_usuario",
  "password": "sua_senha",
  "sistemaId": "ab1a8a3b-21c8-422e-95cd-13c16a45e2ec"
}
```

### Resposta esperada

O app aceita qualquer um dos campos: `accessToken`, `access_token` ou `token`.

```json
{
  "accessToken": "eyJhbGci..."
}
```

### Gerenciamento de token

O token é armazenado em `AuthService._token` (singleton em memória) e compartilhado com `AiService` via `AuthService.token`. É limpo ao chamar `AuthService.instance.logout()`.

---

## Assistente de IA

### Endpoint

| Operação | Método | Endpoint |
|---|---|---|
| Chat | `POST` | `https://mobile-ios-ia.zani0x03.eti.br/api/ai/chat` |

### Payload

```json
{
  "prompt": "mensagem do usuário"
}
```

### Headers obrigatórios

```
Content-Type: application/json
Authorization: Bearer <token>
```

### Campos de resposta aceitos

`response` · `message` · `answer` · `content`

Se nenhum campo for encontrado, o corpo bruto da resposta é exibido como fallback.

---

## Fluxo de navegação

```
/login
  ├── (autenticação ok) → /inventory
  │                           ├── (menu) → /about
  │                           └── (menu) → /chat
  └── (link) → /password-recovery
```

Rotas registradas:

- `/login`
- `/inventory`
- `/about`
- `/password-recovery`
- `/chat`

---

## Persistência de dados (SQLite)

### Banco e tabela

- **Banco:** `nextinventory.db`
- **Tabela:** `inventory_items`

### Schema

| Coluna | Tipo | Restrição |
|---|---|---|
| `id` | TEXT | PRIMARY KEY |
| `name` | TEXT | NOT NULL |
| `code` | TEXT | NOT NULL, UNIQUE |
| `location` | TEXT | NOT NULL |
| `status` | TEXT | NOT NULL |
| `created_at` | INTEGER | NOT NULL |

**Índice:** `idx_inventory_items_created_at` em `created_at DESC`

### Regras

- Código patrimonial único (restrição `UNIQUE`)
- Mensagens de erro amigáveis para violações de constraints
- Listagem ordenada por data de criação (mais novos primeiro)
- Em modo desktop (Windows/Linux), usa `sqflite_common_ffi`

---

## Como executar o projeto

### Pré-requisitos

- Flutter SDK `^3.10.4`
- Dart SDK compatível
- Dispositivo físico ou emulador iOS/Android (ou desktop para testes)

### Passos

```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar no dispositivo padrão
flutter run

# 3. Executar em dispositivo específico
flutter run -d <device-id>
```

---
