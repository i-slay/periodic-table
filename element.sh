#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --tuples-only -c"

INPUT="$1"

if [[ -z $INPUT ]]
then
  echo "Please provide an element as an argument." 
  exit 0
fi

if [[ $INPUT =~ ^[0-9]+$ ]]
then
  VALUE="atomic_number='$INPUT'"
else
  VALUE="symbol='$INPUT' OR name='$INPUT'"
fi

RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE $VALUE")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< "$RESULT"
  {
    IFS="|" read -r MASS MELTING_POINT BOILING_POINT TYPE_ID
    TYPE=$($PSQL "SELECT DISTINCT(type) FROM types LEFT JOIN properties ON types.type_id = properties.type_id WHERE properties.type_id=$TYPE_ID")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  } < <($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
fi