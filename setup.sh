#!/bin/bash
# ============================================================================
# FAVis - Factory Automation Vision
# Script de Setup
# ============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  FAVis - Factory Automation Vision                            ║${NC}"
echo -e "${CYAN}║  Script de Configuração                                       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verifica sistema
echo -e "${YELLOW}[1/5]${NC} Verificando sistema..."

if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo -e "      ${GREEN}✓${NC} Sistema Linux/WSL detectado"
else
    echo -e "      ${RED}✗${NC} Sistema não suportado. Use Linux ou WSL."
    exit 1
fi

# Verifica dependências
echo -e "${YELLOW}[2/5]${NC} Verificando dependências..."

if command -v gcc &> /dev/null; then
    GCC_VERSION=$(gcc --version | head -n1)
    echo -e "      ${GREEN}✓${NC} GCC encontrado: $GCC_VERSION"
else
    echo -e "      ${RED}✗${NC} GCC não encontrado. Instale com: sudo apt install build-essential"
    exit 1
fi

if command -v make &> /dev/null; then
    echo -e "      ${GREEN}✓${NC} Make encontrado"
else
    echo -e "      ${RED}✗${NC} Make não encontrado. Instale com: sudo apt install build-essential"
    exit 1
fi

# Cria diretórios
echo -e "${YELLOW}[3/5]${NC} Criando diretórios..."
mkdir -p images output build docs/assets
echo -e "      ${GREEN}✓${NC} Diretórios criados"

# Baixa bibliotecas stb_image
echo -e "${YELLOW}[4/5]${NC} Baixando bibliotecas stb_image..."

STB_BASE="https://raw.githubusercontent.com/nothings/stb/master"

download_file() {
    local url=$1
    local dest=$2
    
    if command -v wget &> /dev/null; then
        wget -q -O "$dest" "$url"
    elif command -v curl &> /dev/null; then
        curl -s -o "$dest" "$url"
    else
        echo -e "      ${RED}✗${NC} wget ou curl não encontrado"
        exit 1
    fi
}

# Verifica se já existem e são válidos
if [ -f "include/stb_image.h" ] && [ $(wc -l < "include/stb_image.h") -gt 100 ]; then
    echo -e "      ${GREEN}✓${NC} stb_image.h já existe"
else
    download_file "${STB_BASE}/stb_image.h" "include/stb_image.h"
    echo -e "      ${GREEN}✓${NC} stb_image.h baixado"
fi

if [ -f "include/stb_image_write.h" ] && [ $(wc -l < "include/stb_image_write.h") -gt 100 ]; then
    echo -e "      ${GREEN}✓${NC} stb_image_write.h já existe"
else
    download_file "${STB_BASE}/stb_image_write.h" "include/stb_image_write.h"
    echo -e "      ${GREEN}✓${NC} stb_image_write.h baixado"
fi

# Baixa imagens de exemplo
echo -e "${YELLOW}[5/5]${NC} Baixando imagens de exemplo..."

SAMPLE_IMAGES=(
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png|sample1.png"
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Camponotus_flavomarginatus_ant.jpg/320px-Camponotus_flavomarginatus_ant.jpg|sample2.jpg"
    "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/320px-Image_created_with_a_mobile_phone.png|sample3.png"
    "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cat03.jpg/320px-Cat03.jpg|sample4.jpg"
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Sunflower_from_Silesia.jpg/320px-Sunflower_from_Silesia.jpg|sample5.jpg"
)

downloaded=0
for img_data in "${SAMPLE_IMAGES[@]}"; do
    url="${img_data%%|*}"
    filename="${img_data##*|}"
    
    if [ ! -f "images/$filename" ]; then
        if download_file "$url" "images/$filename" 2>/dev/null; then
            ((downloaded++))
        fi
    else
        ((downloaded++))
    fi
done

echo -e "      ${GREEN}✓${NC} $downloaded imagens de exemplo disponíveis"

# Finalização
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              CONFIGURAÇÃO CONCLUÍDA!                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Próximos passos:"
echo -e "    ${CYAN}1.${NC} Compilar:  ${GREEN}make${NC}"
echo -e "    ${CYAN}2.${NC} Executar:  ${GREEN}./favis${NC}"
echo ""
echo -e "  Ou simplesmente: ${GREEN}make run${NC}"
echo ""
