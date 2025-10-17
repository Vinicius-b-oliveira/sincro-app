<div align="center">
  <h1>Sincro</h1>
  <p>
    Documentação técnica para configuração e desenvolvimento do aplicativo Sincro.
  </p>
</div>

<hr>

<h2>Visão Geral do Projeto</h2>

<p>
  Este repositório contém o código-fonte do <b>Sincro</b>, um aplicativo de gerenciamento de gastos financeiros que simplifica o controle de despesas individuais e compartilhadas através de um sistema de grupos. A arquitetura segue um padrão MVVM rigoroso com princípios de Clean Architecture para garantir escalabilidade, testabilidade e manutenibilidade.
</p>

<p>
  A base tecnológica inclui <b>Flutter</b>, <b>Riverpod</b> para gerenciamento de estado e injeção de dependência, <b>GoRouter</b> para navegação, e <b>Dio</b> para comunicação de rede.
</p>

<hr>

<h2>Pré-requisitos de Ambiente</h2>

<p>Antes de começar, garanta que você tenha as seguintes ferramentas instaladas e configuradas no seu ambiente de desenvolvimento:</p>

<ul>
  <li>
    <strong><a href="https://fvm.app">FVM (Flutter Version Management)</a>:</strong> Essencial para garantir que toda a equipe utilize a mesma versão do Flutter definida no projeto.
  </li>
  <li>
    <strong><a href="https://docs.flutter.dev/get-started/install">Flutter SDK</a>:</strong> A versão exata será gerenciada pelo FVM.
  </li>
  <li>
    <strong><a href="https://pub.dev/packages/mason">Mason CLI</a>:</strong> Ferramenta de linha de comando para gerar código a partir de templates (bricks).
  </li>
  <li>
    <strong>IDE:</strong> Visual Studio Code ou Android Studio com os plugins oficiais do Flutter e Dart.
  </li>
</ul>

<hr>

<h2>Configuração Inicial do Projeto</h2>

<p>Siga estes passos para configurar o projeto na sua máquina local após clonar o repositório.</p>

<h4>Passo 1: Sincronizar a Versão do Flutter</h4>
<p>O FVM lerá a versão do Flutter definida em <code>.fvmrc</code> e a instalará localmente para este projeto.</p>
<pre><code>fvm use</code></pre>

<h4>Passo 2: Instalar Dependências</h4>
<p>Use o FVM para executar o comando <code>flutter pub get</code>, garantindo que as dependências sejam baixadas com a versão correta do SDK.</p>
<pre><code>fvm flutter pub get</code></pre>

<h4>Passo 3: Configurar Variáveis de Ambiente</h4>
<p>O projeto utiliza um arquivo <code>.env</code> para gerenciar as chaves de API e URLs do backend em ambiente de desenvolvimento.</p>
<ol>
  <li>Crie uma cópia do arquivo <code>.env.example</code>.</li>
  <li>Renomeie a cópia para <code>.env</code>.</li>
  <li>Preencha as variáveis com os valores corretos para o seu ambiente de desenvolvimento local.</li>
</ol>
<pre><code>cp .env.example .env</code></pre>

<h4>Passo 4: Gerar o Código de Build</h4>
<p>Nosso projeto utiliza <code>build_runner</code> para gerar o código boilerplate para Models (Freezed, JsonSerializable) e Providers (Riverpod Generator). Execute o comando abaixo. É normal que ele demore um pouco na primeira vez.</p>
<pre><code>fvm dart run build_runner build --delete-conflicting-outputs</code></pre>

<hr>

<h2>Estrutura e Padrões de Desenvolvimento</h2>

<h4>Gerando Novas Features com Mason</h4>
<p>
  A criação de novas features deve <strong>obrigatoriamente</strong> ser feita através do nosso template Mason para manter a consistência arquitetural. O template irá criar toda a estrutura de pastas e arquivos (View, ViewModel, State, Repository, DataSource) para você.
</p>
<p>Primeiro, instale os bricks locais:</p>
<pre><code>mason get</code></pre>
<p>Depois, para criar uma nova feature (ex: "profile"):</p>
<pre><code>mason make new_feature_mvvm</code></pre>

<h4>Executando o Gerador de Código (Build Runner)</h4>
<p>
  Sempre que você modificar um arquivo que utiliza anotações do Freezed, Riverpod Generator ou JsonSerializable (ex: Models, States, Providers), você <strong>precisa</strong> rodar o <code>build_runner</code> novamente para que as alterações sejam refletidas nos arquivos gerados (<code>*.g.dart</code>, <code>*.freezed.dart</code>).
</p>
<p>Para rodar o gerador e observar as mudanças em tempo real (recomendado durante o desenvolvimento), use:</p>
<pre><code>fvm dart run build_runner watch --delete-conflicting-outputs</code></pre>

<hr>
