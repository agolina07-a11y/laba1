#!/bin/bash

SCRIPT="./lab1.sh"

PASSED=0
TOTAL=0

run_test() {
    local test_name="$1"
    local input_data="$2"
    local expected_exit="$3"

    TOTAL=$((TOTAL + 1))
    echo "----------------------------------------"
    echo "Тест $TOTAL: $test_name"
    echo "Ввод: '$input_data' | Ожидаемый код выхода: $expected_exit"

    echo "$input_data" | bash "$SCRIPT" > /dev/null 2>&1
    local actual_exit=$?

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo "Результат: ПРОЙДЕН"
        PASSED=$((PASSED + 1))
    else
        echo "Результат: ПРОВАЛЕН"
    fi
}

echo "ЗАПУСК ТЕСТОВ ДЛЯ LAB1.SH"

if [ ! -f "$SCRIPT" ]; then
    echo "Ошибка: скрипт $SCRIPT не найден в текущей директории"
    exit 1
fi

chmod +x "$SCRIPT"

run_test "Корректный ввод (50)" "50" 0
run_test "Корректный ввод (граница 1)" "1" 0
run_test "Корректный ввод (граница 100)" "100" 0
run_test "Некорректный ввод (текст вместо числа)" "abc" 1
run_test "Некорректный ввод (пусто)" "" 1

echo "Пройдено тестов: $PASSED из $TOTAL"

if [ "$PASSED" -eq "$TOTAL" ]; then
    echo "Все тесты успешно пройдены"
    exit 0
else
    echo "Некоторые тесты завершились с ошибкой."
    exit 1
fi
