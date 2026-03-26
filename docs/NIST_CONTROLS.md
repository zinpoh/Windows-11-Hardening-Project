\# Controles NIST SP 800-53 Implementados



\## Resumen de Controles



| Control | Categoría | Implementación | Estado |

|---------|-----------|----------------|--------|

| \*\*AC-3\*\* | Access Enforcement | Eliminación de permisos Everyone/IUSR, herencia removida | ✅ |

| \*\*CM-6\*\* | Configuration Settings | Deshabilitación de WebDAV, IIS | ✅ |

| \*\*SC-7\*\* | Boundary Protection | Firewall bloqueando puerto 80, perfil público | ✅ |

| \*\*AC-4\*\* | Information Flow Enforcement | Network Discovery deshabilitado | ✅ |

| \*\*SI-4\*\* | System Monitoring | Auditoría de eventos habilitada | ✅ |



\## Detalle de Implementación



\### AC-3: Access Enforcement

\*\*Objetivo:\*\* Controlar quién puede acceder a los recursos del sistema.



\*\*Implementación:\*\*

```powershell

\# Eliminar permisos públicos

icacls C:\\inetpub\\wwwroot\\Microsoft /remove "Everyone" /t

icacls C:\\inetpub\\wwwroot\\Microsoft /inheritance:r /t



\# Ocultar directorios

attrib +h C:\\inetpub\\wwwroot\\Microsoft

CM-6: Configuration Settings
Objetivo: Establecer configuraciones de seguridad por defecto.

Implementación:
# Deshabilitar WebDAV
Set-Service -Name "WebClient" -StartupType Disabled
Stop-Service -Name "WebClient" -Force

SC-7: Boundary Protection
Objetivo: Proteger el perímetro de la red.

Implementación:
# Bloquear puerto 80
netsh advfirewall firewall add rule name="HTTP_Block" dir=in action=block protocol=TCP localport=80

# Cambiar perfil de red
Set-NetConnectionProfile -NetworkCategory Public

Referencias
NIST SP 800-53 Rev. 5


---

## Paso 3: Inicializar Git y Subir a GitHub

### 3.1 Verificar que Git está instalado

```powershell
# Verificar Git
git --version

# Si no está instalado, descargar de:
# https://git-scm.com/download/win


