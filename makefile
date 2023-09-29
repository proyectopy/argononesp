# ********************************************************************
# Argonone Daemon Makefile
# ********************************************************************
CC           = gcc
RM           = rm -v
DTC          = dtc -@ -I dts -O dtb -o
BASH         = bash
INSTALL      = install
CFLAGS       = -Wall -s -O3
LFLAGS       = -lpthread -lrt
LFLAGS3      = -lrt
OBJ_DAEMON   = build/argononed.o build/event_timer.o
OBJ_CLI      = src/argonone-cli.c
BIN_DAEMON   = argononed
BIN_SHUTDOWN = argonone-shutdown
BIN_CLI      = argonone-cli
OVERLAY      = argonone.dtbo
GCCVER       = $(shell expr `gcc -dumpversion | cut -f1 -d.` \>= 10)
USERID	     = $(shell id -u)
LOGLEVEL     = 5

-include makefile.conf
ifndef BOOTLOC
BOOTLOC = /boot
endif
ifndef INITSYS
INITSYS = SYSTEMD
endif
ifndef I2CHELPER
I2CHELPER = 0
endif
ifndef AUTOCOMP
AUTOCOMP = 0
endif
ifndef LOGROTATE
LOGROTATE = 0
endif
ifdef DISABLE_POWER_BUTTON_SUPPORT
CFLAGS += -DDISABLE_POWER_BUTTON_SUPPORT
endif
ifdef USE_SYSFS_TEMP
CFLAGS += -DUSE_SYSFS_TEMP=$(USE_SYSFS_TEMP)
endif
ifdef RUN_IN_FOREGROUND
CFLAGS += -DRUN_IN_FOREGROUND
endif
ifdef ENABLE_COMPILE_WARNINGS
CFLAGS += -Wextra -Wconversion -Wunused -Wuninitialized
ifeq ($(GCCVER), 1)
	CFLAGS  += -fanalyzer
endif
endif

-include OS/_common/$(INITSYS).in
-include OS/$(DISTRO)/makefile.in

ifndef CONFIGURED
ifeq (,$(wildcard makefile.conf))
$(warning Falta la configuración o no es correcta)
endif
endif

ifeq (install,$(findstring install, $(MAKECMDGOALS)))
ifneq ($(USERID), 0)
$(error "(Des)Instalar requiere privilegios elevados")
endif
ifeq ($(PACKAGESYS),ENABLED)
$(error "(Des)Instalar no es compatible con el sistema de paquetes")
endif
endif
ifeq (update,$(findstring update, $(MAKECMDGOALS)))
ifneq ($(USERID), 0)
$(error "La actualización requiere privilegios elevados")
endif
ifeq ($(PACKAGESYS),ENABLED)
$(error "La actualización no es compatible con el sistema de paquetes")
endif
endif

.DEFAULT_GOAL := all



build/%.o: src/%.c
	@echo "Compilando $<"
	$(CC) -c -o $@ $< $(CFLAGS) -DLOG_LEVEL=$(LOGLEVEL) 

$(BIN_DAEMON): $(OBJ_DAEMON)
	@echo "Creando $(BIN_DAEMON)"
	$(CC) -o build/$(BIN_DAEMON) $^ $(CFLAGS) $(LFLAGS)

$(BIN_SHUTDOWN): src/argonone-shutdown.c
	@echo "Creando $(BIN_SHUTDOWN)"
	$(CC) -o build/$(BIN_SHUTDOWN) $^ $(CFLAGS)

$(BIN_CLI): $(OBJ_CLI) 
	@echo "Creando $(BIN_CLI)"
	$(CC) -o build/$(BIN_CLI) $^ $(CFLAGS) -DLOG_LEVEL=$(LOGLEVEL) $(LFLAGS3)

$(OVERLAY): src/argonone.dts
	@echo "Creando $@"
	$(DTC) build/$@ $<

.PHONY: overlay
overlay: $(OVERLAY)
	@echo "MAKE: Overlay"

.PHONY: daemon
daemon: $(BIN_DAEMON) $(BIN_SHUTDOWN)
	@echo "MAKE: Daemon"

.PHONY: cli
cli: $(BIN_CLI)
	@echo "MAKE: CLI"

.PHONY: all
all:: daemon cli overlay
	@echo "MAKE: Completado"

ifdef MAKE_OVERRIDES
-include OS/$(DISTRO)/override.in
endif

ifndef OVERRIDE_INSTALL_DAEMON
.PHONY: install-daemon
install-daemon:
	@echo -n "Instalando daemon "
	@$(INSTALL) build/$(BIN_DAEMON) /usr/sbin/$(BIN_DAEMON) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
ifeq ($(LOGROTATE),1)
	@$(INSTALL) -m 600 OS/_common/argononed.logrotate /etc/logrotate.d/argononed
endif
endif

ifndef OVERRIDE_INSTALL_CLI
.PHONY: install-cli
install-cli:
	@echo -n "Instalando CLI "
	@$(INSTALL) -m 0755 build/$(BIN_CLI) /usr/bin/$(BIN_CLI) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
ifeq ($(AUTOCOMP), 1)
	@echo -n "Instalando CLI autocompletar para bash "
	@$(INSTALL) -m 755 OS/_common/argonone-cli-complete.bash /etc/bash_completion.d/argonone-cli 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
