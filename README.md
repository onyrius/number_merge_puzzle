# 🧩 Number Merge Puzzle (WIP)

Uma aplicação Flutter para estudar DDD, Clean Architecture, BLoC e boas práticas de testes, usando uma mecânica inspirada em quebra-cabeças de fusão de números.

### 🛠️ Autor

<p align="center">
  Developed with 💜 by <b>onyrius</b> - Suelen Arruda
</p>

---

## 🚀 Tecnologias & Arquitetura

O projeto adota uma divisão clara de responsabilidades para isolar regra de negócio, orquestração de casos de uso, persistência e interface:

* **Flutter & Dart:** desenvolvimento cross-platform.
* **BLoC/Cubit:** gerenciamento de estado da partida e fluxo de interação da UI.
* **Clean Architecture:** separação entre domínio, aplicação, infraestrutura e apresentação.
* **DDD:** entidades, value objects, serviços de domínio e contratos de repositório.
* **Testes automatizados:** cobertura para domínio, casos de uso, widgets, Cubit e infraestrutura.
* **Flutter Lints:** análise estática baseada no pacote `flutter_lints`.

---

## 📦 Estrutura do Projeto

A estrutura de pastas reflete a separação por camadas:

```text
lib/
├── features/
│   ├── core/              # Constantes globais de UI, cores, textos e dimensões
│   ├── application/       # Casos de uso que orquestram regras de domínio
│   ├── domain/            # Entidades, value objects, contratos e serviços puros
│   └── presentation/      # Screens, widgets e Cubit/State da interface
├── infrastructure/        # Implementações externas, como persistência local
└── main.dart              # Bootstrap da aplicação e injeção das dependências

test/
├── features/              # Testes das camadas de feature
└── infrastructure/        # Testes de adaptadores de infraestrutura
```

---

## ▶️ Como Rodar

```bash
flutter pub get
flutter run
```

## ✅ Qualidade

```bash
flutter analyze
flutter test
```
