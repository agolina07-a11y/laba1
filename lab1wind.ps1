# Настройка переменных
$LOG_DIR = Join-Path $env:USERPROFILE "log"
$LIMIT_MB = 10

# Запрос и валидация ввода
Write-Host "Enter an integer from 1 to 100:"
$N_str = Read-Host

if (-not ($N_str -match '^\d+$')) {
    Write-Host "Error: enter an integer"
    exit 1
}

$N = [int]$N_str
if ($N -lt 1 -or $N -gt 100) {
    Write-Host "Error: integer must be between 1 and 100"
    exit 1
}

# Проверка наличия папки
if (-not (Test-Path $LOG_DIR)) {
    Write-Host "Error: the folder '$LOG_DIR' not found"
    Write-Host "First, run test.sh (or equivalent) to create the file"
    exit 1
}

# Расчет размера папки (эмуляция du -sm, округление вверх до целых МБ)
$SizeBytes = (Get-ChildItem -Path $LOG_DIR -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
if ($null -eq $SizeBytes) { $SizeBytes = 0 }
$SIZE_MB = [math]::Ceiling($SizeBytes / 1MB)

$PERCENT = [math]::Round(($SIZE_MB / $LIMIT_MB) * 100, 2)

Write-Host ""
Write-Host "The folder size: $SIZE_MB MB, percentage of the limit: $PERCENT%"
Write-Host "Max: $N%"
Write-Host ""

# Проверка лимита
if ($PERCENT -le $N) {
    Write-Host "Everything is fine, folder isn't exceeding the $N% limit."
    exit 0
} else {
    Write-Host "Limit exceeded! Starting archiving..."

    # Расчет нехватки места
    $DIFF_PERCENT = [math]::Round($PERCENT - $N, 0)
    $LIMIT_KB = $LIMIT_MB * 1024
    $DIFF_KB = [math]::Floor(($LIMIT_KB * $DIFF_PERCENT) / 100)

    $FREED_KB = 0
    $FILES_TO_ARCHIVE = @()
    $COUNT = 0

    # Получение файлов (только в корне папки), сортировка по дате изменения (старые первые)
    $Files = Get-ChildItem -Path $LOG_DIR -File | Sort-Object LastWriteTime

    foreach ($FILE in $Files) {
        # Эмуляция du -k (округление размера файла вверх до целых КБ)
        $FILE_SIZE_KB = [math]::Ceiling($FILE.Length / 1KB)
        $FILES_TO_ARCHIVE += $FILE.FullName
        $FREED_KB += $FILE_SIZE_KB
        $COUNT++

        if ($FREED_KB -ge $DIFF_KB) {
            break
        }
    }

    # Архивация и удаление
    if ($COUNT -eq 0) {
        Write-Host "Nothing to archive."
    } else {
        $BACKUP_DIR = Join-Path $env:USERPROFILE "backup"
        if (-not (Test-Path $BACKUP_DIR)) {
            New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
        }
        
        $ARCHIVE = Join-Path $BACKUP_DIR "log_archive.tar.gz"

        # Формирование аргументов для tar.exe
        $tarArgs = @("-czf", $ARCHIVE) + $FILES_TO_ARCHIVE

        try {
            # Запуск встроенного в Windows tar
            & tar.exe @tarArgs

            if ($LASTEXITCODE -eq 0) {
                # Удаление оригинальных файлов
                foreach ($f in $FILES_TO_ARCHIVE) {
                    Remove-Item -Path $f -Force
                }
                Write-Host "Archived $COUNT files"
                Write-Host "$FREED_KB KB freed"
                Write-Host "Archive $ARCHIVE written"
            } else {
                Write-Host "ERROR of ARCHIVATION, files didn't deleted"
                exit 1
            }
        } catch {
            Write-Host "ERROR of ARCHIVATION: $_"
            exit 1
        }
    }
}