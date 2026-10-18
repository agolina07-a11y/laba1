# Настройка переменных
$LOG_DIR = Join-Path $env:USERPROFILE "log"
$LIMIT_MB = 10

Write-Host "start"

# Генерация случайного процента от 1 до 100
$PERCENT = Get-Random -Minimum 1 -Maximum 101

# Создание папки (аналог mkdir -p)
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
}

# Удаление всех файлов в папке (аналог rm -f)
Remove-Item -Path "$LOG_DIR\*" -Force -ErrorAction SilentlyContinue

# Расчёт целевого размера в КБ
$TARGET_KB = [math]::Floor($LIMIT_MB * $PERCENT * 1024 / 100)

$CURRENT_KB = 0
$FILE_NUM = 1

# Создание файлов по 100 КБ каждый
while ($CURRENT_KB -lt $TARGET_KB) {
    $FILE_PATH = Join-Path $LOG_DIR "file_$FILE_NUM.bin"
    
    # Создание файла размером 100 КБ (102400 байт), заполненного нулями
    $BYTES = New-Object byte[] (100 * 1024)
    [System.IO.File]::WriteAllBytes($FILE_PATH, $BYTES)
    
    $CURRENT_KB += 100
    $FILE_NUM++
}

Write-Host "files have been created: $($FILE_NUM - 1) total: $CURRENT_KB kb"
Write-Host ""
Write-Host "finish. folder: $LOG_DIR"