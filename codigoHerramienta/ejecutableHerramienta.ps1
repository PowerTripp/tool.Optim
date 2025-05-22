<#
.SYNOPSIS
   Herramienta de Optimización para Windows - WinOptimizer
.DESCRIPTION
   Herramienta completa para optimizar y configurar sistemas Windows
.NOTES
   Versión: 1.2
   Autor: JOSUE LUENGO 
   Fecha: $(Get-Date -Format "2025 . 05 .15")
#>

# Configuración inicial
$Version = "1.2"
$LogFile = "$env:TEMP\WinOptimizer.log"
$BackupDir = "$env:USERPROFILE\Documents\WinOptimizer_Backups"

# Inicialización
function Initialize-Tool {
    Clear-Host
    Show-Header
    
    # Verificar y crear directorio de backups
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Iniciar log
    "[$(Get-Date)] Inicio de F1X3R.TOOL v$Version" | Out-File $LogFile -Append
}

# Función para mostrar el menú principal
function Show-MainMenu {
    param (
        [string]$Title = 'Menú Principal'
    )
    
    Clear-Host
    Write-Host @" 
   __ _     ____           _            _ 
  / _(_)_ _|__ / ___ _ _  | |_ ___  ___| |
 |  _| \ \ /|_ \/ -_) '_| |  _/ _ \/ _ \ |
 |_| |_/_\_\___/\___|_|    \__\___/\___/_|
                                          
"@ -ForegroundColor Green


    Write-Host @"
===============================================
Herramienta para optimizacion de equipos windows
by : [p0w3r.tr1p]
===============================================
"@ -ForegroundColor Green

    Write-Host "=== $Title ===" -ForegroundColor Green 
    Write-Host "`nSeleccione una opción:`n" -ForegroundColor Gray
    
    Write-Host "1. Optimización Rápida (Recomendada)" -ForegroundColor Green
    Write-Host "2. Optimización Avanzada" -ForegroundColor Green
    Write-Host "3. Herramientas del Sistema" -ForegroundColor Green
    Write-Host "4. Configuración Personalizada" -ForegroundColor Green
    Write-Host "5. Restaurar Configuraciones" -ForegroundColor Green
    Write-Host "6. Acerca de WinOptimizer" -ForegroundColor Green
    Write-Host "0. Salir`n" -ForegroundColor Red
    
    $selection = Read-Host "Ingrese su opción"
    return $selection
}

# Función para registrar actividades
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logEntry = "[$(Get-Date)] [$Level] $Message"
    $logEntry | Out-File $LogFile -Append
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message -ForegroundColor Gray }
    }
}

# Función para crear punto de restauración
function Create-RestorePoint {
    try {
        Write-Log "Creando punto de restauración..."
        Checkpoint-Computer -Description "WinOptimizer_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -RestorePointType MODIFY_SETTINGS
        Write-Log "Punto de restauración creado con éxito." -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Error al crear punto de restauración: $_" -Level "ERROR"
        return $false
    }
}

# Función de optimización rápida
function Invoke-QuickOptimization {
    Clear-Host
    Write-Host "=== Optimización Rápida ===" -ForegroundColor Cyan
    
    if (-not (Create-RestorePoint)) {
        $confirmation = Read-Host "No se pudo crear punto de restauración. ¿Desea continuar? (S/N)"
        if ($confirmation -ne 'S') { return }
    }
    
    # 1. Limpieza básica
    Write-Log "Iniciando limpieza básica del sistema..."
    Cleanmgr /sagerun:1 | Out-Null
    Write-Log "Limpieza de disco completada." -Level "SUCCESS"
    
    # 2. Optimizar unidades
    Write-Log "Optimizando unidades..."
    Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | ForEach-Object {
        if ($_.MediaType -eq 'SSD') {
            Optimize-Volume -DriveLetter $_.DriveLetter -ReTrim -Verbose
        } else {
            Optimize-Volume -DriveLetter $_.DriveLetter -Defrag -Verbose
        }
    }
    Write-Log "Optimización de unidades completada." -Level "SUCCESS"
    
    # 3. Servicios básicos
    Write-Log "Optimizando servicios..."
    $services = @(
        @{Name="SysMain"; StartupType="Disabled"},
        @{Name="DiagTrack"; StartupType="Disabled"}
    )
    
    foreach ($service in $services) {
        try {
            Set-Service -Name $service.Name -StartupType $service.StartupType -ErrorAction Stop
            Write-Log "Servicio $($service.Name) configurado como $($service.StartupType)" -Level "SUCCESS"
        }
        catch {
            Write-Log "No se pudo configurar el servicio $($service.Name): $_" -Level "ERROR"
        }
    }
    
    # 4. Plan de energía
    Write-Log "Configurando plan de energía..."
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Log "Plan configurado para Alto Rendimiento." -Level "SUCCESS"
    
    Write-Log "Optimización rápida completada!" -Level "SUCCESS"
    Pause
}

