#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
echo "Fel: Du måste köra scriptet som root."
exit 1
fi

# Kontrollera att minst ett användarnamn skickas in
if [ "$#" -eq 0 ]; then
echo "Användning: sudo ./create_users.sh användare1 användare2"
exit 1
fi

# Först: skapa alla användare
for username in "$@"
do
if id "$username" &>/dev/null; then
echo "Användaren $username finns redan."
else
useradd -m "$username"
echo "Användaren $username skapades."
fi
done

# Sedan: skapa mappar och welcome.txt
for username in "$@"
do
mkdir -p "/home/$username/Documents"
mkdir -p "/home/$username/Downloads"
mkdir -p "/home/$username/Work"

echo "Välkommen $username" > "/home/$username/welcome.txt"
echo "Andra användare i systemet:" >> "/home/$username/welcome.txt"

# Lista andra användare (utan nuvarande)
cut -d ':' -f 1 /etc/passwd | grep -v "^$username$" >> "/home/$username/welcome.txt"

# Sätt ägare
chown -R "$username:$username" "/home/$username"

# Sätt rättigheter
chmod 700 "/home/$username"
chmod 700 "/home/$username/Documents"
chmod 700 "/home/$username/Downloads"
chmod 700 "/home/$username/Work"
chmod 600 "/home/$username/welcome.txt"

done