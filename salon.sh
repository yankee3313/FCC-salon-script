#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services order by service_id;")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU ;;
    2) SERVICE_MENU ;;
    3) SERVICE_MENU ;;
    4) EXIT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
    esac
}

SERVICE_MENU(){
  SERVICE_NAME=$($PSQL"select name from services where service_id = $SERVICE_ID_SELECTED;")
  # ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # get the customer_id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
  # add phone and name to customers table
  INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  # get new customer_id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
  fi
  # CUSTOMER_NAME=get name from database corresponding to id
  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")
  # ask time they would like to schedule
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/ *$|^ *//g'), $(echo $CUSTOMER_NAME | sed -r 's/ *$|^ *//g')?"
  read SERVICE_TIME
  # add appointment to appointments table
  INSERT_APPT_RESULT=$($PSQL "insert into appointments(service_id, customer_id, time) values('$SERVICE_ID_SELECTED','$CUSTOMER_ID', '$SERVICE_TIME');")
  # send to main menu
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/ *$|^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/ *$|^ *//g'). "
}

MAIN_MENU