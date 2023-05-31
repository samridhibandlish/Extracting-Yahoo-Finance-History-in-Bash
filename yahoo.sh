#!/bin/bash

# Function to register a user
register_user() {
    read -p "Enter your username: " username
    read -p "Enter your password: " password
    echo "$username $password" >> users.txt
    echo "User registered successfully!"
}

# Function to log in a user
login_user() {
    read -p "Enter your username: " username
    read -p "Enter your password: " password

    while IFS=' ' read -r user pass; do
        if [[ $user == $username && $pass == $password ]]; then
            echo "Logged in successfully!"
            return 0
        fi
    done < users.txt

    echo "Invalid username or password!"
    return 1
}

# Function to prompt for symbols and fetch data
choose_symbols() {
    read -p "Enter the symbols you want to track (comma-separated): " symbols
    IFS=',' read -ra symbol_array <<< "$symbols" 
}

# Function to show history
show_history() {
    for symbol in "${symbol_array[@]}"; do
        # Construct the API URL
        api_url="https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=5d"

        # Hit Yahoo Finance API and retrieve data
        api_response=$(curl -s "$api_url")

        # Parse and display the data using jq and awk
        echo "Historical data for $symbol:"

        echo "Timestamp: "
        echo "$api_response" | jq -r '.chart.result[0].timestamp as $ts | .chart.result[0].indicators.quote[0] | $ts' | awk '{ printf $1  $2  $3  $4  $5 }'
	echo 
        echo "High: "
        echo "$api_response" | jq -r '.chart.result[0].timestamp as $ts | .chart.result[0].indicators.quote[0] | .high[]' | awk '{ printf $1  $2  $3  $4  $5 } {printf ","} '
	echo 
        echo "Low: "
        echo "$api_response" | jq -r '.chart.result[0].timestamp as $ts | .chart.result[0].indicators.quote[0] | .low[]' | awk '{ printf $1  $2  $3  $4  $5 } {printf ","} '
	echo 
        echo "Close: "
        echo "$api_response" | jq -r '.chart.result[0].timestamp as $ts | .chart.result[0].indicators.quote[0] | .close[]' | awk '{ printf $1  $2  $3  $4  $5 } {printf ","} '
	echo 
        echo "Open: "
        echo "$api_response" | jq -r '.chart.result[0].timestamp as $ts | .chart.result[0].indicators.quote[0] | .open[]' | awk '{ printf $1  $2  $3  $4  $5 } {printf ","} '
	echo 
        echo
    done
}

# Main script
while true; do
    echo "1. Register"
    echo "2. Login"
    echo "3. Choose symbols"
    echo "4. Show history"
    echo "5. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            register_user
            ;;
        2)
            login_user
            ;;
        3)
            choose_symbols
            ;;
        4)
            show_history
            ;;
        5)
            echo "Thank you!"
            exit 0
            ;;
        *)
            echo "Invalid choice! Please try again."
            ;;
    esac

    echo
done
