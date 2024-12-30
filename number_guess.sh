#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

QUERY_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $QUERY_USERNAME ]]
  then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ENTER_USER=$($PSQL "INSERT INTO users(username, games, turns) VALUES('$USERNAME', 0, 9999)")  
  else
  BEST_GAME=$($PSQL "SELECT turns FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games FROM users WHERE username='$USERNAME'")
  echo "$GAMES_PLAYED"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "$SECRET_NUMBER"

echo -e "\nGuess the secret number between 1 and 1000:"

GATHER_GUESS() {
read USERS_GUESS
until [[ $USERS_GUESS =~ ^[0-9]+$ ]]
  do
  echo "That is not an integer, guess again:"
  read USERS_GUESS
done
}

GATHER_GUESS
let COUNT=1

until [[ $USERS_GUESS -eq $SECRET_NUMBER ]]
  do
  if [[ $USERS_GUESS -gt $SECRET_NUMBER ]] 
    then
    echo "It's lower than that, guess again:"     
    GATHER_GUESS
    COUNT=$(($COUNT + 1))   
  else
    echo "It's higher than that, guess again:"
    GATHER_GUESS
    COUNT=$(($COUNT + 1))   
  fi
done

NEW_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
INSERT_NEW_GAMES_PLAYED=$($PSQL "UPDATE users SET games=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")
TURNS=$($PSQL "SELECT turns FROM users WHERE username='$USERNAME'")
if [[ $COUNT -lt $TURNS ]]
then 
  INSERT_NEW_BEST_SCORE=$($PSQL "UPDATE users SET turns=$COUNT WHERE username='$USERNAME'")
fi

echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

EXIT


EXIT() {
  echo -e "\nThanks for playing!"
}
