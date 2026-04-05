# 📦 NextInventory

Aplicação para **gestão de inventário** desenvolvida com **Flutter**, para a disciplina de Desenvolvimento Mobile do curso de Ciências da Computação da Faculdade Anchieta.
---

## 🎯 Visão Geral

**NextInventory** é uma solução simples para gestão de inventário para facilitar o controle de ativos em pequenas empresas. O aplicativo oferece cadastro de itens, edição e exclusão de itens do invetário.

## Mapa da Aplicação
```
lib/
├── main.dart              # Ponto de entrada da aplicação
├── models/                # Modelos de dados
│   └── inventory_item.dart
├── screens/               # Telas da aplicação
│   ├── login_screen.dart
│   ├── password_recovery_screen.dart
│   ├── inventory_screen.dart
│   └── about_screen.dart
├── widgets/               # Componentes reutilizáveis
│   ├── custom_text_field.dart
│   └── inventory_item_card.dart
└── assets/                # Imagens e recursos
    └── images/
```
---

## Instalação e Configuração

### Pré-requisitos
- **Flutter** 3.10.4 ou superior
- **Dart** 3.10.4 ou superior
- **Android Studio** ou **VS Code** com extensão Flutter
- **Xcode** (para build iOS)
- **Android SDK** (para build Android)

### Passo 1: Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/Nextinventory.git
cd Anchieta_Flutter_Nextinventory
```

### Passo 2: Instalar Dependências

```bash
flutter pub get
```

### Passo 3: Executar o Aplicativo

```bash
flutter run
```
