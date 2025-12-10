/**
 * @file common.h
 * @brief FAVis - Factory Automation Vision
 * 
 * Definições comuns, estruturas e configurações do sistema.
 * 
 * @version 0.1.0
 * @date 2024
 * @author Fábio Braz
 * @copyright MIT License
 */

#ifndef FAVIS_COMMON_H
#define FAVIS_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <pthread.h>
#include <semaphore.h>
#include <mqueue.h>
#include <errno.h>
#include <dirent.h>
#include <time.h>
#include <signal.h>

// ============================================================================
// INFORMAÇÕES DO PROJETO
// ============================================================================

#define FAVIS_NAME          "FAVis"
#define FAVIS_FULL_NAME     "Factory Automation Vision"
#define FAVIS_VERSION_MAJOR 0
#define FAVIS_VERSION_MINOR 1
#define FAVIS_VERSION_PATCH 0
#define FAVIS_VERSION       "0.1.0"
#define FAVIS_AUTHOR        "Fábio Braz"
#define FAVIS_LICENSE       "MIT"

// ============================================================================
// CONFIGURAÇÕES DO SISTEMA
// ============================================================================

// Paralelismo
#define NUM_WORKERS         2       // Número de processos worker
#define NUM_THREADS         3       // Threads por worker (filtros paralelos)

// Limites
#define MAX_FILENAME        256     // Tamanho máximo de nome de arquivo
#define MAX_PATH            512     // Tamanho máximo de caminho
#define MAX_IMAGES          100     // Máximo de imagens por execução
#define MAX_MSG_SIZE        512     // Tamanho máximo de mensagem IPC
#define MAX_QUEUE_MSGS      10      // Capacidade da fila de mensagens

// Parâmetros de filtros
#define BLUR_KERNEL_SIZE    5       // Tamanho do kernel de blur (ímpar)
#define RESIZE_SCALE        0.5     // Fator de redimensionamento padrão

// ============================================================================
// RECURSOS IPC
// ============================================================================

// Nomes dos recursos IPC POSIX (devem começar com /)
#define QUEUE_NAME          "/favis_queue"
#define SHM_NAME            "/favis_stats"
#define SEM_IO_NAME         "/favis_io_sem"

// ============================================================================
// DIRETÓRIOS
// ============================================================================

#define INPUT_DIR           "images"
#define OUTPUT_DIR          "output"

// ============================================================================
// TIPOS DE FILTRO
// ============================================================================

typedef enum {
    FILTER_GRAYSCALE = 0,
    FILTER_BLUR      = 1,
    FILTER_RESIZE    = 2,
    // Reservado para versões futuras:
    // FILTER_SOBEL     = 3,
    // FILTER_THRESHOLD = 4,
    // FILTER_CANNY     = 5,
    FILTER_COUNT     = 3    // Número total de filtros ativos
} filter_type_t;

// ============================================================================
// CÓDIGOS DE MENSAGEM
// ============================================================================

typedef enum {
    MSG_TASK        = 1,    // Tarefa de processamento
    MSG_TERMINATE   = 2,    // Sinal de término
    MSG_STATUS      = 3,    // Requisição de status (futuro)
    MSG_CONFIG      = 4     // Atualização de configuração (futuro)
} msg_type_t;

// ============================================================================
// ESTRUTURAS DE DADOS
// ============================================================================

/**
 * @brief Estatísticas compartilhadas entre processos
 * 
 * Armazenada em memória compartilhada POSIX (shm).
 * Protegida por mutex com PTHREAD_PROCESS_SHARED.
 */
typedef struct {
    // Sincronização
    pthread_mutex_t mutex;
    pthread_mutexattr_t mutex_attr;
    pthread_cond_t cond_finished;
    pthread_condattr_t cond_attr;
    
    // Estatísticas de processamento
    int total_images;           // Total de imagens a processar
    int processed_images;       // Imagens processadas com sucesso
    int failed_images;          // Imagens com falha
    double total_processing_time;
    
    // Estado dos workers
    int workers_active;         // Workers atualmente ativos
    int workers_done;           // Workers que finalizaram
    char current_files[NUM_WORKERS][MAX_FILENAME];  // Arquivo atual de cada worker
} shared_stats_t;

/**
 * @brief Mensagem para fila de tarefas
 * 
 * Usada para comunicação coordenador → workers via mq_send/mq_receive.
 */
typedef struct {
    long msg_type;              // Tipo da mensagem (MSG_TASK, MSG_TERMINATE, etc.)
    char filename[MAX_FILENAME];// Nome do arquivo a processar
    int task_id;                // ID sequencial da tarefa
} task_message_t;

/**
 * @brief Argumentos para threads de filtro
 * 
 * Passado para cada thread que executa um filtro específico.
 */
typedef struct {
    unsigned char *image_data;  // Ponteiro para dados da imagem
    int width;                  // Largura em pixels
    int height;                 // Altura em pixels
    int channels;               // Número de canais (1=gray, 3=RGB, 4=RGBA)
    char input_file[MAX_FILENAME];  // Arquivo de entrada
    char output_file[MAX_PATH];     // Arquivo de saída
    int filter_type;            // Tipo do filtro (filter_type_t)
    int thread_id;              // ID da thread dentro do worker
    int worker_id;              // ID do worker pai
    int success;                // Resultado: 1=sucesso, 0=falha
} thread_args_t;

/**
 * @brief Contexto de execução do worker
 * 
 * Contém todos os recursos necessários para o worker operar.
 */
typedef struct {
    int worker_id;              // ID do worker (0 a NUM_WORKERS-1)
    mqd_t msg_queue;            // Descritor da fila de mensagens
    shared_stats_t *stats;      // Ponteiro para estatísticas compartilhadas
    sem_t *io_sem;              // Semáforo de controle de I/O
    int pipe_fd;                // File descriptor do pipe de log
} worker_context_t;

// ============================================================================
// MACROS DE LOG
// ============================================================================

#define LOG_SETUP(fmt, ...)     printf("[SETUP] " fmt "\n", ##__VA_ARGS__)
#define LOG_COORD(fmt, ...)     printf("[COORD] " fmt "\n", ##__VA_ARGS__)
#define LOG_WORKER(id, fmt, ...)  printf("[W%d] " fmt "\n", id, ##__VA_ARGS__)
#define LOG_ERROR(fmt, ...)     fprintf(stderr, "[ERRO] " fmt "\n", ##__VA_ARGS__)
#define LOG_DEBUG(fmt, ...)     // printf("[DEBUG] " fmt "\n", ##__VA_ARGS__)

// ============================================================================
// FUNÇÕES UTILITÁRIAS INLINE
// ============================================================================

/**
 * @brief Calcula diferença de tempo entre dois timespec
 * @return Diferença em segundos (double)
 */
static inline double get_time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

/**
 * @brief Extrai nome base de um caminho completo
 */
static inline void get_basename(const char *path, char *basename) {
    const char *last_slash = strrchr(path, '/');
    if (last_slash) {
        strcpy(basename, last_slash + 1);
    } else {
        strcpy(basename, path);
    }
}

/**
 * @brief Remove extensão de um nome de arquivo
 */
static inline void remove_extension(char *filename) {
    char *dot = strrchr(filename, '.');
    if (dot) *dot = '\0';
}

/**
 * @brief Imprime versão do FAVis
 */
static inline void favis_print_version(void) {
    printf("%s v%s - %s\n", FAVIS_NAME, FAVIS_VERSION, FAVIS_FULL_NAME);
}

#endif // FAVIS_COMMON_H
