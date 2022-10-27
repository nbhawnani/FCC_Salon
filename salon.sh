#! /bin/bash

echo -e '\n~~~~~ MY SALON ~~~~~\n'
echo -e '\nWelcome to My Salon, how can I help you?\n'

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

  # ask for service needed
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED
  echo $SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU 
  else
    # check if service exists
    SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # else send to main menu
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      # send to main menu
      echo 'I could not find that service. What would you like today?'
      MAIN_MENU 
    else
      #service available
      echo -e 'Got it. '$SERVICE_AVAILABILITY' it is.'
      echo 'What is your phone number?'
      read CUSTOMER_PHONE

      #check if customer exists
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo $CUSTOMER_ID

      if [[ -z $CUSTOMER_ID ]]
      then
        #Enter new customer
        echo 'I don't have a record for that phone number, what's your name?'
        read CUSTOMER_NAME
        echo 'What is the time?'
        read SERVICE_TIME
        RESULT=$($PSQL "insert into customers(phone,name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
        #Enter appointment for new customer:
        echo $CUSTOMER_ID
        RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      else
        #customer exists
        echo 'What is the time?'
        read SERVICE_TIME
        
        #Enter appointment for  customer:
        RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      fi

      CUST_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
      #Success message at the end
      echo 'I have put you down for a'$SERVICE_AVAILABILITY' at '$SERVICE_TIME','$CUST_NAME'.'

    
      
    fi

  fi


}

MAIN_MENU


