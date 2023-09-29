/*
MIT License

Copyright (c) 2020 DarkElvenAngel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// Should have the sticky bit set // No longer needs sticky bit


#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <linux/gpio.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <dirent.h>
#include <poll.h>
#include <inttypes.h>
#include <time.h>
#include <ctype.h>
#include <argp.h>
#include "argononed.h"

char* RUN_STATE_STR[4] = {"AUTO", "OFF", "MANUAL", "COOLDOWN"};
char* STATUS_STR[11] = {"Esperando solicitud",
    "La solicitud está lista para ser procesada.",
    "Solicitud pendiente",
    "Error en la última solicitud",
    "Solicitando estado para sincronizar",
    "Limpiar solicitud",
    "Solicitando reinicio del Daemon",
    "Solicitudes retenidas",
    "Solicitando apagado del Daemon",
    "Solicitar señal de confirmación",
    "Desconocido"
    };

const char *argp_program_version = "argonone-cli version 0.3.1";
const char *argp_program_bug_address =
	"<gitlab.com/darkelvenangel/argononed.git>";

/* Program documentation. */
static char doc[] =
	"ArgonOne Daemon CLI - Ajustar la configuración y monitorear el estado";

/* A description of the arguments we accept. */
static char args_doc[] = "";

/* The options we understand. */
static struct argp_option options[] = {
  {0 ,0 ,0, 0, ">> modos control ventilador <<", 1},
  {"cooldown", 'c', "Temp", 0,  "Asignar modo Cool Down", 1},
  {"manual",   'm', 0,      0,  "Asignar modo Manual", 1},
  {"fan",      'f', "SPEED",0,  "SAsignar velocidad del ventilador", 1},
  {0 ,0 ,0, 0, ">> Monitorizar controles <<",2},
  {"off",      'o', 0,      0,  "Encender monitor de temperatura",2},
  {"auto",     'a', 0,      0,  "Asignar modo Automatico",2},
  {0, 0, 0, 0,  ">> Programar Operaciones<<",3},
  {"fan0", 3, "VALUE",0, "Asignar valor a Fan1",3},
  {"fan1", 4, "VALUE",0, "Asignar valor a Fan2",3},
  {"fan2", 5, "VALUE",0, "Asignar valor a Fan3",3},
  {"temp0", 6, "VALUE",0, "Asignar valor a Temperatura1",3},
  {"temp1", 7, "VALUE",0, "Asignar valor a Temperatura2",3},
  {"temp2", 8, "VALUE",0, "Asignar valor a Temperatura3",3},
  {"hysteresis", 9, "VALUE",0,  "Asignar valor a Hysteresis",3},
  {0, 0, 0, 0, "",4},
  {"commit",    1,  0,      0,  "Aplicar cambios",4},
  {"reload",   'r', 0,      OPTION_ALIAS,"",4},
  {"reset",    'R', 0,      0,  "Restablecer la memoria compartida",4},
  //{"load",     'l', "FILE", 0,  "Load New Schedule "},
  {0, 0, 0, 0, ">> Opciones de salida <<" ,5},
  {"decode",   'd', 0,      0,  "Decodifica la memoria compartida",5},
  {"verbose",  'v', 0,      0,  "Produce una salida ampliada" ,5},
  {"quiet",    'q', 0,      0,  "Sin efecto" ,5},
  {"silent",   's', 0,      OPTION_ALIAS ,"",5},
  { 0 }
};

/* Used by main to communicate with parse_opt. */
struct arguments
{
  char *args;
  int silent, verbose, reload, reset, debug;
  int mode;
  int fanoverride;
  int targettemp; 
  struct DTBO_Config *Schedule;
};

