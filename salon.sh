#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c ";

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1";
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  # list services
  $PSQL "select service_id, name from services order by service_id;" | while IFS='|' read ID NAME
  do
    echo -e "$ID) $NAME"
  done
  # get required service id and description
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
  # if not found, send to main menu with a message
  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  fi

  # get customer phone and name
  echo -e "\nPlease enter your phone number "
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';");
    # if not found
  if  [ -z $CUSTOMER_ID ]
  then
    # prompt for name
    echo -e "\nI don't have a record for that phone number. Please enter your name "
    read CUSTOMER_NAME
    # if name is null return to main menu
    [ -z $CUSTOMER_NAME ] && MAIN_MENU "Name is required. Please select a service."
    # insert a new customer
    res=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    # and get the new customer id
    CUSTOMER_ID=`$PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';"`
  else
    CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID;");
  fi;
  #echo "%$CUSTOMER_ID% => %$CUSTOMER_NAME%"
  # ask for time and insert a new appointment
  SERVICE_TIME="";
  while [ -z $SERVICE_TIME ]
  do
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME? "
    read SERVICE_TIME;
  done
  #echo -e "'$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE', '$SERVICE_TIME'"

  RES=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $RES == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  exit 0;
}

MAIN_MENU
