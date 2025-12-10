<p align="center">
  <img src="docs/assets/logo.png" alt="FAVis Logo" width="180">
</p>

<h1 align="center">FAVis</h1>
<h3 align="center">Factory Automation Vision</h3>

<p align="center">
  Sistema de processamento paralelo de imagens para automação industrial
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/platform-Linux-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/language-C-orange.svg" alt="Language">
</p>

---

## Sobre

**FAVis** é um sistema de processamento paralelo de imagens que demonstra técnicas de programação concorrente utilizando processos, threads POSIX e mecanismos de comunicação entre processos (IPC).

O projeto implementa uma arquitetura **produtor-consumidor** onde um coordenador distribui tarefas de processamento de imagens para múltiplos workers, que por sua vez utilizam threads para aplicar filtros em paralelo.

---

## Funcionalidades

| Categoria | Funcionalidade | Status |
|-----------|----------------|--------|
| **Processos** | Fork de workers paralelos | ✅ |
| **Processos** | Gerenciamento com wait/exit | ✅ |
| **Threads** | Pool de threads por worker | ✅ |
| **Threads** | Processamento paralelo de filtros | ✅ |
| **IPC** | Fila de mensagens POSIX | ✅ |
| **IPC** | Memória compartilhada | ✅ |
| **IPC** | Pipes para logging | ✅ |
| **Sincronização** | Semáforos POSIX | ✅ |
| **Sincronização** | Mutex compartilhado | ✅ |
| **Sincronização** | Variáveis de condição | ✅ |
| **Filtros** | Grayscale, Blur, Resize | ✅ |

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                      COORDENADOR (main)                         │
│  • Escaneia diretório de imagens                                │
│  • Inicializa recursos IPC (mq, shm, sem)                       │
│  • Cria workers via fork()                                      │
│  • Distribui tarefas via fila de mensagens                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                ▼                               ▼
        ┌─────────────┐                 ┌─────────────┐
        │  WORKER 0   │                 │  WORKER 1   │
        │  (processo) │                 │  (processo) │
        │             │                 │             │
        │ ┌─────────┐ │                 │ ┌─────────┐ │
        │ │Thread 0 │ │                 │ │Thread 0 │ │
        │ │grayscale│ │                 │ │grayscale│ │
        │ ├─────────┤ │                 │ ├─────────┤ │
        │ │Thread 1 │ │                 │ │Thread 1 │ │
        │ │  blur   │ │                 │ │  blur   │ │
        │ ├─────────┤ │                 │ ├─────────┤ │
        │ │Thread 2 │ │                 │ │Thread 2 │ │
        │ │ resize  │ │                 │ │ resize  │ │
        │ └─────────┘ │                 │ └─────────┘ │
        └─────────────┘                 └─────────────┘
```

### Mecanismos IPC

| Mecanismo | Uso |
|-----------|-----|
| **Message Queue** | Distribuição de tarefas (coordenador → workers) |
| **Shared Memory** | Estatísticas globais e progresso |
| **Semaphores** | Controle de acesso concorrente a I/O |
| **Mutex** | Proteção de seções críticas |
| **Condition Vars** | Sinalização de conclusão |
| **Pipes** | Coleta de logs dos workers |

---

## Instalação

### Pré-requisitos

- Linux (Ubuntu 20.04+ / Debian 11+ / WSL2)
- GCC 9+
- Make

### Compilação

```bash
git clone https://github.com/FBR4Z/FAVis.git
cd FAVis

chmod +x setup.sh
./setup.sh

make
./favis
```

---

## Uso

```bash
# Coloque imagens na pasta images/
cp suas_imagens/*.jpg images/

# Execute
./favis

# Resultados em output/
ls output/
```

### Configuração

Parâmetros em `include/common.h`:

```c
#define NUM_WORKERS     2    // Processos paralelos
#define NUM_THREADS     3    // Threads por worker
#define BLUR_KERNEL     5    // Tamanho do kernel
#define RESIZE_SCALE    0.5  // Fator de redimensionamento
```

---

## Conceitos de SO Demonstrados

### Processos
- `fork()` - Criação de processos filhos
- `wait()` / `waitpid()` - Sincronização pai-filho
- `exit()` - Término de processos

### Threads POSIX
- `pthread_create()` / `pthread_join()`
- `pthread_mutex_*` - Exclusão mútua
- `pthread_cond_*` - Variáveis de condição

### IPC POSIX
- `mq_open()` / `mq_send()` / `mq_receive()`
- `shm_open()` / `mmap()`
- `sem_open()` / `sem_wait()` / `sem_post()`
- `pipe()`

### Padrões
- Produtor-consumidor
- Seções críticas
- Mutex com `PTHREAD_PROCESS_SHARED`

---

## Estrutura do Projeto

```
FAVis/
├── src/
│   ├── main.c           # Coordenador
│   ├── worker.c         # Lógica dos workers
│   ├── filters.c        # Filtros de imagem
│   ├── ipc_manager.c    # Gerenciamento IPC
│   └── sync_manager.c   # Sincronização
├── include/
│   └── *.h              # Headers
├── images/              # Entrada
├── output/              # Saída
├── docs/
│   └── ROADMAP.md       # Planos futuros
├── Makefile
├── setup.sh
└── README.md
```

---

## Roadmap

Para planos futuros e visão do projeto, consulte [ROADMAP.md](docs/ROADMAP.md).

---

## Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## Autor

**Fábio Braz** - [@FBR4Z](https://github.com/FBR4Z)

---
