\# Windows 11 Hardening Guide - Auditoría y Protección



[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Kali Linux](https://img.shields.io/badge/Kali-Linux-blue)](https://www.kali.org/)
[![Windows 11](https://img.shields.io/badge/Windows-11-blue)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)](https://docs.microsoft.com/en-us/powershell/)
[![Gobuster](https://img.shields.io/badge/Gobuster-3.8+-orange)](https://github.com/OJ/gobuster)



## Tabla de Contenidos

- [Descripción](#descripción)

- [Arquitectura del Proyecto](#arquitectura-del-proyecto)

- [Metodología de Ataque (MITRE ATT\&CK)](#metodología-de-ataque-mitre-attck)

- [Fase 1: Instalación de Herramientas](#fase-1-instalación-de-herramientas)

- [Fase 2: Enumeración con Gobuster](#fase-2-enumeración-con-gobuster)

- [Fase 3: Análisis de Vulnerabilidades](#fase-3-análisis-de-vulnerabilidades)

- [Metodología de Defensa (NIST SP 800-53)](#metodología-de-defensa-nist-sp-800-53)

- [Fase 4: Hardening de Seguridad](#fase-4-hardening-de-seguridad)

- [Fase 5: Verificación](#fase-5-verificación)

- [Referencias](#referencias)



## Descripción



Este proyecto documenta un proceso completo de auditoría de seguridad en un sistema Windows 11, utilizando \*\*Gobuster\*\* como herramienta principal de enumeración. Se identifican las vulnerabilidades más comunes en configuraciones por defecto y se implementan medidas de hardening basadas en estándares internacionales.



### Objetivos

- Identificar vulnerabilidades en configuraciones por defecto de Windows 11

- Utilizar Gobuster para enumeración de directorios web

- Implementar controles de seguridad basados en NIST SP 800-53

- Documentar procedimientos de hardening replicables



## Arquitectura del Proyecto

windows-11-hardening/

├── README.md

├── docs/

│ ├── MITRE\_MAPPING.md # Mapeo de técnicas MITRE ATT\&CK

│ └── NIST\_CONTROLS.md # Controles NIST implementados

├── scripts/

│ ├── protect\_windows.ps1 # Script de hardening para Windows

│ └── verify.ps1 # Script de verificación

└── reports/

└── audit\_report.md # Reporte de auditoría





## Metodología de Ataque (MITRE ATT\&CK)



### Tácticas y Técnicas Identificadas



| Táctica MITRE | ID | Técnica | Descripción |

|--------------|-----|---------|-------------|

| Discovery | T1083 | File and Directory Discovery | Enumeración de directorios web con Gobuster |

| Discovery | T1046 | Network Service Scanning | Escaneo de servicios en puertos |

| Persistence | T1505 | Server Software Component | Explotación de configuraciones IIS/WebDAV |



## Fase 1: Instalación de Herramientas



### En Kali Linux



```bash

\# Actualizar repositorios

sudo apt update



\# Instalar Gobuster y herramientas necesarias

sudo apt install gobuster seclists curl -y



\# Verificar instalación

gobuster --version
```





## Fase 2: Enumeración con Gobuster

# 2.1 Escaneo Básico de Directorios
```bash
# Escaneo con diccionario común

gobuster dir -u http://{ip\_victim} -w /usr/share/wordlists/dirb/common.txt
```


Explicación de parámetros:


-dir: Modo directorio
-u: URL objetivo (IP de la máquina Windows)
-w: Wordlist o diccionario a utilizar

# 2.2 Escaneo con Extensiones de Archivo
```bash
# Buscar archivos con extensiones peligrosas
gobuster dir -u http://{ip_victim} -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,bak,zip,log,config,ini
```

Extensiones comunes vulnerables:

-.bak - Archivos de respaldo
-.config - Archivos de configuración
-.log - Archivos de registro
-.sql - Copias de bases de datos
-.zip - Archivos comprimidos


# 2.3 Escaneo con Mayor Velocidad

```bash
# Aumentar threads para escaneo más rápido
gobuster dir -u http://{ip\_victim} -w /usr/share/wordlists/dirb/common.txt -t 50
```

# 2.4 Escaneo Sigiloso (Menos Detectable)

# Escaneo con delay y pocos threads
```bash
gobuster dir -u http://{ip\_victim} -w /usr/share/wordlists/dirb/common.txt
  -t 3 
  --delay 2s 
  --useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

# 2.5 Guardar Resultados
```
# Guardar resultados en archivo
gobuster dir -u http://{ip\_victim} -w /usr/share/wordlists/dirb/common.txt -o resultados.txt

# Ver resultados
cat resultados.txt
```

# 2.6 Escaneo con Wordlist Personalizada
```
# Usar SecLists (wordlist más completa)
gobuster dir -u http://{ip\_victim} -w /usr/share/seclists/Discovery/Web-Content/common.txt -x php,asp,aspx,config
```

## Fase 3: Análisis de Vulnerabilidades

# 3.1 Interpretación de Resultados
Los resultados de Gobuster muestran:

Código HTTP	Significado	Riesgo
| Código HTTP | Significado | Riesgo |
| 200 OK |	Recurso existe y es accesible |	🔴 Alto |

| 301/302 |	Redirección - El recurso existe |	🟠 Medio |

| 403 | Forbidden	Existe pero acceso denegado | 🟡 Información |

| 404 | Not Found	No existe |	🟢 Sin riesgo |



# 3.2 Vulnerabilidades Comunes en Windows 11 por Defecto

| Vulnerabilidad |	Descripción |	Severidad	| MITRE ID

| Listado de Directorios |	IIS/WebDAV expone estructura de archivos |	Alta |	T1083

| WebDAV Habilitado |	Compartición web no segura |	Alta |	T1505

| Archivos de Respuesta |	Archivos .bak, .old expuestos |	Media |	T1083

| Directorios del Sistema |	/Microsoft/, /LogFiles/ expuestos |	Alta |	T1083



## Fase 4: Metodología de Defensa (NIST SP 800-53)

Controles de Seguridad Aplicados

| Control NIST |	Categoría |	Descripción |	Implementación |

| AC-3 |	Access Enforcement |	Control de acceso a recursos |	Restricción de permisos NTFS |

| CM-6 |	Configuration Settings |	Configuración segura |	Hardening de servicios |

| SC-7 |	Boundary Protection |	Protección de perímetro |	Reglas de firewall |

| SI-4 |	System Monitoring |	Monitoreo de seguridad |	Logs y alertas |


## Fase 5: Hardening de Seguridad

# 5.1 Script de Protección para Windows 11

Ejecutar en PowerShell como Administrador:
```bash
# scripts/protect_windows.ps1
<#
.SYNOPSIS
    Script de hardening para Windows 11 basado en NIST SP 800-53
.DESCRIPTION
    Aplica controles de seguridad para mitigar vulnerabilidades
#>

Write-Host "Windows 11 Hardening Script" -ForegroundColor Cyan

# 1. Aplicar Control AC-3: Restringir permisos de carpetas vulnerables
Write-Host "[1/4] Restringiendo permisos..." -ForegroundColor Yellow

$VULNERABLE_PATHS = @(
    "C:\inetpub\wwwroot\Microsoft",
    "C:\inetpub\wwwroot\LogFiles",
    "C:\inetpub\wwwroot\recovery",
    "C:\inetpub\wwwroot\Protect"
)

foreach ($path in $VULNERABLE_PATHS) {
    if (Test-Path $path) {
        # Eliminar permisos públicos
        icacls $path /remove "Everyone" /t /q 2>$null
        icacls $path /remove "IUSR" /t /q 2>$null
        icacls $path /remove "ANONYMOUS LOGON" /t /q 2>$null
        icacls $path /inheritance:r /t /q 2>$null
        
        # Ocultar directorios
        attrib +h $path 2>$null
        
        Write-Host "  ✓ $path" -ForegroundColor Green
    }
}

# 2. Aplicar Control CM-6: Deshabilitar servicios no seguros
Write-Host "[2/4] Deshabilitando servicios vulnerables..." -ForegroundColor Yellow

# Deshabilitar WebDAV
Set-Service -Name "WebClient" -StartupType Disabled
Stop-Service -Name "WebClient" -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ WebDAV deshabilitado" -ForegroundColor Green

# Deshabilitar IIS si no se utiliza
Stop-Service -Name "W3SVC" -Force -ErrorAction SilentlyContinue
Set-Service -Name "W3SVC" -StartupType Disabled -ErrorAction SilentlyContinue

# 3. Aplicar Control SC-7: Configurar Firewall
Write-Host "[3/4] Configurando firewall..." -ForegroundColor Yellow

# Bloquear puertos no seguros
netsh advfirewall firewall add rule name="Block_HTTP_External" dir=in action=block protocol=TCP localport=80

# Cambiar perfil de red a Público
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Public

Write-Host "  ✓ Firewall configurado" -ForegroundColor Green

# 4. Aplicar Control SI-4: Configurar monitoreo
Write-Host "[4/4] Configurando monitoreo..." -ForegroundColor Yellow

# Habilitar auditoría de seguridad
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable

Write-Host "  ✓ Monitoreo activado" -ForegroundColor Green

Write-Host "✅ Hardening completado con éxito" -ForegroundColor Green

```

# 5.2 Ejecutar el Script

```bash
# En Windows 11 como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd C:\Users\Administrator\Desktop
.\protect_windows.ps1
```
## ✅ Fase 6: Verificación
# 6.1 Desde Kali Linux - Verificar Protección
```bash
# Verificar que los directorios ya no son accesibles
curl -I http://{ip_victim}/Microsoft/
# Esperado: Connection Refused o 403 Forbidden

# Verificar puertos cerrados
nmap -p 80 {ip_victim}
# Esperado: filtered o closed
```

# 6.2 Script de Verificación en Windows
```bash
# scripts/verify.ps1
Write-Host "Verificando hardening..." -ForegroundColor Cyan

# Verificar servicios deshabilitados
$services = @("WebClient", "W3SVC")
foreach ($svc in $services) {
    $status = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($status.StartType -eq "Disabled") {
        Write-Host "✅ $svc - Deshabilitado" -ForegroundColor Green
    } else {
        Write-Host "❌ $svc - Aún activo" -ForegroundColor Red
    }
}

# Verificar permisos de carpetas
$paths = @("C:\inetpub\wwwroot\Microsoft", "C:\inetpub\wwwroot\LogFiles")
foreach ($path in $paths) {
    if (Test-Path $path) {
        $perms = icacls $path 2>$null
        if ($perms -match "Everyone") {
            Write-Host "❌ $path - Vulnerable" -ForegroundColor Red
        } else {
            Write-Host "✅ $path - Protegido" -ForegroundColor Green
        }
    }
}
```
## Resultados Esperados

# Antes del Hardening
- Directorios web expuestos (/Microsoft/, /LogFiles/)
- WebDAV habilitado
- Servicios HTTP accesibles

# Después del Hardening

- Acceso denegado a directorios sensibles
- WebDAV deshabilitado
- Firewall bloqueando accesos no autorizados

## 📚 Referencias
# MITRE ATT&CK Framework
- T1083 - File and Directory Discovery
- T1046 - Network Service Scanning
- T1505 - Server Software Component

# NIST Cybersecurity Framework
- NIST SP 800-53

# Herramientas Utilizadas

- Gobuster
- SecLists

### ⚠️ Aviso Legal
## Este material es solo para fines educativos. Realiza auditorías solo en sistemas que posees o para los que tienes autorización explícita.
