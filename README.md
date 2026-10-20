# AmparaPet — Back-end

Sistema de adoção de animais do **Abrigo Toca de Assis** (Ivaiporã - PR).
Projeto Integrador — Análise e Desenvolvimento de Sistemas, UNIVALE 2026.

| Camada | Tecnologia |
|--------|------------|
| Back-end | Python 3.11+ com **FastAPI**, uma API REST que responde em JSON |
| Banco de dados | **MySQL 8.4** portátil, dentro da própria pasta do projeto, sem instalação |
| Interface de teste | HTML + JavaScript simples em `frontend-teste/`, só para testar a API |
| Front-end oficial | Feito à parte, por outra pessoa da equipe. Ele consome esta API. |

---

## Sumário

1. [Início rápido](#1-início-rápido)
2. [O que foi feito](#2-o-que-foi-feito)
3. [Como o MySQL portátil funciona](#3-como-o-mysql-portátil-funciona)
4. [Como os arquivos .bat funcionam](#4-como-os-arquivos-bat-funcionam)
5. [Outras formas de rodar (VS Code e terminal)](#5-outras-formas-de-rodar-vs-code-e-terminal)
6. [Banco de dados](#6-banco-de-dados)
7. [Guia da API para o front-end](#7-guia-da-api-para-o-front-end)
8. [Decisões técnicas](#8-decisões-técnicas)
9. [Testes automatizados](#9-testes-automatizados)
10. [Configuração e produção](#10-configuração-e-produção)
11. [Estrutura de pastas](#11-estrutura-de-pastas)
12. [Problemas comuns](#12-problemas-comuns)

---

## 1. Início rápido

Pré-requisito: **Python 3.11 ou mais novo** instalado e no PATH. Durante a instalação do Python, marque "Add python.exe to PATH". Não é preciso instalar MySQL, XAMPP nem nenhum programa extra.

1. Dê dois cliques em **`iniciar.bat`**.
   A primeira execução demora alguns minutos, porque instala as dependências Python, baixa o MySQL (~270 MB) e cria o banco. Nas próximas vezes, o sistema sobe em segundos.
2. Com a janela preta aberta, acesse:
   - **Interface de teste:** http://localhost:8000/teste/
   - **Documentação da API (Swagger):** http://localhost:8000/docs
3. Entre na área administrativa com `admin@amparapet.local` / `trocar123`. Esses dados vêm do `.env`; **troque a senha** depois do primeiro login.
4. Para desligar tudo, dê dois cliques em **`parar.bat`**.

Para popular o banco com 6 animais de exemplo (com fotos geradas automaticamente), rode isto com o banco ligado e ainda sem animais:

```bash
cd backend && ..\.venv\Scripts\python -m app.init_db --exemplos
```

---

## 2. O que foi feito

Tudo foi implementado a partir da documentação do Projeto Integrador (RF01–RF14 e RNF01–RNF11).

### Requisitos funcionais

| Requisito | Como foi implementado |
|-----------|-----------------------|
| **RF01** Cadastro de animais | `POST /api/admin/animais`. Além dos campos pedidos, foram incluídos **sexo**, **vacinas detalhadas** e **necessidades especiais**. Espécie: Cão/Gato. Porte: Pequeno/Médio/Grande. A idade é guardada como **data de nascimento aproximada** e calculada automaticamente ("2 anos e 3 meses"), então nunca fica desatualizada. |
| **RF02** Vitrine pública | `GET /api/animais`, sem login. Mostra só animais Disponíveis e Em processo, com paginação. |
| **RF03** Página do animal | `GET /api/animais/{id}`, com todos os dados, as fotos e os links prontos. |
| **RF04** Fotos | Envio de várias fotos de uma vez (JPG, PNG ou WEBP, até 5 MB cada), remoção e reordenação. O servidor confere se o arquivo é mesmo uma imagem, corrige a rotação de fotos de celular, converte para WEBP comprimido (máx. 1600 px) e gera uma **miniatura** de 400 px. A pré-visualização antes de enviar é feita no navegador. |
| **RF05** Filtros | Espécie, porte, sexo, castrado, vacinado, status e busca por nome, raça ou cor. |
| **RF06** Interesse | Botão "Tenho interesse" abre o WhatsApp do abrigo com uma mensagem pronta citando o nome e o código do animal. Cada clique é **contado** (sem coletar dados pessoais) e aparece no painel. |
| **RF07** Área administrativa | Login por e-mail e senha, logout, sessão com validade de 8 horas e bloqueio das rotas para quem não está logado. Vários administradores, todos com o mesmo nível. |
| **RF08** Status | Disponível, Em processo e Adotado. Adotados somem da vitrine mas continuam salvos. Toda mudança fica no **histórico**, com data, autor e observação, e o animal pode ser reativado. |
| **RF09** Edição e exclusão | Todos os campos são editáveis. A exclusão é definitiva e apaga também fotos e histórico. A confirmação "tem certeza?" fica no front-end. |
| **RF10** Armazenamento | MySQL, com datas de cadastro e de atualização em todos os registros. |
| **RF11** Compartilhamento | A API devolve o link da página do animal (para copiar) e um link de compartilhamento pelo WhatsApp. |
| **RF12 / RF13** Como adotar e endereço | Endereço, horários, WhatsApp, passo a passo e documentos exigidos ficam no banco e são **editáveis pela área administrativa**, sem mexer no código. |
| **RF14** Painel | Total de animais, disponíveis, em processo, adotados, cliques de interesse e os 5 animais mais procurados. |

### Requisitos não funcionais atendidos pelo back-end

| Requisito | Como |
|-----------|------|
| **RNF04** Desempenho | Fotos comprimidas em WEBP com miniaturas, índices nos campos usados nos filtros e paginação na vitrine. |
| **RNF05** Segurança | Senhas com **bcrypt**; no banco, os tokens de sessão ficam só como hash; bloqueio de 15 minutos após 5 erros de login; logout encerra a sessão na hora; validação de todos os dados recebidos. O HTTPS fica a cargo da hospedagem. |
| **RNF06** Manutenibilidade | Código separado por responsabilidade (rotas, regras, banco, segurança, imagens), testes automatizados e esta documentação. |
| **RNF07** Qualidade das imagens | Redimensionamento sem distorção (mantém a proporção) e miniaturas otimizadas. |
| **RNF11** Tempo de resposta | Consultas indexadas e fotos servidas diretamente como arquivos estáticos. |

RNF01–RNF03 e RNF08–RNF10 (usabilidade, responsividade, acessibilidade, SEO) dependem do **front-end oficial**.

### Entregas

- API completa, com documentação interativa (Swagger) em `/docs`, que atende ao item "Documentar endpoints da API" do checklist;
- banco MySQL portátil e scripts para ligar, desligar, testar e abrir o console;
- documentação do banco com DER e dicionário de dados em [`docs/banco-de-dados.md`](docs/banco-de-dados.md), que atende ao item "MER/DER" do checklist;
- 17 testes automatizados cobrindo os requisitos;
- interface de teste simples (vitrine, página do animal, "como adotar" e área administrativa completa).

---

## 3. Como o MySQL portátil funciona

O MySQL normalmente é instalado no Windows como um **serviço** que liga junto com o computador. Aqui foi usada a versão **ZIP "sem instalador"** oficial da Oracle (MySQL Community 8.4.13 LTS), que roda direto de uma pasta. Por isso:

- não precisa de instalação nem de permissão de administrador;
- não entra em conflito com outro MySQL, XAMPP ou WAMP que já exista na máquina;
- a pasta do projeto pode ser copiada para outro computador ou pendrive e continua funcionando;
- o MySQL só roda quando você manda (pelo `iniciar.bat`) e para quando você manda (pelo `parar.bat`).

### O que fica dentro de `mysql/`

```
mysql/
  server/      programas do MySQL (mysqld.exe, mysql.exe, mysqldump.exe...)
  data/        os DADOS do banco (tabelas, registros). Criada na primeira execução.
  my.ini       configuração, gerada automaticamente a cada execução
  mysql.log    log do servidor (consulte se o banco não ligar)
```

### Passo a passo do que o script `scripts/banco.ps1` faz

Os `.bat` chamam este script. Ele faz o seguinte:

1. **Baixa o MySQL, se precisar.** Se `mysql/server/` não existir (por exemplo, logo depois de clonar o repositório do GitHub), baixa o ZIP oficial de `cdn.mysql.com` e confere a integridade pelo MD5 publicado pela Oracle. Depois extrai o ZIP e apaga os arquivos de depuração (`.pdb`), o que reduz a pasta de ~1,2 GB para ~420 MB.
2. **Gera o `my.ini`** com os caminhos da pasta atual. Como o arquivo é refeito toda vez, o projeto pode mudar de lugar (outro disco, outro computador) sem quebrar. Configurações principais:
   - `port=3307`, para não brigar com um MySQL "normal", que usa a 3306;
   - `bind-address=127.0.0.1`, para aceitar só conexões do próprio computador (ninguém na rede consegue acessar);
   - `character-set-server=utf8mb4`, para acentos e emojis.
3. **Na primeira vez**, roda `mysqld --initialize-insecure`, que cria a pasta `data/` com as tabelas internas do MySQL e um usuário `root` **sem senha**. Como o servidor só aceita conexões locais, isso é aceitável para desenvolvimento.
4. **Liga o servidor** (`mysqld.exe`) em segundo plano, numa janela oculta, e espera ele responder na porta 3307.
5. **Na primeira vez**, também cria:
   - o banco `amparapet` (dados do sistema);
   - o banco `amparapet_teste` (usado só pelos testes automatizados);
   - o usuário `amparapet` com a senha `amparapet`, que tem acesso só a esses dois bancos. A API usa esse usuário, nunca o `root`.

As **tabelas** do sistema (animais, fotos etc.) não são criadas pelo script. A API as cria sozinha quando sobe, junto com o administrador inicial e os dados padrão do abrigo.

Para **desligar**, o script envia o comando `mysqladmin shutdown`, que encerra o MySQL corretamente, salvando tudo. Não é preciso matar o processo.

### Por que a pasta `mysql/` não vai para o GitHub

São ~420 MB de programas, mais os dados locais de cada pessoa. Ela está no `.gitignore`. Quem clonar o repositório roda o `iniciar.bat` e o script baixa o MySQL automaticamente (passo 1).

---

## 4. Como os arquivos .bat funcionam

### Por que existem

Para acessar o `localhost:8000`, **dois programas** precisam estar rodando:

1. o **MySQL** (`mysqld.exe`), que guarda os dados;
2. a **API** (`uvicorn`, o servidor web do Python), que responde no `localhost:8000`.

Sem os `.bat`, seria preciso abrir um editor como o VS Code, ativar o ambiente Python, ligar o MySQL e digitar o comando do servidor no terminal. Os `.bat` fazem tudo isso com dois cliques, sem precisar de nenhum editor aberto. Assim, qualquer pessoa da equipe, ou o próprio abrigo, consegue rodar.

### O que cada um faz

| Arquivo | O que faz, passo a passo |
|---------|--------------------------|
| **`iniciar.bat`** | 1. Se não existir o ambiente Python (`.venv`), chama o `instalar.bat`. 2. Se não existir o `.env`, copia o `.env.example`. 3. Liga o MySQL (`scripts\banco.ps1 iniciar`), baixando-o se necessário. 4. Sobe a API com `uvicorn --reload` em http://localhost:8000. **A janela preta é a API**: enquanto ela estiver aberta, o site funciona. Com `--reload`, a API reinicia sozinha quando um arquivo `.py` é alterado. |
| **`parar.bat`** | 1. Encerra a API (`scripts\api.ps1 parar`): procura os processos Python rodando `app.main:app` e os fecha, junto com os processos filhos. 2. Desliga o MySQL corretamente (`scripts\banco.ps1 parar`). |
| **`instalar.bat`** | Cria o ambiente virtual Python (`.venv`) e instala as bibliotecas de `backend\requirements.txt`. Normalmente é chamado sozinho pelo `iniciar.bat`; rode manualmente só se mudar o `requirements.txt`. |
| **`testar.bat`** | Liga o MySQL, se estiver desligado, e roda os 17 testes automatizados no banco `amparapet_teste`, sem tocar nos dados reais. |
| **`mysql.bat`** | Abre o console SQL do MySQL já conectado ao banco `amparapet`, para rodar comandos como `SELECT * FROM animais;`. Digite `exit` para sair. |

### Detalhes importantes

- **Fechar a janela do `iniciar.bat`** (ou apertar Ctrl+C nela) para **só a API**. O MySQL continua ligado em segundo plano. Para desligar os dois, use o **`parar.bat`**.
- **Se o localhost abre mas dá erro**, a API está rodando mas o MySQL está desligado. Rode o `iniciar.bat` de novo, que liga o que estiver faltando, ou o `parar.bat` para desligar tudo.
- Rodar o `iniciar.bat` com o MySQL já ligado não causa problema: o script percebe e só avisa "MySQL ja esta rodando".
- Os `.bat` chamam scripts PowerShell com `-ExecutionPolicy Bypass`. Isso libera **apenas aquele script**, sem mudar nenhuma configuração do Windows.
- Os `.bat` sempre entram na pasta onde estão (`cd /d "%~dp0"`). Por isso funcionam com dois cliques, pelo terminal ou por atalho.

---

## 5. Outras formas de rodar (VS Code e terminal)

Os `.bat` são a forma mais simples, mas não a única. Quem preferir trabalhar no editor tem estas opções.

### Pelo VS Code

O projeto já vem com a pasta `.vscode/` configurada. Abra a **pasta `AMPARAPET`** inteira no VS Code (Arquivo → Abrir Pasta) e instale a extensão **Python**, da Microsoft.

- **F5 (Executar e Depurar)** → "AmparaPet: API (depurar)": liga o MySQL e sobe a API com o **depurador**, permitindo usar breakpoints. Para parar, use o botão vermelho do depurador. O MySQL continua ligado; desligue pela tarefa "parar tudo" ou pelo `parar.bat`.
- **Terminal → Executar Tarefa...**, com as tarefas prontas:
  - `AmparaPet: iniciar tudo (igual ao iniciar.bat)`
  - `AmparaPet: iniciar banco`
  - `AmparaPet: parar tudo (API + banco)`
  - `AmparaPet: rodar testes`
- A aba **Testes** (ícone de frasco) também encontra e roda os testes.
- O interpretador Python do `.venv` já vem selecionado (`.vscode/settings.json`).

### Pelo terminal (qualquer editor)

```bash
instalar.bat
```

```bash
powershell -ExecutionPolicy Bypass -File scripts\banco.ps1 iniciar
```

```bash
cd backend && ..\.venv\Scripts\python -m uvicorn app.main:app --reload --port 8000
```

O primeiro comando é necessário só na primeira vez. O segundo liga o MySQL. O terceiro sobe a API, que fica rodando até Ctrl+C. O `banco.ps1` também aceita `parar`, `status` e `console`.

### Usando outro MySQL (XAMPP, instalado, nuvem)

O MySQL portátil é só uma conveniência. Para usar outro, crie o banco e o usuário nele e altere `DATABASE_URL` no `.env`. Por exemplo, para o XAMPP na porta 3306:

```
DATABASE_URL=mysql+pymysql://usuario:senha@127.0.0.1:3306/amparapet?charset=utf8mb4
```

As tabelas são criadas automaticamente na primeira vez que a API sobe.

---

## 6. Banco de dados

**Documentação completa, com DER, dicionário de dados, relacionamentos e regras: [`docs/banco-de-dados.md`](docs/banco-de-dados.md)**

![DER](docs/der.png)

| Tabela | Conteúdo |
|--------|----------|
| `animais` | Dados dos animais, status e contador de cliques em "tenho interesse" |
| `fotos` | Fotos de cada animal; a de menor `ordem` é a principal |
| `historico_status` | Toda mudança de status, com data, usuário e observação |
| `usuarios` | Administradores (senha com bcrypt) |
| `sessoes` | Sessões de login ativas (só o hash do token) |
| `tentativas_login` | Registro de logins, usado para bloquear após 5 erros seguidos |
| `configuracoes` | Dados do abrigo editáveis: endereço, horários, WhatsApp, textos |

| Acesso | Valor |
|--------|-------|
| Servidor | `127.0.0.1`, porta **3307** |
| Banco | `amparapet` |
| Usuário / senha | `amparapet` / `amparapet` (o `root` não tem senha e só acessa localmente) |

Também dá para abrir o banco em programas como o MySQL Workbench, o DBeaver ou o HeidiSQL com esses dados, desde que o MySQL esteja ligado.

- **Zerar tudo:** `parar.bat`, apague as pastas `mysql\data\` e `uploads\` e rode o `iniciar.bat`.
- **Backup:** veja a seção "Operação" em [`docs/banco-de-dados.md`](docs/banco-de-dados.md#6-operação).

---

## 7. Guia da API para o front-end

A documentação completa, com todos os campos, exemplos e o botão "Try it out" para testar, está em **http://localhost:8000/docs**.

### Rotas públicas (sem login)

| Método | Rota | Uso |
|--------|------|-----|
| GET  | `/api/animais` | Vitrine. Filtros: `especie`, `porte` (pode repetir), `sexo`, `castrado`, `vacinado`, `status`, `busca`, `pagina`, `por_pagina`. Adotados nunca aparecem. |
| GET  | `/api/animais/{id}` | Página do animal, com `fotos` e `links` (página, WhatsApp de interesse, compartilhar) |
| POST | `/api/animais/{id}/interesse` | Conta o clique e devolve `whatsapp_url` para abrir |
| GET  | `/api/abrigo` | Endereço, horários, WhatsApp, "como adotar", documentos |
| GET  | `/api/opcoes` | Valores aceitos (CAO, GATO, PEQUENO...) com rótulos em português |

### Rotas administrativas

Faça `POST /api/auth/login` com `{"email": "...", "senha": "..."}` e envie o `token` recebido em todas as chamadas seguintes, no cabeçalho:

```
Authorization: Bearer <token>
```

Uma resposta **401** significa que a sessão expirou: mande o usuário para a tela de login.

| Método | Rota | Uso |
|--------|------|-----|
| POST   | `/api/auth/logout` | Sair |
| GET    | `/api/auth/eu` | Usuário logado |
| PUT    | `/api/auth/senha` | Trocar a própria senha |
| GET    | `/api/admin/painel` | Totais (RF14) |
| GET/POST | `/api/admin/animais` | Listar todos (inclusive adotados) / cadastrar |
| GET/PATCH/DELETE | `/api/admin/animais/{id}` | Ver / editar (só os campos enviados) / excluir |
| PATCH  | `/api/admin/animais/{id}/status` | `{"status": "ADOTADO", "observacao": "..."}`. Para reativar, volte para `DISPONIVEL`. |
| GET    | `/api/admin/animais/{id}/historico` | Histórico de status |
| POST   | `/api/admin/animais/{id}/fotos` | `multipart/form-data`, campo `fotos` (pode repetir). JPG, PNG ou WEBP de até 5 MB cada. |
| PUT    | `/api/admin/animais/{id}/fotos/ordem` | `{"ids": [3, 1, 2]}`. A primeira vira a principal. |
| DELETE | `/api/admin/fotos/{id}` | Remover foto |
| GET/PUT | `/api/admin/abrigo` | Dados do abrigo |
| GET/POST/PATCH/DELETE | `/api/admin/usuarios` | Administradores |

### Observações

- **Idade:** envie `data_nascimento` aproximada (`AAAA-MM-01` se só souber mês/ano). A API devolve `idade` já em texto.
- **Fotos:** use `miniatura_url` na vitrine e `url` na página do animal.
- **Exclusão:** é definitiva. Peça confirmação ao usuário antes de chamar o `DELETE`.
- **Links do WhatsApp e de compartilhamento:** são montados com o campo `url_pagina_animal` dos dados do abrigo (com `{id}`). Quando o front-end oficial estiver no ar, ajuste esse campo na área administrativa para o endereço real, por exemplo `https://amparapet.com/animal.html?id={id}`.
- **WhatsApp do abrigo:** enquanto o número não for preenchido na área administrativa, `whatsapp_interesse` vem `null`.
- **Exemplo de código:** a interface de teste (`frontend-teste/`) mostra como chamar cada rota em JavaScript puro. O arquivo `comum.js` tem a função `api()`, que já envia o token.

---

## 8. Decisões técnicas

| Decisão | Motivo |
|---------|--------|
| **FastAPI** como framework | Gera a documentação Swagger automaticamente e valida os dados de entrada. É simples para uma API JSON consumida por um front-end separado. |
| **SQLAlchemy** para acessar o banco | As tabelas são definidas em Python (`models.py`) e criadas automaticamente. Também protege contra SQL injection. |
| **Sessões com token guardado no banco**, em vez de JWT | Permite logout de verdade e permite derrubar as sessões de um usuário desativado na hora. |
| **Fotos em arquivos**, só o caminho no banco | Mantém o banco leve e as fotos são servidas direto pelo servidor web, o que é mais rápido. |
| **Conversão para WEBP** | Arquivos bem menores que JPG/PNG com a mesma qualidade (RNF04). |
| **Data de nascimento** em vez de idade | A idade se atualiza sozinha. |
| **Contador de cliques**, sem formulário de interesse | Não coleta dados pessoais (LGPD) e o contato continua pelo WhatsApp, como o abrigo pediu. |
| **Dados do abrigo em tabela chave-valor** | O endereço e o WhatsApp do abrigo ainda não estavam definidos; o abrigo pode editá-los sem programador. |
| **Valores fixos (ENUM) sem acento** (`CAO`, `MEDIO`) | Evitam diferença de grafia entre front-end e banco. Os rótulos com acento vêm de `/api/opcoes`. |

---

## 9. Testes automatizados

```bash
testar.bat
```

São 17 testes em `backend/tests/` (pytest). Eles cobrem login e bloqueio, cadastro e validações, status e histórico, upload (formatos, tamanho, miniatura, ordem), filtros, links do WhatsApp, painel, dados do abrigo e gerenciamento de administradores. Os testes usam o banco **`amparapet_teste`** e uma pasta temporária para as fotos, então os dados reais não são tocados.

---

## 10. Configuração e produção

As configurações ficam no arquivo `.env`, criado automaticamente a partir do [`.env.example`](.env.example). O `.env` **não vai para o GitHub**, porque contém senhas.

| Variável | Para que serve |
|----------|----------------|
| `DATABASE_URL` | Conexão com o MySQL |
| `DATABASE_URL_TESTE` | Banco usado pelos testes |
| `CORS_ORIGENS` | Endereços do front-end autorizados a chamar a API (`*` = qualquer um) |
| `ADMIN_INICIAL_*` | Administrador criado quando o banco está vazio |
| `SESSAO_HORAS` | Validade do login |
| `LOGIN_MAX_TENTATIVAS` / `LOGIN_BLOQUEIO_MINUTOS` | Bloqueio por senha errada |
| `SERVIR_INTERFACE_TESTE` | `1` mostra a interface de teste em `/teste` |

Para publicar (Render, Railway etc.):

- `DATABASE_URL` apontando para o MySQL hospedado;
- `ADMIN_INICIAL_SENHA` forte;
- `CORS_ORIGENS` com o endereço do front-end, em vez de `*`;
- `SERVIR_INTERFACE_TESTE=0`;
- HTTPS (RNF05), que já vem incluído no Render e no Railway;
- comando de início: `uvicorn app.main:app --host 0.0.0.0 --port $PORT --proxy-headers`, rodado dentro da pasta `backend`;
- a pasta de fotos (`UPLOAD_DIR`) precisa ficar num disco persistente.

---

## 11. Estrutura de pastas

```
AMPARAPET/
├── iniciar.bat / parar.bat / instalar.bat / testar.bat / mysql.bat   atalhos (seção 4)
├── .env.example        modelo das configurações (.env é gerado a partir dele)
├── backend/
│   ├── requirements.txt    bibliotecas Python, com versões fixas
│   ├── app/
│   │   ├── main.py         cria a API, CORS e arquivos estáticos
│   │   ├── config.py       lê o .env
│   │   ├── database.py     conexão com o MySQL
│   │   ├── models.py       tabelas do banco
│   │   ├── schemas.py      formato e validação dos dados de entrada/saída
│   │   ├── servicos.py     regras de negócio (idade, links do WhatsApp, histórico, dados do abrigo)
│   │   ├── security.py     senhas, sessões e bloqueio de tentativas
│   │   ├── imagens.py      validação, compressão e miniaturas das fotos
│   │   ├── init_db.py      cria tabelas, admin inicial e animais de exemplo
│   │   └── routers/        rotas: publico.py, auth.py, admin.py, usuarios.py
│   └── tests/              testes automatizados
├── frontend-teste/     páginas HTML simples para testar a API
├── docs/               documentação do banco, DER (png/svg) e schema.sql
├── scripts/
│   ├── banco.ps1       liga/desliga/baixa o MySQL portátil (seção 3)
│   ├── api.ps1         desliga a API
│   └── gerar_der.py    gera a imagem do DER
├── .vscode/            configuração pronta do VS Code (seção 5)
├── mysql/              MySQL portátil e dados (fora do Git)
├── uploads/            fotos enviadas (fora do Git)
└── .venv/              ambiente Python (fora do Git)
```

---

## 12. Problemas comuns

| Sintoma | Causa provável e solução |
|---------|--------------------------|
| `localhost:8000` não abre | A API não está rodando. Rode o `iniciar.bat` e deixe a janela aberta. |
| A página abre mas dá **erro** (500) ou não carrega os animais | O MySQL está desligado. Rode o `iniciar.bat` de novo. |
| "Python nao encontrado" | Instale o Python 3.11+ marcando "Add python.exe to PATH" e rode o `iniciar.bat` de novo. |
| "MySQL nao subiu" | Veja as últimas linhas de `mysql\mysql.log`. Se mencionar porta em uso, outro programa está usando a 3307: feche-o ou troque a porta em `scripts\banco.ps1` e no `.env`. |
| Erro sobre `MSVCP140.dll` ou `VCRUNTIME140.dll` | Falta o "Microsoft Visual C++ Redistributable" (x64), exigido pelo MySQL. Ele é gratuito e fica no site da Microsoft. |
| Porta 8000 em uso | Outra API já está rodando, talvez numa janela esquecida. Rode o `parar.bat`. |
| Esqueci a senha do admin | Rode `mysql.bat` e execute `DELETE FROM usuarios;`. Ao reiniciar a API, o admin do `.env` é recriado. Isso apaga **todos** os administradores. |
| Mudei uma coluna em `models.py` e nada aconteceu | A API só cria tabelas que não existem. Aplique um `ALTER TABLE` ou zere o banco (seção 6). |
