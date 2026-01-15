#!/bin/bash
# install-kairos.sh - Instalación completa de KairOS
# Integra menú de niveles + tus scripts existentes

set -e

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones para mostrar mensajes
print_msg() { echo -e "${GREEN}[KairOS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Configuración
PACKAGE_DIR="/root/KairOS/packages"
SCRIPT_DIR="/root/KairOS/scripts"
LOG_FILE="/var/log/kairos-install.log"

# Verificar directorios
[ ! -d "$PACKAGE_DIR" ] && { print_error "Directorio $PACKAGE_DIR no encontrado"; exit 1; }
[ ! -d "$SCRIPT_DIR" ] && { print_error "Directorio $SCRIPT_DIR no encontrado"; exit 1; }

# ============================================
# PASO 1: ACTUALIZAR SISTEMA
# ============================================
print_msg "Paso 1: Actualizando sistema..."
loadkeys la-latin1
pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"

# ============================================
# PASO 2: SELECCIÓN DE NIVEL EDUCATIVO
# ============================================
print_msg "Paso 2: Selección del nivel educativo"
echo ""
echo "========================================="
echo "     SELECCIÓN DE NIVEL EDUCATIVO"
echo "========================================="
echo "1) Primaria (6-12 años)"
echo "2) Secundaria (12-16 años)"
echo "3) Bachillerato (16-18 años)"
echo "4) Universidad"
echo "5) Todos los niveles (recomendado)"
echo "========================================="
echo -n "Selecciona una opción [1-5]: "

read -r nivel_opcion

case $nivel_opcion in
    1) NIVELES=("primaria"); print_info "Configuración: PRIMARIA" ;;
    2) NIVELES=("secundaria"); print_info "Configuración: SECUNDARIA" ;;
    3) NIVELES=("bachillerato"); print_info "Configuración: BACHILLERATO" ;;
    4) NIVELES=("universidad"); print_info "Configuración: UNIVERSIDAD" ;;
    5) NIVELES=("primaria" "secundaria" "bachillerato" "universidad"); print_info "Configuración: TODOS LOS NIVELES" ;;
    *) print_error "Opción no válida. Usando 'Todos los niveles'"; NIVELES=("primaria" "secundaria" "bachillerato" "universidad") ;;
esac

# ============================================
# PASO 3: INSTALAR PAQUETES COMUNES
# ============================================
print_msg "Paso 3: Instalando paquetes comunes..."
if [ -f "$PACKAGE_DIR/common.txt" ]; then
    pacman -S --needed --noconfirm $(cat "$PACKAGE_DIR/common.txt") 2>&1 | tee -a "$LOG_FILE"
else
    print_error "common.txt no encontrado en $PACKAGE_DIR"
    exit 1
fi

# ============================================
# PASO 4: INSTALAR PAQUETES POR NIVEL
# ============================================
for nivel in "${NIVELES[@]}"; do
    archivo_nivel="$PACKAGE_DIR/${nivel}.txt"
    if [ -f "$archivo_nivel" ]; then
        print_msg "Instalando paquetes para $nivel..."
        pacman -S --needed --noconfirm $(cat "$archivo_nivel") 2>&1 | tee -a "$LOG_FILE"
    else
        print_warning "Archivo $archivo_nivel no encontrado, omitiendo..."
    fi
done

# ============================================
# PASO 5: INSTALAR YAY (AUR HELPER) - OPCIONAL
# ============================================
print_msg "Paso 5: Configuración AUR (opcional)..."
echo ""
echo "¿Deseas instalar yay (AUR helper) y paquetes AUR?"
echo "Esto permite instalar software como OnlyOffice, Google Chrome, etc."
echo -n "¿Instalar? [S/n]: "
read -r instalar_aur

if [[ "$instalar_aur" =~ ^[Ss]$ ]] || [[ -z "$instalar_aur" ]]; then
    # Instalar yay si no existe
    if ! command -v yay &> /dev/null; then
        print_info "Instalando yay..."
        cd /opt
        git clone https://aur.archlinux.org/yay.git 2>&1 | tee -a "$LOG_FILE"
        chown -R $SUDO_USER:$SUDO_USER yay/ 2>&1 | tee -a "$LOG_FILE"
        cd yay
        sudo -u $SUDO_USER makepkg -si --noconfirm 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Instalar paquetes AUR si existe el archivo
    if [ -f "$PACKAGE_DIR/aur.txt" ]; then
        print_info "Instalando paquetes AUR..."
        sudo -u $SUDO_USER yay -S --needed --noconfirm $(cat "$PACKAGE_DIR/aur.txt") 2>&1 | tee -a "$LOG_FILE"
    fi
else
    print_warning "Omitiendo instalación AUR"
fi

# ============================================
# PASO 6: EJECUTAR TUS SCRIPTS EXISTENTES
# ============================================
print_msg "Paso 6: Ejecutando scripts de configuración..."

