# 🧩 Number Merge Puzzle (  WIP )

Uma aplicação mobil desenvolvida para o aprofundamento em Flutter, DDD e Clean Code, focada em mecânicas de quebra-cabeça e fusão de números.
---

## 🚀 Tecnologias & Arquitetura

O projeto adota uma divisão clara de responsabilidades para isolar a lógica de negócio da camada de interface:

*   **Flutter & Dart:** Desenvolvimento cross-platform nativo.
*   **BLoC Pattern (State Management):** Fluxo de dados unidirecional e previsível para estados complexos do tabuleiro.
*   **Clean Architecture:** Separação rígida em camadas (`Domain`, `Data`, e `Presentation`).
*   **Very Good Analysis:** Padrões estritos de linting e análise estática de código.

---

## 📦 Estrutura do Projeto

A estrutura de pastas reflete a separação por Features e Camadas de Domínio:

```text
lib/
├── app/                  # Configurações globais, temas e rotas
└── features/
    └───├── data/         # Repositórios e fontes de dados (Locais/Remotos)
        ├── domain/       # Entidades puras, Casos de Uso (Use Cases) e contratos
        └── presentation/ # Widgets UI, Páginas e BLoCs (State, Event, Bloc)