endif
endif

ifndef OVERRIDE_INSTALL_OVERLAY
.PHONY: install-overlay
install-overlay:
	@echo -n "Instalando overlay "
	@$(INSTALL) build/argonone.dtbo $(BOOTLOC)/overlays/argonone.dtbo 2>/dev/null && echo "Correcto" || { echo "Fallido"; }
	@$(BASH) OS/_common/setup-overlay.sh $(BOOTLOC)/config.txt
endif

ifndef OVERRIDE_INSTALL_SERVICE
.PHONY: install-service
install-service:
	@echo "Instalando servicios "
	@echo -n "argononed.service ... "
	@$(INSTALL) -m $(SERVICE_FILE_PERMISSIONS) $(SERVICE_FILE) $(SERVICE_PATH) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; } 
	@echo -n "argonone-shutdown ... "
	@$(INSTALL) $(SHUTDOWN_FILE) $(SHUTDOWN_PATH) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
ifeq ($(INITSYS), SYSTEMD)
	@echo "Actualizando lista de servicios"
	@systemctl daemon-reload
endif
	@echo -n "Activar Servicio "
	@$(SERVICE_ENABLE) argononed &>/dev/null && echo "Correcto" || { echo "Fallido"; }
	@echo -n "Arrancando Servicio "
	@timeout 5s $(SERVICE_START) &>/dev/null && echo "Correcto" || { ( [ $$? -eq 124 ] && echo "Timeout" || echo "Fallido" ) }
endif

.PHONY: install
install:: install-daemon install-cli install-service install-overlay
ifeq ($(shell if [ -f /usr/bin/argononed ]; then echo 1; fi), 1)
	@echo -n "Borrando antiguo daemon ... "
	@$(RM) /usr/bin/argononed 2>/dev/null&& echo "Correcto" || { echo "Fallido"; true; }
endif
	@echo "Instalación completada"

.PHONY: update
update:: install-daemon install-cli install-service
ifeq ($(shell if [ -f /usr/bin/argononed ]; then echo 1; fi), 1)
	@echo -n "Borrando antiguo daemon ... "
	@$(RM) /usr/bin/argononed 2>/dev/null&& echo "Correcto" || { echo "Fallido"; true; }
endif
	@echo "Actualización Completada"

ifndef OVERRIDE_UNINSTALL
.PHONY: uninstall
uninstall::
	@echo -n "Parando Servicio ... "
	@$(SERVICE_STOP) &>/dev/null && echo "Correcto" || { echo "Fallido"; }
	@echo -n "Desactivando Servicio ... "
	@$(SERVICE_DISABLE) &>/dev/null && echo "Correcto" || { echo "Fallido"; }
	@echo -n "Borrado del servicio ... "
	@$(RM) $(SERVICE_PATH) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
ifeq ($(INITSYS), OPENRC)
	@echo -n "Barrado del servicio de apagado ... "
	@$(RM) $(SHUTDOWN_PATH) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
	@echo -n "Borrado del argonone-shutdown ... "
	@$(RM) /usr/*bin/shutdown_argonone 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
else
	@echo -n "Borrado del argonone-shutdown ... "
	@$(RM) $(SHUTDOWN_PATH) 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
endif
	@echo -n "Borrado de overlay ... "
	@$(RM) $(BOOTLOC)/overlays/argonone.dtbo 2>/dev/null && echo "Correcto" || { echo "Fallido"; }
	@echo -n "Borrado de daemon ... "
	@$(RM) /usr/*bin/argononed 2>/dev/null&& echo "Correcto" || { echo "Fallido"; true; }
	@echo -n "Borrado de cli-tool ... "
	@$(RM) /usr/bin/argonone-cli 2>/dev/null&& echo "Correcto" || { echo "Fallido"; true; }
	@echo -n "Borrado de autocomplete para cli ... "
	$(RM) /etc/bash_completion.d/argonone-cli 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
	@echo -n "Borrado de la configuración de logrotate ... "
	$(RM) /etc/logrotate.d/argononed 2>/dev/null && echo "Correcto" || { echo "Fallido"; true; }
	@echo "Borrado de dtoverlay=argonone de $(BOOTLOC)/config.txt"
	@cp $(BOOTLOC)/config.txt $(BOOTLOC)/config.argonone.backup
	@sed -i '/dtoverlay=argonone/d' $(BOOTLOC)/config.txt
	@echo "Desinstalación completada"
endif

.PHONY: clean
clean::
	-@$(RM) *.o 2>/dev/null || true
	-@$(RM) argonone.dtbo 2>/dev/null || true
	-@$(RM) $(BIN_DAEMON) 2>/dev/null || true
	-@$(RM) $(BIN_SHUTDOWN) 2>/dev/null || true
	-@$(RM) $(BIN_CLI) 2>/dev/null || true
	-@$(RM) build/* 2>/dev/null || true

.PHONY: mrproper
mrproper: clean
	-@$(RM) makefile.conf 2>/dev/null || true

.PHONY: dumpvars
dumpvars:
	@$(foreach V,$(sort $(.VARIABLES)), $(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))

