# ARCH.md — mobile_arquitetura_01

## Fluxo da aplicação

A ideia foi separar bem cada parte do código pra nenhuma camada fazer coisa que não é dela. O fluxo funciona assim:

```
UI (ProductListPage)
  │
  ▼
ViewModel (ProductViewModel)
  │  — não acessa Widget nem BuildContext
  │  — avisa a UI quando o estado muda via ChangeNotifier
  ▼
Repository Interface (ProductRepository)   ← domain (só o contrato)
  │
  ▼
RepositoryImpl (ProductRepositoryImpl)     ← data (a implementação de fato)
  │
  ▼
RemoteDataSource (ProductRemoteDatasource) ← data (quem faz o HTTP)
  │
  ▼
AppHttpClient (core/network)               ← utilitário genérico de rede
  │
  ▼
FakeStore API — https://fakestoreapi.com/products
```

## Estrutura de pastas

```
lib/
├── core/
│   └── network/
│       └── http_client.dart          # cliente HTTP que uso em qualquer feature
├── features/
│   └── products/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── product_remote_datasource.dart
│       │   ├── models/
│       │   │   └── product_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── product.dart
│       │   └── repositories/
│       │       └── product_repository.dart   # interface abstrata
│       └── presentation/
│           ├── pages/
│           │   └── product_list_page.dart
│           ├── viewmodels/
│           │   └── product_viewmodel.dart
│           └── widgets/
│               └── product_card.dart
└── main.dart
```

## Por que essa estrutura?

Optei pelo padrão **feature-first** junto com separação em camadas porque faz sentido agrupar tudo que é de "products" num lugar só. Se eu precisasse adicionar um carrinho ou autenticação, bastaria criar `features/cart/` ou `features/auth/` sem bagunçar o que já existe.

Outra vantagem é que o domínio fica isolado — a entidade `Product` não sabe nada de Flutter ou HTTP, o que facilita testar e reutilizar.

## Responsabilidade de cada parte

| Camada | Arquivo | O que faz |
|--------|---------|-----------|
| `core/network` | `http_client.dart` | Faz as requisições HTTP e lança erro se não der 200 |
| `domain/entities` | `product.dart` | Define o que é um produto no app, sem depender de nada |
| `domain/repositories` | `product_repository.dart` | Contrato que define o método `getProducts()` |
| `data/models` | `product_model.dart` | Converte o JSON da API em objeto `Product` |
| `data/datasources` | `product_remote_datasource.dart` | Chama a API e retorna os modelos |
| `data/repositories` | `product_repository_impl.dart` | Implementa o contrato, decide de onde vêm os dados |
| `presentation/viewmodels` | `product_viewmodel.dart` | Controla o estado da tela (loading, sucesso, erro) |
| `presentation/pages` | `product_list_page.dart` | Monta a tela e reage ao estado do ViewModel |
| `presentation/widgets` | `product_card.dart` | Card reutilizável que exibe um produto |

## Regras que segui

- A UI não chama HTTP diretamente
- O ViewModel não conhece nenhum Widget ou BuildContext
- O Repository é o único ponto de acesso aos dados
- Domain não depende de nada externo (Flutter, http, etc.)