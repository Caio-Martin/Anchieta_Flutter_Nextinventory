# NextInventory

  Aplicativo Flutter para gestão de inventário de TI, com autenticação via API, assistente de IA integrado e persistência local com SQLite.

Desenvolvido para a disciplina de Desenvolvimento Mobile para IOS no [Centro Universitário Padre Anchieta](https://www.anchieta.br/) sobre a supervisão do docente [Tiago Zaniquelli](https://github.com/zani0x03/), no curso de Ciência da Computação (5º Semestre - 2026), com arquitetura voltada para cenários reais de produção.

---
## Participantes 

- [Aline da Silva de Azevedo](https://github.com/asazeved)
- [Ana Júlia Lima Formiga](https://github.com/AnaJuliaFormiga)
- [Caio Martin do Nascimento](https://github.com/Caio-Martin)



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

---

## Visão geral

O NextInventory é um aplicativo móvel multiplataforma (iOS/Android) que permite:

- Autenticação real via API dedicada
- Cadastro, listagem, edição e exclusão de itens de inventário com persistência local por usuário
- Chat com assistente de IA contextualizado para suporte ao inventário
- Recuperação de senha em duas etapas (simulada)

---

## Funcionalidades

### 1. Login

- Campos de usuário e senha
- Autenticação com API real: `https://mobile-ios-login.zani0x03.eti.br`
- Token de acesso e username salvos em memória via singleton (`AuthService`)
- Redirecionamento automático para a aplicação após login
### 2. Registro de usuário

- Cadastro de novo usuário diretamente pela API
- Campos: nome, sobrenome, login, e-mail e senha
- Endpoint: `POST /api/register`

### 3. Recuperação de senha

Fluxo simulado em duas etapas:

- **Etapa 1:** envio de código de verificação por e-mail
- **Etapa 2:** validação do código e definição de nova senha

### 4. Inventário (CRUD)

- Listagem de itens  por data de criação
- Cadastro de novo item com:
  - Nome
  - Código patrimonial gerado automaticamente   
  - Localização
  - Status
- Edição de item existente
- Exclusão com diálogo de confirmação

### 5. Chat com IA

- Interface de chat com bolhas de mensagem diferenciadas 
- Indicador de carregamento enquanto aguarda resposta
- Integração com endpoint de IA via `Bearer Token` herdado do login
- Aceita campos de resposta: `response`, `message`, `answer` ou `content`

---

## Tecnologias e arquitetura



### Padrões adotados

- **Singleton** para `AuthService`, `AiService` e `InventoryDatabaseService`
- Token de sessão e username do usuário gerenciados em memória via `AuthService` (campos estáticos)
- Separação clara entre camadas: `screens/`, `services/`, `widgets/`, `utils/`, `models/`
- Constantes centralizadas em `AppConstants` (`lib/utils/constants.dart`)
- Isolamento de dados no banco local por username (`created_by`)

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
| `services/auth_service.dart` | Login, registro e logout contra a API real; guarda token e username do usuário logado |
| `services/ai_service.dart` | Envio de mensagens ao endpoint de IA com autenticação |
| `services/inventory_database_service.dart` | CRUD local via SQLite com isolamento por usuário (`created_by`) |
| `screens/chat_screen.dart` | Interface de chat com a IA |
| `widgets/chat_bubble.dart` | Componente de bolha de mensagem do chat |

---

## Autenticação

### Endpoints

| Operação | Método | Endpoint |
|---|---|---|
| Login | `POST` | `https://mobile-ios-login.zani0x03.eti.br/api/auth/login` |
| Registro | `POST` | `https://mobile-ios-login.zani0x03.eti.br/api/register` |


### Gerenciamento de sessão

Após o login bem-sucedido, o `AuthService` armazena em memória:

- `AuthService.token` — Bearer token usado nas requisições autenticadas
- `AuthService.currentUser` — username do usuário logado, usado como chave de isolamento no banco local

Ambos são apagados ao chamar `AuthService.instance.logout()`.

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
- **Versão atual do schema:** `2`

### Schema (v2)

| Coluna | Tipo | Restrição |
|---|---|---|
| `id` | TEXT | PRIMARY KEY |
| `name` | TEXT | NOT NULL |
| `code` | TEXT | NOT NULL, UNIQUE |
| `location` | TEXT | NOT NULL |
| `status` | TEXT | NOT NULL |
| `created_at` | INTEGER | NOT NULL |
| `created_by` | TEXT | NOT NULL, DEFAULT `''` |

**Índices:**
- `idx_inventory_items_created_at` em `created_at DESC`
- `idx_inventory_items_created_by` em `created_by`

### Regras

- Código patrimonial único globalmente (restrição `UNIQUE`)
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
