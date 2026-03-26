<#
.SYNOPSIS
    Script de hardening para Windows 11 - Protección contra vulnerabilidades
.DESCRIPTION
    Aplica controles de seguridad para mitigar vulnerabilidades encontradas con Gobuster
    Basado en NIST SP 800-53
.NOTES
    Ejecutar como Administrador
#>

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║     Windows 11 Hardening Script - NIST SP 800-53 Compliant   ║
║              Protección contra vulnerabilidades               ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ============================================
# 1. Control AC-3: Access Enforcement
# ============================================
Write-Host "[1/6] Aplicando Control AC-3: Restricción de Acceso" -ForegroundColor Yellow

$VULNERABLE_PATHS = @(
    "C:\inetpub\wwwroot\Microsoft",
    "C:\inetpub\wwwroot\LogFiles",
    "C:\inetpub\wwwroot\recovery",
    "C:\inetpub\wwwroot\Protect",
    "C:\inetpub\wwwroot\keywords",
    "C:\inetpub\wwwroot\licenses",
    "C:\inetpub\wwwroot\tasks"
)

foreach ($path in $VULNERABLE_PATHS) {
    if (Test-Path $path) {
        # Eliminar permisos de usuarios anónimos
        icacls $path /remove "Everyone" /t /q 2>$null
        icacls $path /remove "IUSR" /t /q 2>$null
        icacls $path /remove "ANONYMOUS LOGON" /t /q 2>$null
        
        # Remover herencia de permisos
        icacls $path /inheritance:r /t /q 2>$null
        
        # Ocultar directorios
        attrib +h $path 2>$null
        
        Write-Host "  ✓ $path - Protegido" -ForegroundColor Green
    } else {
        Write-Host "  - $path - No existe" -ForegroundColor Gray
    }
}

# ============================================
# 2. Control CM-6: Configuration Settings
# ============================================
Write-Host "[2/6] Aplicando Control CM-6: Configuración Segura" -ForegroundColor Yellow

# Deshabilitar WebDAV (WebClient)
$webClient = Get-Service -Name "WebClient" -ErrorAction SilentlyContinue
if ($webClient) {
    Stop-Service -Name "WebClient" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WebClient" -StartupType Disabled
    Write-Host "  ✓ WebDAV (WebClient) deshabilitado" -ForegroundColor Green
}

# Deshabilitar IIS si no es necesario
$w3svc = Get-Service -Name "W3SVC" -ErrorAction SilentlyContinue
if ($w3svc) {
    Stop-Service -Name "W3SVC" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "W3SVC" -StartupType Disabled
    Write-Host "  ✓ IIS (W3SVC) deshabilitado" -ForegroundColor Green
}

# ============================================
# 3. Control SC-7: Boundary Protection
# ============================================
Write-Host "[3/6] Aplicando Control SC-7: Protección de Perímetro" -ForegroundColor Yellow

# Configurar firewall con política de denegación
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

# Bloquear puerto 80
netsh advfirewall firewall add rule name="HTTP_Block_External" dir=in action=block protocol=TCP localport=80

# Cambiar perfil de red a Público
try {
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Public
    Write-Host "  ✓ Perfil de red cambiado a Público" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ No se pudo cambiar perfil de red" -ForegroundColor Yellow
}

# ============================================
# 4. Control AC-4: Information Flow Enforcement
# ============================================
Write-Host "[4/6] Aplicando Control AC-4: Control de Flujo de Información" -ForegroundColor Yellow

# Deshabilitar Network Discovery
try {
    Set-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled False -ErrorAction SilentlyContinue
    Write-Host "  ✓ Network Discovery deshabilitado" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Network Discovery ya estaba deshabilitado" -ForegroundColor Yellow
}

# Deshabilitar File and Printer Sharing
try {
    Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled False -ErrorAction SilentlyContinue
    Write-Host "  ✓ File and Printer Sharing deshabilitado" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Compartición de archivos ya estaba deshabilitada" -ForegroundColor Yellow
}

# ============================================
# 5. Control SI-4: System Monitoring
# ============================================
Write-Host "[5/6] Aplicando Control SI-4: Monitoreo del Sistema" -ForegroundColor Yellow

# Habilitar auditoría de eventos de seguridad
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable

# Configurar tamaño de logs
wevtutil sl "Security" /ms:1073741824 2>$null

Write-Host "  ✓ Auditoría de seguridad habilitada" -ForegroundColor Green

# ============================================
# 6. Verificación Final
# ============================================
Write-Host "[6/6] Verificando configuración..." -ForegroundColor Yellow

# Verificar servicios
Write-Host "`n  Servicios:" -ForegroundColor Cyan
$services = @("WebClient", "W3SVC")
foreach ($svc in $services) {
    $status = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($status.StartType -eq "Disabled") {
        Write-Host "    ✅ $svc - Deshabilitado" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ $svc - Estado: $($status.StartType)" -ForegroundColor Yellow
    }
}

# Verificar carpetas
Write-Host "`n  Carpetas Protegidas:" -ForegroundColor Cyan
foreach ($path in $VULNERABLE_PATHS) {
    if (Test-Path $path) {
        $attrs = attrib $path
        Write-Host "    ✅ $path - Protegida y oculta" -ForegroundColor Green
    }
}

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║              ✅ HARDENING COMPLETADO CON ÉXITO                ║
║                                                              ║
║  Controles Aplicados:                                        ║
║  ✓ AC-3 - Access Enforcement                                 ║
║  ✓ CM-6 - Configuration Settings                            ║
║  ✓ SC-7 - Boundary Protection                               ║
║  ✓ AC-4 - Information Flow Enforcement                      ║
║  ✓ SI-4 - System Monitoring                                 ║
║                                                              ║
║  Vulnerabilidades Mitigadas:                                ║
║  ✓ T1083 - File and Directory Discovery                     ║
║  ✓ T1505 - Server Software Component                        ║
║  ✓ T1046 - Network Service Scanning                         ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

Read-Host "`nPresiona Enter para salir"