#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU(){
  #random generator 1-1000
  RANDOM_NUMBER=$(( (RANDOM%1000) + 1 ))
  NUMBER_OF_GUESSES=0
  #starter message
  echo Enter your username:
  read USERNAME
  #query if user already exists by username
  USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  #if not exists
  if [[ -z $USER_EXISTS ]]
  then
    #insert user into DB, set games_played to 0 to be incremented on completion of game
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', 0)")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  #ask for guess and store variable
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESSED_NUMBER
  #if not a valid number
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESSED_NUMBER
  else
    while [ $GUESSED_NUMBER -ne $RANDOM_NUMBER ]
    do
      #store attempts and increment
      ((NUMBER_OF_GUESSES++))
      #if guess is higher
      if [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read GUESSED_NUMBER
      #if guess is lower
      elif [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        read GUESSED_NUMBER
      fi
    done
    
    #if guessed properly
    if [[ $GUESSED_NUMBER = $RANDOM_NUMBER ]]
    then
      #increment games_played by 1
      INCREMENT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED + 1 WHERE username='$USERNAME'")
      
      #if best_game is null update number_of_guesses of current game
      if [[ -z $BEST_GAME ]]
      then
        INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
      #if number of guesses is less than best_game update new high score
      elif [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
      fi
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  fi
}

MAIN_MENU
