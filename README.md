![banner](https://github.com/z-bj/Haircut-Spot-Appointment-Scheduler/blob/master/haircut-spot-banner.jpg)

![vim](https://img.shields.io/badge/Vim-019733.svg?style=for-the-badge&logo=Vim&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)![postgreSQL](https://camo.githubusercontent.com/281c069a2703e948b536500b9fd808cb4fb2496b3b66741db4013a2c89e91986/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f506f737467726553514c2d3331363139323f7374796c653d666f722d7468652d6261646765266c6f676f3d706f737467726573716c266c6f676f436f6c6f723d7768697465)

``` bash
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

```

### [User story](https://github.com/z-bj/Haircut-Spot-Appointment-Scheduler/blob/master/User_story.md)
