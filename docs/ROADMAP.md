# FAVis - Roadmap

Este documento descreve a visão de longo prazo e os planos de desenvolvimento do FAVis.

---

## Visão

Transformar o FAVis em uma plataforma completa de **Inspeção Óptica Automatizada (AOI)** para ambientes industriais, executando em hardware embarcado de baixo custo com aceleração de IA.

---

## Versionamento

O projeto segue [Semantic Versioning](https://semver.org/):
- `0.x.x` - Desenvolvimento e experimentação
- `1.0.0` - Primeira versão estável para produção
- `x.y.0` - Novas funcionalidades
- `x.y.z` - Correções de bugs

---

## Versões Planejadas

### v0.1.0 ✅ (Atual)
**Base do Sistema**
- Arquitetura produtor-consumidor
- Fork, threads POSIX, IPC completo
- Filtros: grayscale, blur, resize
- ~800 linhas de código

### v0.2.0 (Planejado)
**Filtro Sobel + Sub-regiões**
- Detecção de bordas com kernel Sobel
- Divisão de imagem em sub-regiões
- Threads processando regiões em paralelo
- Técnica de halo para bordas

### v0.3.0 (Planejado)
**Benchmarks e Métricas**
- Medição de tempo por filtro
- Comparação serial vs paralelo
- Cálculo de speedup e eficiência
- Relatório JSON
- Gráficos com Python/matplotlib

### v0.4.0 (Planejado)
**Suporte ARM**
- Compilação para ARM64/aarch64
- CMake para build multiplataforma
- Otimizações NEON (SIMD)
- Testado em Raspberry Pi 5 e Orange Pi 5

### v0.5.0 (Planejado)
**Integração com Câmera**
- Captura via V4L2 e libcamera
- Pipeline GStreamer
- Trigger GPIO para sincronização
- Buffer circular de frames
- Suporte: RPi Camera Module 3, USB UVC

### v0.6.0 (Planejado)
**Aceleração NPU**
- Backend Hailo Runtime (HailoRT)
- Backend RKNN (Rockchip RK3588)
- Inferência YOLOv8 para detecção
- Pipeline híbrido: CPU (pré-proc) + NPU (inferência)
- Model Zoo com modelos pré-treinados

### v0.7.0 (Planejado)
**Interface de Operador**
- Interface web responsiva (React + TailwindCSS)
- Backend: C + libmicrohttpd
- Streaming via WebSocket + MJPEG
- Configuração de parâmetros em tempo real
- Histórico e estatísticas (SQLite)

### v0.8.0 (Planejado)
**Sistema de Receitas**
- Receitas em YAML para diferentes produtos
- ROI (Region of Interest) configurável
- Parâmetros por produto: modelo, thresholds, ações
- Executor de pipeline configurável

### v0.9.0 (Planejado)
**Release Candidate**
- Testes de stress (168h contínuas)
- Testes de temperatura (0-50°C)
- Documentação completa
- Systemd service files
- Watchdog para auto-recovery

**Critérios de aprovação:**
- Uptime 7 dias contínuos
- Memory leak < 1MB/hora
- Latência P99 < 100ms
- Throughput ≥ 30 FPS

### v1.0.0 (Meta)
**MVP Industrial**
- Todas funcionalidades integradas
- Testado para ambiente industrial
- ~15.000 linhas de código
- Cobertura de testes > 70%
- Documentação: INSTALL, USER_MANUAL, API_REFERENCE

---

## Versões Futuras (Pós-1.0)

### v1.1.0 - Integração PLC
- Modbus TCP/RTU
- OPC-UA
- Comunicação bidirecional com CLPs
- Integração com rejeitor pneumático

### v1.2.0 - Dashboard e Relatórios
- Dashboard em tempo real com KPIs
- Gráficos de tendência (Pareto, histograma)
- Relatórios PDF automáticos
- Exportação CSV/Excel
- Alertas por email/SMS

### v1.3.0 - Multi-câmera
- Suporte a múltiplas câmeras simultâneas
- Sincronização de captura
- Inspeção em múltiplos ângulos
- Stitching de imagens

### v2.0.0 - Arquitetura Distribuída
- Múltiplos nós coordenados
- Dashboard centralizado multi-fábrica
- Treinamento de modelos na cloud
- Federated Learning
- Update OTA de modelos

---

## Hardware Alvo

| Plataforma | NPU | Performance | Preço | Uso |
|------------|-----|-------------|-------|-----|
| Raspberry Pi 5 + Hailo-8L | 13 TOPS | ~80 FPS | ~$150 | Prototipagem |
| Raspberry Pi 5 + Hailo-8 | 26 TOPS | ~150 FPS | ~$290 | Produção leve |
| Orange Pi 5 Plus | 6 TOPS (RK3588) | ~35 FPS | ~$150 | Custo-benefício |
| Orange Pi 5 + Hailo-8 | 32 TOPS | ~180 FPS | ~$370 | Alta performance |

---

## Aplicações Industriais

### Casos de Uso

- **Inspeção de PCBs**: Detecção de defeitos (curtos, aberturas, componentes faltantes)
- **Controle de Qualidade**: Verificação visual de produtos em linha
- **Contagem de Peças**: Inventário automático em bandejas/pallets
- **Verificação de Rótulos**: OCR e validação de etiquetas
- **Visão Robótica**: Guia para pick-and-place

### Conceitos Aplicados

| Conceito FAVis | Aplicação Industrial |
|----------------|---------------------|
| Divisão em sub-regiões | Inspeção paralela de PCBs grandes |
| Pipeline de filtros | Pré-processamento antes de ML |
| Arquitetura multiprocesso | Redundância e isolamento de falhas |
| Memória compartilhada | Estatísticas em tempo real |
| Filas de mensagens | Desacoplamento produtor-consumidor |

---

## Datasets para Treinamento

- **DeepPCB**: 1.500 imagens, 6 tipos de defeitos
- **Kaggle PCB Defects**: 1.386 imagens
- **PKU PCB Dataset**
- **HRIPCB**

Tipos de defeitos: missing hole, mouse bite, open circuit, short circuit, spur, spurious copper

---

## Contribuindo

Interessado em contribuir? Veja as issues marcadas como `good first issue` ou `help wanted`.

Áreas que precisam de ajuda:
- Testes em hardware ARM
- Otimizações SIMD
- Documentação
- Tradução para outros idiomas