/* Parse a single option. */
static error_t parse_opt (int key, char *arg, struct argp_state *state)
{
	/* Get the input argument from argp_parse, which we
     know is a pointer to our arguments structure. */
	struct arguments *arguments = state->input;
  static int mode_switch = -1;
	switch (key)
    {
    case 'q': case 's':
      arguments->silent = 1;
      break;
    case 'v':
      arguments->verbose = 1;
      break;
    case 'r': case 1:
      arguments->reload = 1;
      break; 
    case ARGP_KEY_ARG:
      if (state->arg_num >= 2)
      {
        fprintf(stderr, "ERROR:  Argumento incorrecto");
        /* Too many arguments. */
        argp_usage (state);
      }
      arguments->args= arg;

      break;

    case 'm':
      if (mode_switch != -1)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 2;
      break;
    case 'c':
      if (mode_switch != -1)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      arguments->targettemp = atoi(arg);
      mode_switch = 3;
      break;
    case 'a':
      if (mode_switch != -1)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 0;
      break;
    case 'o':
      if (mode_switch != -1)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 1;
      break;
    case 'd':
      if (mode_switch != -1)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 5;
      break;
    case 'f':
    {
      int fanspeed = atoi(arg);
      if (fanspeed > 0 && fanspeed < 10) fanspeed = 10;
      if (fanspeed > 100) fanspeed = 100;
      arguments->fanoverride = fanspeed;
      break;
    }
    case 'R':
      arguments->reset = 1;
      break;
    case 3:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->fanstages[0] = atoi(arg);
      break;

    case 4:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->fanstages[1] = atoi(arg);
      break;
    
    case 5:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->fanstages[2] = atoi(arg);
      break;

    case 6:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->thresholds[0] = atoi(arg);
      break;

    case 7:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->thresholds[1] = atoi(arg);
      break;

    case 8:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->thresholds[2] = atoi(arg);
      break;

    case 9:
      if (mode_switch != -1 && mode_switch != 4)
      {
        fprintf (stderr,"ERROR:  Modos en conflicto\n");
        mode_switch = -2;
        break;
      }
      mode_switch = 4;
      arguments->Schedule->hysteresis = atoi(arg);
      break;

    case ARGP_KEY_END:
      /* if (state->arg_num == 0) //  Not enough arguments.
      {
          argp_usage (state);
      } */
      break;

    default:
      return ARGP_ERR_UNKNOWN;
    }
    arguments->mode = mode_switch;
	return 0;
}

/* Our argp parser. */
static struct argp argp = { options, parse_opt, args_doc, doc, 0, 0, 0 };
/// ====================================================================

struct arguments arguments = {0};

/**
 * Send Request and wait for reply
 * 
 * \param ptr Pointer to share memory data
 * \param pid PID of the daemon
 * \return 0 on success
 */
int Send_Request(struct SHM_Data* ptr, int pid)
{
    if (pid != 0)
    {
      if (arguments.debug) fprintf(stderr, "DEBUG:  Enviar señal HANGUP a PID %d\n", pid);
      if (arguments.verbose && !arguments.debug) fprintf (stderr, "INFO:  Enviar señal HANGUP a PID %d\n", pid);
      return kill(pid, 1);
    }
    uint8_t last_state = 0;
    if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
    if (arguments.verbose && !arguments.debug) fprintf (stderr, "INFO:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");
    if (ptr->status != REQ_WAIT) 
    {
        if (!arguments.silent) fprintf (stderr, "ADVERTENCIA: argononed no está listo reintentar");
        return 1;
    }
    ptr->status = REQ_RDY;
    for(;ptr->status != REQ_WAIT;) 
    {
        if (last_state != ptr->status)
        {
            if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
            if (arguments.verbose && !arguments.debug) fprintf (stderr, "INFO:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");
            last_state = ptr->status;
            if (ptr->status == REQ_ERR)
            {
                if (!arguments.silent) fprintf (stderr, "ERROR:  Hubo un error en tus solicitudes.\n");
                return -1;
            }
        }
        msync(ptr,13,MS_SYNC);
    } 
    if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
    if (arguments.verbose && !arguments.debug) fprintf (stderr, "INFO:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");
    ptr->status = REQ_CLR;
   return 0;
}

/**
 * Send Reset Request and wait for reply
 * 
 * \param ptr Pointer to share memory data
 * \param pid PID of the daemon
 * \return 0 on success
 */
