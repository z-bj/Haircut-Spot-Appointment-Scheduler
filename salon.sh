#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# title
echo -e "\n~~~~ Zak Salon Appointment Scheduler ~~~~\n"

# greeting/call for action
echo -e "\nWelcome to Zak Salon, what service would you like to book?\n"


# create function to loop through steps required to schedule the appoitment and update database
MAIN_MENU() {

  # error message
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  # get services available
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # format output
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
 
  # obtain user input
  echo -e "\nService number to book:"
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send back to beginning of main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # find service selected
      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # if service is not from selection give
      if [[ -z $SERVICE_NAME_SELECTED ]]
        then
          # send back to beginning of main menu
          MAIN_MENU "Sorry, that is not a valid service. Please choose again."
        else
          echo -e "\nYou have selected the service: $SERVICE_NAME_SELECTED"
          # obtain customers phone number to find them (phone has a UNIQUE constraint in the database)
          echo -e "\nWhat is your phone number?"
          read CUSTOMER_PHONE
          
          # get customers name
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

          # if not found
          if [[ -z $CUSTOMER_NAME ]]
            then
              # obtain the new customers name
              echo -e "\nWe could not find a record to that phone number. What is your name?"
              read CUSTOMER_NAME
              # insert new customer into database
              INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          fi
          
          # obtain service time
          echo -e "\n What time would you like to book the $SERVICE_NAME_SELECTED service, $CUSTOMER_NAME?"
          read SERVICE_TIME

          # get customer_id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          # insert appointment into database
          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")

          echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
          echo -e "\n Thank you for using our virtual appoitment scheduler. See you soon!"

      fi 
      
  fi

}

# call function so it runs when the script start
MAIN_MENU