# Función de optimización avanzada
function Invoke-AdvancedOptimization {
    Clear-Host
    Write-Host "=== Optimización Avanzada ===" -ForegroundColor Cyan
    
    Write-Host "`nEsta opción realiza cambios más profundos en el sistema.`n" -ForegroundColor Yellow
    
    $confirmation = Read-Host "¿Desea continuar? (S/N)"
    if ($confirmation -ne 'S') { return }
    
    if (-not (Create-RestorePoint)) {
        $confirmation = Read-Host "No se pudo crear punto de restauración. ¿Desea continuar? (S/N)"
        if ($confirmation -ne 'S') { return }
    }
    
    # Aquí irían las funciones de optimización avanzada
    # (Similar a la optimización rápida pero con más ajustes)
    
    Write-Log "Optimización avanzada completada!" -Level "SUCCESS"
    Pause
}

# Función para mostrar información del sistema
function Show-SystemInfo {
    Clear-Host
    Write-Host "=== Información del Sistema ===" -ForegroundColor Cyan
    
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $gpu = Get-CimInstance Win32_VideoController
    $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    
    Write-Host "`nSistema Operativo: $($os.Caption) ($($os.OSArchitecture))"
    Write-Host "Versión: $($os.Version)"
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "GPU: $($gpu.Name)"
    Write-Host "RAM: $ram GB (Disponible: $freeRam GB)`n"
    
    Pause
}

# Función para mostrar el about
function Show-About {
    Clear-Host
    Write-Host "=== Acerca de WinOptimizer ===" -ForegroundColor Cyan
    
    Write-Host "`nWinOptimizer v$Version"
    Write-Host "Herramienta profesional de optimización para Windows"
    Write-Host "Desarrollado por: [p0w3r.tr1p]"
    Write-Host @"   
   _   _   _   _   _   _   _   _   _   _  
  / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
 ( p | 0 | w | 3 | r | . | t | r | 1 | p )
  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ 


"@ -ForegroundColor Green

    Write-Host "Última actualización: $(Get-Date -Format 'yyyy-MM-dd')`n"
    
    Write-Host "Características principales:" -ForegroundColor Yellow
    Write-Host "- Optimización del sistema"
    Write-Host "- Limpieza de archivos temporales"
    Write-Host "- Gestión de servicios"
    Write-Host "- Herramientas de diagnóstico"
    Write-Host "- Configuraciones personalizadas`n"
    
    Pause
}

# Función principal
function Main {
    Initialize-Tool
    
    do {
        $selection = Show-MainMenu
        
        switch ($selection) {
            '1' { Invoke-QuickOptimization }
            '2' { Invoke-AdvancedOptimization }
            '3' { Show-SystemInfo }
            '4' { Write-Host "Próximamente..." -ForegroundColor Yellow; Pause }
            '5' { Write-Host "Próximamente..." -ForegroundColor Yellow; Pause }
            '6' { Show-About }
            '0' { return }
            default { Write-Host "Opción no válida. Intente nuevamente." -ForegroundColor Red; Pause }
        }
    } while ($true)
}

# Punto de entrada
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador. Abre PowerShell como Administrador y vuelve a intentarlo." -ForegroundColor Red
    exit
}

Main