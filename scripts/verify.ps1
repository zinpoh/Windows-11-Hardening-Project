<#
.SYNOPSIS
    Script de verificación de hardening en Windows 11
.DESCRIPTION
    Verifica que todas las medidas de seguridad estén correctamente aplicadas
#>

Write-Host "🔍 Verificando estado de hardening..." -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. Verificar servicios
# ============================================
Write-Host "[1/5] Verificando servicios..." -ForegroundColor Yellow

$services = @(
    @{Name="WebClient"; Desc="WebDAV - Compartición web"},
    @{Name="W3SVC"; Desc="IIS - Servidor web"}
)

foreach ($svc in $services) {
    $status = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($status) {
        if ($status.StartType -eq "Disabled") {
            Write-Host "  ✅ $($svc.Desc) - Deshabilitado" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($svc.Desc) - Aún activo ($($status.StartType))" -ForegroundColor Red
        }
    } else {
        Write-Host "  ℹ️ $($svc.Desc) - No instalado" -ForegroundColor Gray
    }
}

# ============================================
# 2. Verificar carpetas vulnerables
# ============================================
Write-Host "`n[2/5] Verificando carpetas vulnerables..." -ForegroundColor Yellow

$paths = @(
    "C:\inetpub\wwwroot\Microsoft",
    "C:\inetpub\wwwroot\LogFiles",
    "C:\inetpub\wwwroot\recovery"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        $perms = icacls $path 2>$null
        if ($perms -match "Everyone") {
            Write-Host "  ❌ $path - Permisos públicos encontrados!" -ForegroundColor Red
        } else {
            Write-Host "  ✅ $path - Permisos restringidos" -ForegroundColor Green
        }
    } else {
        Write-Host "  ℹ️ $path - No existe" -ForegroundColor Gray
    }
}

# ============================================
# 3. Verificar firewall
# ============================================
Write-Host "`n[3/5] Verificando firewall..." -ForegroundColor Yellow

$rule = netsh advfirewall firewall show rule name="HTTP_Block_External" 2>$null
if ($rule -match "Enabled") {
    Write-Host "  ✅ Regla HTTP_Block_External - Activa" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Regla HTTP_Block_External - No encontrada" -ForegroundColor Yellow
}

# Verificar política de firewall
$profile = netsh advfirewall show allprofiles | Select-String "Inbound Policy"
if ($profile -match "Block") {
    Write-Host "  ✅ Política de entrada: Bloquear" -ForegroundColor Green
}

# ============================================
# 4. Verificar Network Discovery
# ============================================
Write-Host "`n[4/5] Verificando Network Discovery..." -ForegroundColor Yellow

try {
    $ndStatus = Get-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled True -ErrorAction SilentlyContinue
    if ($ndStatus) {
        Write-Host "  ⚠ Network Discovery - Aún activo" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Network Discovery - Deshabilitado" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✅ Network Discovery - Deshabilitado" -ForegroundColor Green
}

# ============================================
# 5. Verificar puertos abiertos
# ============================================
Write-Host "`n[5/5] Verificando puertos abiertos..." -ForegroundColor Yellow

$openPorts = netstat -an | findstr "LISTENING" | findstr ":80 "
if ($openPorts) {
    Write-Host "  ❌ Puerto 80 - ABIERTO (posible riesgo)" -ForegroundColor Red
    Write-Host "     $openPorts" -ForegroundColor Red
} else {
    Write-Host "  ✅ Puerto 80 - CERRADO" -ForegroundColor Green
}

# ============================================
# Resumen final
# ============================================
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "VERIFICACIÓN COMPLETADA" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan

Read-Host "`nPresiona Enter para salir"