#!/bin/bash

# Инициализация двумерного ассоциативного массива "board" размером 4х4 и заполнение его нулями.
declare -A board=(
    [1,1]=0 [1,2]=0 [1,3]=0 [1,4]=0
    [2,1]=0 [2,2]=0 [2,3]=0 [2,4]=0
    [3,1]=0 [3,2]=0 [3,3]=0 [3,4]=0
    [4,1]=0 [4,2]=0 [4,3]=0 [4,4]=0
)

# Функция для вывода игрового поля. Внутри функции используется цикл for для прохода по каждому элементу двумерного массива "board".
function print_board {
    clear
    echo "----------------------"
    for ((i=1; i<=4; i++)); do
        for ((j=1; j<=4; j++)); do
            printf "|%4s" "${board[$i,$j]}"
        done
        echo "|"
        echo "----------------------"
    done
}

# Функция для перемещения кубика. В зависимости от введенного пользователем направления (w, a, s, d), кубики на игровом поле "board" перемещаются в соответствующую сторону.
function move {
    read -rsn1 direction
    case $direction in
        w) # Движение вверх
            for ((j=1; j<=4; j++)); do
                for ((i=2; i<=4; i++)); do
                    if [[ ${board[$i,$j]} != 0 ]]; then
                        for ((k=$i-1; k>=1; k--)); do
                            if [[ ${board[$k,$j]} == 0 ]]; then
                                board[$k,$j]=${board[$i,$j]}
                                board[$i,$j]=0
                            elif [[ ${board[$k,$j]} == ${board[$i,$j]} ]]; then
                                board[$k,$j]=$(( ${board[$k,$j]} * 2 ))
                                board[$i,$j]=0
                                break
                            else
                                break
                            fi
                        done
                    fi
                done
            done
		generate_cube
            ;;
        s) # Движение вниз
            for ((j=1; j<=4; j++)); do
                for ((i=3; i>=1; i--)); do
                    if [[ ${board[$i,$j]} != 0 ]]; then
                        for ((k=$i+1; k<=4; k++)); do
                            if [[ ${board[$k,$j]} == 0 ]]; then
                                board[$k,$j]=${board[$i,$j]}
                                board[$i,$j]=0
                            elif [[ ${board[$k,$j]} == ${board[$i,$j]} ]]; then
                                board[$k,$j]=$(( ${board[$k,$j]} * 2 ))
                                board[$i,$j]=0
                                break
                            else
                                break
                            fi
                        done
                    fi
                done
            done
		generate_cube
            ;;
        a) # Движение влево
            for ((i=1; i<=4; i++)); do
                for ((j=2; j<=4; j++)); do
                    if [[ ${board[$i,$j]} != 0 ]]; then
                        for ((k=$j-1; k>=1; k--)); do
                            if [[ ${board[$i,$k]} == 0 ]]; then
                                board[$i,$k]=${board[$i,$j]}
                                board[$i,$j]=0
                            elif [[ ${board[$i,$k]} == ${board[$i,$j]} ]]; then
                                board[$i,$k]=$(( ${board[$i,$k]} * 2 ))
                                board[$i,$j]=0
                                break
                            else
                        break
                        fi
                    done
                fi
            done
        done
	generate_cube
        ;;
    d) # Движение вправо
        for ((i=1; i<=4; i++)); do
            for ((j=3; j>=1; j--)); do
                if [[ ${board[$i,$j]} != 0 ]]; then
                    for ((k=$j+1; k<=4; k++)); do
                        if [[ ${board[$i,$k]} == 0 ]]; then
                            board[$i,$k]=${board[$i,$j]}
                            board[$i,$j]=0
                            break
                        elif [[ ${board[$i,$k]} == ${board[$i,$j]} ]]; then
                            board[$i,$k]=$(( ${board[$i,$k]} * 2 ))
                            board[$i,$j]=0
                            break
                        else
                            break
                        fi
                    done
                fi
            done
        done
	generate_cube
        ;;
    q) # Выход из игры
        exit
        ;;
    *) # Некорректный ввод
        echo "Некорректный ввод!"
        sleep 1
        ;;
esac
}

function check_game_win {
	#Функция для проверки выигрыша. Если на поле есть кубик со значением 2048, игрок выиграл игру.
    for ((i=1; i<=4; i++)); do
        for ((j=1; j<=4; j++)); do
            if [[ ${board[$i,$j]} == 2048 ]]; then
                echo "You Win!"
                exit
            fi
        done
    done
}
function generate_cube {
    # Создание массива свободных ячеек
    free_cells=()
    for ((i=1; i<=4; i++)); do
        for ((j=1; j<=4; j++)); do
            # Если ячейка пуста (имеет значение 0), добавляем ее в массив свободных ячеек
            if [[ ${board[$i,$j]} == 0 ]]; then
                free_cells+=("$i,$j")
            # Иначе, если ячейку можно сложить с кубиком, также добавляем ее в массив свободных ячеек
            elif [[ $i -gt 1 && ${board[$((i-1)),$j]} == ${board[$i,$j]} ]] ||
                 [[ $i -lt 4 && ${board[$((i+1)),$j]} == ${board[$i,$j]} ]] ||
                 [[ $j -gt 1 && ${board[$i,$((j-1))]} == ${board[$i,$j]} ]] ||
                 [[ $j -lt 4 && ${board[$i,$((j+1))]} == ${board[$i,$j]} ]]; then
                free_cells+=("$i,$j")
            fi
        done
    done

    # Если нет свободных ячеек для генерации нового кубика, выводим сообщение "Game over." и завершаем игру
    if [[ ${#free_cells[@]} == 0 ]]; then
        echo "Game over."
        exit 1
    # Иначе, генерируем новый кубик на случайной свободной ячейке
    else
        while true; do
            # Выбираем случайную свободную ячейку из массива свободных ячеек
            idx=$((RANDOM % ${#free_cells[@]}))
            row=${free_cells[idx]%,*}
            col=${free_cells[idx]#*,}
            # Задаем значение нового кубика (2 или 4)
            value=$((RANDOM % 2 ? 2 : 4))
            # Если выбранная ячейка пуста, помещаем в нее новый кубик и выходим из цикла
            if [[ ${board[$row,$col]} == 0 ]]; then
                board[$row,$col]=$value
                break
            # Иначе, если выбранная ячейка уже занята, удаляем ее из массива свободных ячеек и продолжаем цикл
            else
                unset free_cells[$idx]
                free_cells=("${free_cells[@]}")
                # Если больше нет свободных ячеек для генерации нового кубика, выводим сообщение "Game over." и завершаем игру
                if [[ ${#free_cells[@]} == 0 ]]; then
                    echo "Game over."
                    exit 1
                fi
            fi
        done
    fi
}
while true; do
	generate_cube
	print_board
	while true; do
		move
		print_board
        	check_game_win
	done
done
