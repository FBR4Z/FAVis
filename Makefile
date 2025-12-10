# ============================================================================
# FAVis - Factory Automation Vision
# Makefile
# ============================================================================

# Informações do projeto
PROJECT_NAME = FAVis
PROJECT_VERSION = 0.1.0

# Compilador e flags
CC = gcc
CFLAGS = -Wall -Wextra -pthread -D_GNU_SOURCE -I./include
LDFLAGS = -pthread -lrt -lm

# Debug flags (descomente para debug)
# CFLAGS += -g -O0 -DDEBUG
# Release flags
CFLAGS += -O2

# Diretórios
SRC_DIR = src
INC_DIR = include
BUILD_DIR = build

# Binário de saída
TARGET = favis

# Arquivos fonte
SRCS = $(SRC_DIR)/main.c \
       $(SRC_DIR)/worker.c \
       $(SRC_DIR)/filters.c \
       $(SRC_DIR)/ipc_manager.c \
       $(SRC_DIR)/sync_manager.c

# Arquivos objeto
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Cores para output
GREEN = \033[0;32m
YELLOW = \033[0;33m
CYAN = \033[0;36m
NC = \033[0m

# ============================================================================
# TARGETS PRINCIPAIS
# ============================================================================

.PHONY: all clean run setup download-libs help version info

all: info $(TARGET)
	@echo "$(GREEN)✓ Build concluído!$(NC)"
	@echo "  Execute: ./$(TARGET)"

$(TARGET): $(BUILD_DIR) $(OBJS)
	@echo "$(YELLOW)Linkando...$(NC)"
	@$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)
	@echo "$(GREEN)✓ $(TARGET) criado$(NC)"

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "$(CYAN)Compilando $<...$(NC)"
	@$(CC) $(CFLAGS) -c $< -o $@

# ============================================================================
# DEPENDÊNCIAS DE HEADERS
# ============================================================================

$(BUILD_DIR)/main.o: $(INC_DIR)/common.h $(INC_DIR)/ipc_manager.h $(INC_DIR)/sync_manager.h $(INC_DIR)/worker.h
$(BUILD_DIR)/worker.o: $(INC_DIR)/common.h $(INC_DIR)/worker.h $(INC_DIR)/filters.h $(INC_DIR)/ipc_manager.h $(INC_DIR)/sync_manager.h
$(BUILD_DIR)/filters.o: $(INC_DIR)/common.h $(INC_DIR)/filters.h $(INC_DIR)/stb_image.h $(INC_DIR)/stb_image_write.h
$(BUILD_DIR)/ipc_manager.o: $(INC_DIR)/common.h $(INC_DIR)/ipc_manager.h
$(BUILD_DIR)/sync_manager.o: $(INC_DIR)/common.h $(INC_DIR)/sync_manager.h

# ============================================================================
# TARGETS AUXILIARES
# ============================================================================

info:
	@echo ""
	@echo "$(CYAN)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║  $(PROJECT_NAME) - Factory Automation Vision              v$(PROJECT_VERSION)  ║$(NC)"
	@echo "$(CYAN)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""

version:
	@echo "$(PROJECT_NAME) v$(PROJECT_VERSION)"

run: all
	@echo ""
	@./$(TARGET)

clean:
	@echo "$(YELLOW)Limpando arquivos de build...$(NC)"
	@rm -rf $(BUILD_DIR) $(TARGET)
	@echo "$(GREEN)✓ Limpo!$(NC)"

setup: download-libs
	@mkdir -p images output
	@echo "$(GREEN)✓ Diretórios criados$(NC)"

download-libs:
	@echo "$(YELLOW)Baixando bibliotecas stb_image...$(NC)"
	@wget -q -O $(INC_DIR)/stb_image.h https://raw.githubusercontent.com/nothings/stb/master/stb_image.h 2>/dev/null || \
		curl -s -o $(INC_DIR)/stb_image.h https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
	@wget -q -O $(INC_DIR)/stb_image_write.h https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h 2>/dev/null || \
		curl -s -o $(INC_DIR)/stb_image_write.h https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h
	@echo "$(GREEN)✓ Bibliotecas baixadas$(NC)"

# ============================================================================
# LIMPEZA DE RECURSOS
# ============================================================================

clean-ipc:
	@echo "$(YELLOW)Limpando recursos IPC...$(NC)"
	@rm -f /dev/mqueue/favis_queue 2>/dev/null || true
	@rm -f /dev/shm/favis_stats 2>/dev/null || true
	@rm -f /dev/shm/sem.favis_io_sem 2>/dev/null || true
	@echo "$(GREEN)✓ Recursos IPC limpos$(NC)"

clean-output:
	@echo "$(YELLOW)Limpando imagens de saída...$(NC)"
	@rm -f output/*
	@echo "$(GREEN)✓ Pasta output limpa$(NC)"

clean-all: clean clean-ipc clean-output
	@echo "$(GREEN)✓ Tudo limpo!$(NC)"

# ============================================================================
# INSTALAÇÃO
# ============================================================================

PREFIX ?= /usr/local

install: $(TARGET)
	@echo "$(YELLOW)Instalando $(TARGET) em $(PREFIX)/bin...$(NC)"
	@install -d $(PREFIX)/bin
	@install -m 755 $(TARGET) $(PREFIX)/bin/
	@echo "$(GREEN)✓ Instalado!$(NC)"

uninstall:
	@echo "$(YELLOW)Removendo $(TARGET) de $(PREFIX)/bin...$(NC)"
	@rm -f $(PREFIX)/bin/$(TARGET)
	@echo "$(GREEN)✓ Removido!$(NC)"

# ============================================================================
# AJUDA
# ============================================================================

help:
	@echo ""
	@echo "$(CYAN)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║  $(PROJECT_NAME) - Comandos Disponíveis                             ║$(NC)"
	@echo "$(CYAN)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "  $(GREEN)make$(NC)              Compila o projeto"
	@echo "  $(GREEN)make run$(NC)          Compila e executa"
	@echo "  $(GREEN)make setup$(NC)        Configura ambiente (baixa libs)"
	@echo "  $(GREEN)make clean$(NC)        Remove arquivos de build"
	@echo "  $(GREEN)make clean-ipc$(NC)    Remove recursos IPC órfãos"
	@echo "  $(GREEN)make clean-output$(NC) Limpa pasta de saída"
	@echo "  $(GREEN)make clean-all$(NC)    Limpa tudo"
	@echo "  $(GREEN)make install$(NC)      Instala em /usr/local/bin"
	@echo "  $(GREEN)make uninstall$(NC)    Remove instalação"
	@echo "  $(GREEN)make version$(NC)      Mostra versão"
	@echo "  $(GREEN)make help$(NC)         Mostra esta ajuda"
	@echo ""
