$LOG_DIR = Join-Path $env:USERPROFILE "log"
$LIMIT_MB = 10

Write-Host "start"

$PERCENT = Get-Random -Minimum 1 -Maximum 101

if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
}

Remove-Item -Path "$LOG_DIR\*" -Force -ErrorAction SilentlyContinue

$TARGET_KB = [math]::Floor($LIMIT_MB * $PERCENT * 1024 / 100)

$CURRENT_KB = 0
$FILE_NUM = 1

while ($CURRENT_KB -lt $TARGET_KB) {
    $FILE_PATH = Join-Path $LOG_DIR "file_$FILE_NUM.bin"
    
    $BYTES = New-Object byte[] (100 * 1024)
    [System.IO.File]::WriteAllBytes($FILE_PATH, $BYTES)
    
    $CURRENT_KB += 100
    $FILE_NUM++
}

Write-Host "files have been created: $($FILE_NUM - 1) total: $CURRENT_KB kb"
Write-Host ""
Write-Host "finish. folder: $LOG_DIR"
