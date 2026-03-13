# mobile_arquitetura_02

Evolução da Atividade 1, adicionando estados explícitos na UI, tratamento de erros e cache local.

## Como rodar

```bash
flutter pub get
flutter run
```

## O que foi adicionado nessa versão

- **Estados da interface**: a tela mostra loading, erro ou lista de produtos de forma explícita
- **Tratamento de erros**: erros de rede e servidor são capturados e informados ao usuário
- **Cache local**: os produtos carregados são salvos com SharedPreferences. Se a API cair, o app usa os dados salvos

---

## Questionário de Reflexão

### 1. Em qual camada foi implementado o cache? Por que essa decisão é adequada?

O cache foi implementado na camada **data**, mais especificamente no `ProductLocalDatasource` e coordenado pelo `ProductRepositoryImpl`.

Essa decisão faz sentido porque o Repository é quem decide de onde os dados vêm. Ele tenta a API primeiro e, se falhar, cai no cache. A UI e o ViewModel não precisam saber dessa lógica, eles só pedem os dados e recebem. Se eu precisasse trocar a forma de cachear (de SharedPreferences para SQLite, por exemplo), mexeria só nessa camada sem afetar nada mais.

### 2. Por que o ViewModel não deve fazer chamadas HTTP diretamente?

Porque o ViewModel é responsável por gerenciar o estado da interface, não por buscar dados. Se ele fizesse HTTP direto, estaria acumulando duas responsabilidades, o que dificulta manutenção e testes.

Além disso, se a API mudar ou eu quiser trocar a fonte de dados, teria que mexer no ViewModel junto, quando na verdade isso é responsabilidade da camada de dados.

### 3. O que poderia acontecer se a interface acessasse o DataSource diretamente?

A UI ficaria acoplada à implementação de dados. Se eu trocasse a API ou adicionasse cache, teria que alterar código na tela também. Fora que a lógica de "tentar API, cair no cache" estaria espalhada pela interface, tornando o código difícil de entender e manter.

Também ficaria impossível testar a UI de forma isolada, já que ela dependeria diretamente de chamadas HTTP.

### 4. Como essa arquitetura facilita a substituição da API por um banco de dados local?

Bastaria criar um novo `ProductLocalDatabaseDatasource` (usando SQLite, por exemplo) e alterar o `ProductRepositoryImpl` para usá-lo. A interface, o ViewModel e até o contrato do repositório continuariam intactos. Nenhuma outra camada precisaria ser tocada.

---

## Arquitetura

```
UI (ProductListPage)
  ↓
ViewModel (ProductViewModel)
  ↓
Repository Interface (ProductRepository)
  ↓
ProductRepositoryImpl
  ├── ProductRemoteDatasource  ← tenta primeiro (HTTP)
  └── ProductLocalDatasource  ← fallback (cache SharedPreferences)
```

Veja o [ARCH.md](./ARCH.md) para mais detalhes.
