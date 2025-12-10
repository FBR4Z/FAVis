# ============================================================================
# FAVis - Configuração do Repositório GitHub
# ============================================================================

## DESCRIÇÃO DO REPOSITÓRIO (copiar para o campo "About")

FAVis (Factory Automation Vision) - Sistema de processamento paralelo de imagens para automação industrial. Demonstra programação concorrente com processos, threads POSIX e IPC.


## DESCRIÇÃO LONGA (para usar no About ou em apresentações)

FAVis é um sistema de visão computacional desenvolvido para aplicações de 
automação industrial. Utiliza arquitetura produtor-consumidor com múltiplos 
processos worker e threads paralelas para processamento eficiente de imagens.

O projeto demonstra conceitos avançados de Sistemas Operacionais:
• Processos (fork, wait, exit)
• Threads POSIX (pthread_create, join, mutex)
• IPC: Filas de mensagens, memória compartilhada, pipes
• Sincronização: semáforos, mutex, variáveis de condição

Projetado para evoluir de projeto acadêmico até sistema industrial de 
Inspeção Óptica Automatizada (AOI) em hardware embarcado (RPi 5 + Hailo-8).


## TOPICS/TAGS (adicionar no GitHub)

c
linux
parallel-processing
image-processing
posix
threads
ipc
computer-vision
factory-automation
aoi
embedded-systems
raspberry-pi
operating-systems


## CONFIGURAÇÕES RECOMENDADAS NO GITHUB

1. Repository name: FAVis
2. Description: (usar a descrição curta acima)
3. Visibility: Public
4. Add a README: Não (já temos)
5. Add .gitignore: Não (já temos)
6. Choose a license: MIT (já temos)


## COMANDOS PARA SUBIR O PROJETO

# Opção A: Novo repositório limpo
cd ~/FAVis
git init
git add .
git commit -m "v0.1.0 - Initial release: FAVis - Factory Automation Vision"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/FAVis.git
git push -u origin main

# Opção B: Se já tem o repositório trabalho2_sis_os_emb
# Primeiro renomeie no GitHub: Settings > General > Repository name > FAVis
# Depois atualize o remote local:
cd ~/trabalho2_sis_op_emb_fabiobraz
git remote set-url origin https://github.com/SEU_USUARIO/FAVis.git

# Substitua os arquivos atualizados e faça commit:
git add .
git commit -m "refactor: Rebrand para FAVis - Factory Automation Vision"
git push


## ESTRUTURA FINAL DO REPOSITÓRIO

FAVis/
├── .gitignore
├── LICENSE
├── Makefile
├── README.md
├── setup.sh
├── docs/
│   └── assets/
├── images/
│   └── .gitkeep
├── include/
│   ├── common.h
│   ├── filters.h
│   ├── ipc_manager.h
│   ├── stb_image.h        (baixado pelo setup.sh)
│   ├── stb_image_write.h  (baixado pelo setup.sh)
│   ├── sync_manager.h
│   └── worker.h
├── output/
│   └── .gitkeep
└── src/
    ├── filters.c
    ├── ipc_manager.c
    ├── main.c
    ├── sync_manager.c
    └── worker.c
