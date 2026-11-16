# Plano de 30 dias

Cada dia é **uma tarefa de ~30 minutos** e vira **uma issue** no GitHub.
Feche a issue no commit (`git commit -m "feat(api): endpoint /health (closes #1)"`).

Regra de ouro: **terminou em 30 min? commita. Não terminou? commita o que tem** (com testes passando) e anota no `LOG.md` o que falta. Um dia "pequeno" é melhor que um dia pulado.

---

## Semana 1: API em Go (`api/`)

| Dia | Tarefa | Pronto quando... |
|----:|--------|------------------|
| 1 | Criar o módulo Go (`go mod init`), `cmd/api/main.go` com `GET /health` e um `Makefile` (`run`, `test`). | `make run` sobe e `curl localhost:8080/health` responde `{"status":"ok"}` |
| 2 | Pacote `shortcode`: gerar códigos base62 aleatórios de 7 caracteres. | Testes de tamanho, alfabeto e unicidade (10k códigos sem colisão) |
| 3 | Interface `Store` (`Save`, `Get`, `IncrementClicks`) + implementação em memória com `sync.RWMutex`. | Testes, incluindo um teste concorrente com `-race` |
| 4 | `POST /api/links` recebe `{"url": "..."}`, valida a URL e devolve `{"code","short_url"}`. | Retorna 400 para URL inválida, 201 no sucesso, com testes `httptest` |
| 5 | `GET /{code}` faz redirect 302 e incrementa os cliques. Código inexistente dá 404. | Testes dos dois cenários |
| 6 | `GET /api/links/{code}` devolve URL original, cliques e `created_at`. `GET /api/links` lista todos. | Testes + exemplo de `curl` no README da pasta |
| 7 | Persistência em SQLite (`modernc.org/sqlite`, sem CGO) implementando `Store`. Flag `-db` escolhe memória ou arquivo. | Os mesmos testes da store rodam nas duas implementações |

## Semana 2: CLI e relatórios em Python (`cli/`)

| Dia | Tarefa | Pronto quando... |
|----:|--------|------------------|
| 8 | Projeto com `pyproject.toml` (uv ou pip), pacote `linkly_cli`, comando `linkly shorten <url>` com `httpx` + `typer`. | `linkly shorten https://go.dev` imprime a URL curta |
| 9 | Comando `linkly stats <code>` com saída formatada (`rich`). | Mostra URL, cliques e data numa tabela |
| 10 | Testes com `pytest` mockando a API (`respx`). | Cobertura dos dois comandos, incluindo erro de rede |
| 11 | Comando `linkly top --limit 10`: ranking dos links mais clicados. | Ordenação testada |
| 12 | Comando `linkly export --format csv\|json` para arquivo. | Testa o conteúdo gerado |
| 13 | `ruff` + `mypy --strict` configurados no `pyproject.toml`, e corrigir o que aparecer. | `ruff check` e `mypy` limpos |
| 14 | GitHub Actions: workflow com jobs `go` (vet + test -race) e `python` (ruff, mypy, pytest). | Badge verde no README |

## Semana 3: Frontend em Angular (`web/`)

| Dia | Tarefa | Pronto quando... |
|----:|--------|------------------|
| 15 | `ng new web` (standalone, SCSS) + `proxy.conf.json` apontando `/api` para a API Go. Habilitar CORS na API se precisar. | `ng serve` abre e chama `/health` |
| 16 | Tipos `Link`/`LinkStats` e `LinksService` com `HttpClient`. | Teste do service com `HttpTestingController` |
| 17 | Formulário reativo para encurtar URL, com validação e estado de loading/erro. | Mostra a URL curta após enviar |
| 18 | Componente de lista de links (consome `GET /api/links`), usando signals. | Lista atualiza após criar um link |
| 19 | Botão "copiar" (Clipboard API) + feedback visual. | Funciona e tem teste do componente |
| 20 | Rota `/stats/:code` com página de detalhes do link. | Navegação da lista para os detalhes |
| 21 | Testes de componente do formulário (válido, inválido, erro da API) + job `web` no CI. | CI roda `ng test --watch=false` e `ng build` |

## Semana 4: Worker .NET, extensão JS e entrega (`checker/`, `extension/`)

| Dia | Tarefa | Pronto quando... |
|----:|--------|------------------|
| 22 | `dotnet new worker -n Linkly.Checker` + solução `.sln` + projeto de testes xUnit. | `dotnet build` e `dotnet test` passam |
| 23 | Worker busca `GET /api/links` a cada N minutos (`IOptions<CheckerOptions>`) e faz `HEAD` em cada URL. | Loga links quebrados (status >= 400 ou timeout) |
| 24 | Testes do checker com `HttpMessageHandler` fake. | Casos: OK, 404, timeout |
| 25 | Extensão de navegador (Manifest V3, JS puro): popup com botão "Encurtar esta aba". | Carrega como "unpacked" no Chrome |
| 26 | Extensão chama a API, mostra a URL curta e copia para a área de transferência. Opções para configurar a URL da API. | Funciona ponta a ponta |
| 27 | `Dockerfile` multi-stage para `api` (distroless) e `web` (nginx). | `docker build` dos dois |
| 28 | `docker-compose.yml` com api + web + checker, com volume para o SQLite. | `docker compose up` sobe tudo |
| 29 | Job `dotnet` no CI + workflow que valida o build das imagens. | CI completo verde |
| 30 | README final: diagrama de arquitetura (Mermaid), GIF/screenshot, como rodar, e uma retrospectiva no `LOG.md`. | Repo pronto para mostrar no portfólio |

---

## Dias corridos (plano B)

Tem dia que 30 minutos não rolam. Nesses dias, faça **uma** destas (5–10 min) em vez de pular:

- Escreva um teste que faltava.
- Melhore uma mensagem de erro ou um log.
- Atualize o `README` de uma pasta.
- Registre no `LOG.md` algo que você aprendeu ("TIL").
- Rode `go vet`, `ruff`, `dotnet format` e corrija um aviso.

## Depois dos 30 dias

Ideias para continuar: autenticação (JWT) para links por usuário, rate limiting na API, QR code para cada link, expiração de links, métricas Prometheus + Grafana no compose, deploy (Fly.io / Render), um segundo projeto com outra stack principal.