# Función para ejecutar scripts de manera segura
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        print_info "Ejecutando $script_name..."
        bash "$script_path" 2>&1 | tee -a "$LOG_FILE"
        return 0
    else
        print_warning "Script $script_name no encontrado o no ejecutable"
        return 1
    fi
}

# Ejecutar tus scripts en orden (con verificación)
SCRIPTS=(
    "users.sh"      # Creación de usuarios
    "sudo.sh"       # Configuración sudo
    "services.sh"   # Habilitar servicios
    "firewall.sh"   # Configurar firewall
    "conf-hora.sh"  # Configurar hora
    "wallpapers.sh" # Fondos de pantalla
    "dconf.sh"      # Configuración GNOME
    "os-release.sh" # Información del SO
    "gdm-theme.sh"  # Tema GDM
)

for script in "${SCRIPTS[@]}"; do
    run_script "$script"
done

# ============================================
# PASO 7: CONFIGURACIÓN ESPECÍFICA POR NIVEL
# ============================================
print_msg "Paso 7: Aplicando configuraciones por nivel..."

for nivel in "${NIVELES[@]}"; do
    case $nivel in
        "primaria")
            print_info "Aplicando configuraciones para Primaria..."
            # Fuentes más grandes
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.interface text-scaling-factor 1.15 2>&1 | tee -a "$LOG_FILE"
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' 2>&1 | tee -a "$LOG_FILE"
            # Iconos grandes
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.nautilus.icon-view default-zoom-level 'large' 2>&1 | tee -a "$LOG_FILE"
            ;;
            
        "secundaria")
            print_info "Aplicando configuraciones para Secundaria..."
            # Configuración estándar
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.interface clock-format '24h' 2>&1 | tee -a "$LOG_FILE"
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view' 2>&1 | tee -a "$LOG_FILE"
            ;;
            
        "bachillerato")
            print_info "Aplicando configuraciones para Bachillerato..."
            # Productividad
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.session idle-delay 600 2>&1 | tee -a "$LOG_FILE"  # 10 minutos
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.screensaver lock-delay 1200 2>&1 | tee -a "$LOG_FILE"  # 20 minutos
            ;;
            
        "universidad")
            print_info "Aplicando configuraciones para Universidad..."
            # Máxima productividad
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.session idle-delay 0 2>&1 | tee -a "$LOG_FILE"  # No suspender
            sudo -u $SUDO_USER dbus-launch gsettings set org.gnome.desktop.notifications show-banners false 2>&1 | tee -a "$LOG_FILE"  # Sin notificaciones
            ;;
    esac
done

# ============================================
# PASO 8: HABILITAR SERVICIOS BÁSICOS
# ============================================
print_msg "Paso 8: Habilitando servicios básicos..."

SERVICIOS=(
    "gdm"
    "NetworkManager"
    "cups"
    "bluetooth"
    "avahi-daemon"
    "ufw"
)

for servicio in "${SERVICIOS[@]}"; do
    if systemctl list-unit-files | grep -q "$servicio.service"; then
        print_info "Habilitando $servicio..."
        systemctl enable "$servicio" 2>&1 | tee -a "$LOG_FILE"
    else
        print_warning "Servicio $servicio no encontrado"
    fi
done

# ============================================
# PASO 9: CONFIGURAR GRUB (si es necesario)
# ============================================
print_msg "Paso 9: Configurando GRUB..."
if [ -d /boot/efi ] && [ ! -f /boot/grub/grub.cfg ]; then
    print_info "Instalando GRUB para UEFI..."
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=KAIROS 2>&1 | tee -a "$LOG_FILE"
    grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tee -a "$LOG_FILE"
elif [ ! -f /boot/grub/grub.cfg ]; then
    print_info "Instalando GRUB para BIOS..."
    grub-install --target=i386-pc /dev/sda 2>&1 | tee -a "$LOG_FILE"
    grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tee -a "$LOG_FILE"
else
    print_info "GRUB ya está configurado"
fi

# ============================================
# FINALIZACIÓN
# ============================================
print_msg "✅ Instalación completada exitosamente!"
echo ""
echo "========================================="
echo "     RESUMEN DE INSTALACIÓN KAIROS"
echo "========================================="
echo "📊 Niveles instalados: ${NIVELES[*]}"
echo "📝 Log completo: $LOG_FILE"
echo "🖥️  Reinicia con: systemctl reboot"
echo ""
echo "🔧 Scripts ejecutados:"
for script in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        echo "  ✓ $script"
    else
        echo "  ✗ $script (no encontrado)"
    fi
done
echo "========================================="

# Crear archivo de identificación del sistema
cat > /etc/kairos-release << EOF
KairOS Educational Distribution
Niveles: ${NIVELES[*]}
Fecha instalación: $(date)
Versión: 1.0
EOF