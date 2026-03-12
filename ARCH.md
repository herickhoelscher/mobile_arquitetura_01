# ARCH.md — mobile_arquitetura_01

## Diagrama do Fluxo

```
UI (ProductListPage)
  │
  ▼
ViewModel (ProductViewModel)
  │  — não conhece Widgets nem BuildContext
  │  — expõe estado via ChangeNotifier
  ▼
Repository Interface (ProductRepository)   ← domain (contrato)
  │
  ▼
RepositoryImpl (ProductRepositoryImpl)     ← data (implementação)
  │
  ▼
RemoteDataSource (ProductRemoteDatasource) ← data (HTTP)
  │
  ▼
AppHttpClient (core/network)               ← utilitário de rede
  │
  ▼
FakeStore API — https://fakestoreapi.com/products
```

## Estrutura de Pastas

```
lib/
├── core/
│   └── network/
│       └── http_client.dart          # cliente HTTP reutilizável
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
│       │       └── product_repository.dart   # interface (abstract)
│       └── presentation/
│           ├── pages/
│           │   └── product_list_page.dart
│           ├── viewmodels/
│           │   └── product_viewmodel.dart
│           └── widgets/
│               └── product_card.dart
└── main.dart
```

## Justificativa da Estrutura

Adotamos a arquitetura **feature-first** combinada com **Clean Architecture em camadas**, pois:

- Agrupa tudo relacionado a "products" em um único lugar, facilitando manutenção.
- Permite escalar para novas features (ex: `features/cart/`, `features/auth/`) sem conflito.
- Isola o domínio de frameworks externos (HTTP, Flutter), tornando as entidades testáveis.

## Decisões de Responsabilidade

| Camada           | Arquivo(s)                          | Responsabilidade                                         |
|------------------|-------------------------------------|----------------------------------------------------------|
| `core/network`   | `http_client.dart`                  | Encapsula chamadas HTTP, lança exceção em erros          |
| `domain/entities`| `product.dart`                      | Define a entidade pura, sem dependência de framework     |
| `domain/repositories` | `product_repository.dart`      | Contrato (interface) que o ViewModel enxerga             |
| `data/models`    | `product_model.dart`                | Converte JSON → entidade (`fromJson`)                    |
| `data/datasources` | `product_remote_datasource.dart`  | Faz a requisição HTTP e retorna modelos                  |
| `data/repositories` | `product_repository_impl.dart`  | Implementa o contrato; escolhe fonte de dados            |
| `presentation/viewmodels` | `product_viewmodel.dart`  | Gerencia estado; sem Widget/BuildContext                 |
| `presentation/pages` | `product_list_page.dart`       | Exibe dados; sem HTTP/SharedPreferences direto           |
| `presentation/widgets` | `product_card.dart`          | Widget reutilizável de exibição de produto               |

## Regras respeitadas

- ✅ UI não chama HTTP diretamente
- ✅ ViewModel sem Widget/BuildContext
- ✅ Repository centraliza o acesso a dados
- ✅ Domain não depende de nada externo (Flutter, http, etc.)
