$SCRIPT = ".\lab1wind.ps1"

$PASSED = 0
$TOTAL = 0

function Run-Test {
    param(
        [string]$TestName,
        [string]$InputData,
        [int]$ExpectedExit
    )

    $script:TOTAL++
    Write-Host "Тест $($script:TOTAL): $TestName"
    Write-Host "Ввод: '$InputData' | Ожидаемый код выхода: $ExpectedExit"

    $InputData | powershell -ExecutionPolicy Bypass -File $SCRIPT > $null 2>&1
    $ActualExit = $LASTEXITCODE

    if ($ActualExit -eq $ExpectedExit) {
        Write-Host "Результат: ПРОЙДЕН"
        $script:PASSED++
    } else {
        Write-Host "Результат: ПРОВАЛЕН"
    }
}

Write-Host "Запуск тестов"

if (-not (Test-Path $SCRIPT)) {
    Write-Host "Ошибка: скрипт $SCRIPT не найден в текущей директории" -ForegroundColor Red
    exit 1
}

Run-Test -TestName "Корректный ввод (50)" -InputData "50" -ExpectedExit 0
Run-Test -TestName "Корректный ввод (граница 1)" -InputData "1" -ExpectedExit 0
Run-Test -TestName "Корректный ввод (граница 100)" -InputData "100" -ExpectedExit 0
Run-Test -TestName "Некорректный ввод (текст вместо числа)" -InputData "abc" -ExpectedExit 1
Run-Test -TestName "Некорректный ввод (пусто)" -InputData "" -ExpectedExit 1

Write-Host ""
Write-Host "Пройдено тестов: $PASSED из $TOTAL"

if ($PASSED -eq $TOTAL) {
    Write-Host "Все тесты успешно пройдены" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Некоторые тесты завершились с ошибкой." -ForegroundColor Red
    exit 1
}