int Send_Reset(struct SHM_Data* ptr, int pid)
{
    if (pid != 0)
    {
      if (arguments.debug) fprintf(stderr, "DEBUG:  Enviar señal HANGUP a PID %d\n", pid);
      return kill(pid, 1);
    }
    uint8_t last_state = 0;
    if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
    if (ptr->status != REQ_WAIT) 
    {
        if (!arguments.silent) fprintf (stderr, "ADVERTENCIA: argononed no está listo reintentar");
        return 1;
    }
    ptr->status = REQ_CLR;
    for(;ptr->status != REQ_WAIT;) 
    {
        if (last_state != ptr->status)
        {
            if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
            last_state = ptr->status;
            if (ptr->status == REQ_ERR)
            {
                fprintf (stderr, "ERROR:  Hubo un error en tus solicitudes.\n");
                return -1;
            }
        }
        msync(ptr,13,MS_SYNC);
    } 
    if (arguments.debug) fprintf (stderr, "DEBUG:  Estado  %02x:%s\n",ptr->status, ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");// < 10 ? STATUS_STR[*status] : "Desconocido");
   return 0;
}
int main (int argc, char** argv)
{
    // if (getuid() != 0) {
    //     fprintf(stderr, "ERROR: Permissions error, must be run as root\n");
    //     exit(1);
    // }
    if (argc == 1 )
    {
      fprintf(stderr, "Uso: argonone-cli [OPCION...]\nTry `argonone-cli --help' or `argonone-cli --usage' para más información.\n");
      exit (1);
    }
    #if LOG_LEVEL == 6
    arguments.debug = 1;
    #endif
    struct SHM_Data* ptr;
    int shm_fd =  shm_open(SHM_FILE, O_RDWR, 0664);
    if (shm_fd == -1)
    {
      fprintf(stderr, "ERROR:  argononed no se está ejecutando o no tiene acceso a la memoria compartida.\n");
      exit(1);
    }
    ftruncate(shm_fd, SHM_SIZE);
    ptr = mmap(0, SHM_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (ptr == MAP_FAILED) {
        fprintf(stderr, "ERROR:  Error de mapa de memoria compartida\n");
        exit(1);
    }
    arguments.Schedule = &ptr->config;
    argp_parse (&argp, argc, argv, 0, 0, &arguments);
    FILE* file = fopen (LOCK_FILE, "r");
    int main_ret = 0;
    int d_pid = 0;
    if (file == NULL)
    {
        if (errno == 2)
        {
          if (!arguments.silent) fprintf(stderr, "ERROR:  argononed no se está ejecutando.\n");
          exit (1);
        }
        if (errno == 13)
        {
          if (!arguments.silent) fprintf(stderr,"INFO:  Si se ejecuta con un usuario normal, es posible que algunas funciones no funcionen.\n");
        } else {
          if (!arguments.silent) fprintf(stderr,"ERROR:  No se puede abrir %s [ %s ]\n",LOCK_FILE, strerror(errno));
          exit(1);
        }
    } else {
      fscanf (file, "%d", &d_pid);
      fclose (file);
      if (kill(d_pid, 0) != 0)
      {
          if (!arguments.silent) fprintf(stderr, "ERROR:  argononed no se está ejecutando.\n");
          exit (1);
      }
    }

    // if (arguments.debug) fprintf(stderr,">> ARGUMENT PARSE <<\nMODE\t%d\nTEMP\t%d\nFANS\t%d\n", arguments.mode, arguments.targettemp, arguments.fanoverride);

    if (arguments.mode < -2) 
    {


    } else {
        if (arguments.reset)
        {
            Send_Reset(ptr, 0);
        }
        if (arguments.mode > -1 && arguments.mode < 4)
        {
            if (arguments.mode == 3)
            {
              if (ptr->temperature <= arguments.targettemp)
              {
                  if (!arguments.silent) fprintf(stderr, "ERROR:  La CPU ya está por debajo de la temperatura objetivo\n");
                  return 1;
              }
              if (arguments.fanoverride == 0) arguments.fanoverride = 10;
            } 
            ptr->fanmode = arguments.mode;
            ptr->temperature_target = arguments.targettemp;
            ptr->fanspeed_Overide = arguments.fanoverride;
            // kill(d_pid, 1); // Send update message
            if (Send_Request(ptr, d_pid) != 0) main_ret = 1;
        }
        if (arguments.mode == 4)
        {
            ptr->fanmode = 0;
            ptr->temperature_target = 0;
            ptr->fanspeed_Overide = 0;

            if (arguments.reload) 
            {
              if (Send_Request(ptr, d_pid) != 0) main_ret = 1;
              // kill(d_pid, 1); // Send update message
            }
        }
        if (arguments.mode == -1 && arguments.reload)
        {
            if (Send_Request(ptr, d_pid) != 0) main_ret = 1;
        }
        if (arguments.mode == 5)
        {
          printf(">> DECODIFICANDO MEMORIA <<\n");
          printf("Estado del ventilador %s Velocidad %d%%\n", ptr->fanspeed == 0x00 ? "APAGADO" : "ENCENDIDO", ptr->fanspeed);
          printf("Temperatura del sistema %d°\n", ptr->temperature);
          printf("Hysteresis fijada en %d°\n",ptr->config.hysteresis);
          printf("Velocidad ventilador fijada en %d%% %d%% %d%%\n",ptr->config.fanstages[0],ptr->config.fanstages[1],ptr->config.fanstages[2]);
          printf("Temperaturas fijadas en %d° %d° %d°\n",ptr->config.thresholds[0],ptr->config.thresholds[1],ptr->config.thresholds[2]);
          printf("Modo del ventilador [ %s ] \n", RUN_STATE_STR[ptr->fanmode]);
          printf("Anular velocidad ventilador %d%% \n", ptr->fanspeed_Overide);
          printf("Temperatura objetivo %d° \n", ptr->temperature_target);
          printf("Estado del Daemon : %s\n", ptr->status < 10 ? STATUS_STR[ptr->status] : "Desconocido");
          printf("Temperatura máxima : %d°\n", ptr->stat.max_temperature);
          printf("Temperatura mínima : %d°\n", ptr->stat.min_temperature);
          printf("Advertencias del Daemon : %d\n", ptr->stat.EF_Warning);
          printf("Errores del Daemon : %d\n", ptr->stat.EF_Error);
          printf("Errores criticos del Daemon : %d\n", ptr->stat.EF_Critical);
        }
    }
    close(shm_fd);
    return main_ret;
}