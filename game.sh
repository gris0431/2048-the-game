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
        ;;
    q) # Выход из игры
        exit
        ;;
    *) # Некорректный ввод
        echo "Некорректный ввод!"
        sleep 1
        ;;
esac
generate_cube
}
function check_game_over {
	# Если все ячейки на поле заполнены и нет возможности объединить кубики - конец игры
	for ((i=1; i<=4; i++)); do
		for ((j=1; j<=4; j++)); do
			if [[ {board[i,$j]} == 0 ]]; then
				return 1 # Продолжаем игру
			elif [[ $i -lt 4 && ${board[$i,$j]} == ${board[$((i+1)),$j]} ]]; then
				return 1 # Продолжаем игру
			elif [[ $i -lt 4 && ${board[$i,$j]} == ${board[$i,$((j+1))]} ]]; then
				return 1 # Продолжаем игру
			fi
		done
	done

	echo "Игра окончена!"
	exit
}
function check_game_win {
	#Функция для проверки выигрыша. Если на поле есть кубик со значением 2048, игрок выиграл игру.
    for ((i=1; i<=4; i++)); do
        for ((j=1; j<=4; j++)); do
            if [[ ${board[$i,$j]} == 2048 ]]; then
                echo "Вы выиграли!"
                exit
            fi
        done
    done
}
function generate_cube {
	#Функция для генерации нового кубика с вероятностью 50% на пустом месте на игровом поле.
    while true; do
        x=$(( RANDOM % 4 + 1 ))
        y=$(( RANDOM % 4 + 1 ))
        if [[ ${board[$x,$y]} == 0 ]]; then
            board[$x,$y]=$(( RANDOM % 2 ? 4 : 2 )) # С вероятностью 50% генерируем 2 или 4
            echo "Сгенерирован кубик ${board[$x,$y]} на позиции $x,$y"
            break
        fi
    done
}
#Бесконечный цикл, который вызывает функцию для генерации нового кубика и вывода игрового поля. Затем входит во внутренний бесконечный цикл, который обрабатывает ходы пользователя, выводит игровое поле и проверяет условия окончания или выигрыша игры. Если игра закончилась или пользователь выиграл, внутренний цикл прерывается, и игра начинается снова.
while true; do
	generate_cube
	print_board
	while true; do
		move
		print_board
		check_game_over
        	check_game_win
	done
done
