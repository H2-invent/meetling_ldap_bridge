echo Welcome to the installer:
FILE=docker.conf
if [ -f "$FILE" ]; then
  source $FILE
else
  touch $FILE
    KEYCLOAK_PW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    KEYCLOAK_ADMIN_PW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    echo "KEYCLOAK_PW=$KEYCLOAK_PW" >> $FILE
    echo "KEYCLOAK_ADMIN_PW=$KEYCLOAK_ADMIN_PW" >> $FILE
    echo "NEW_UUID=$NEW_UUID" >> $FILE
  source $FILE
fi
  USELETSENCRYPT=${USELETSENCRYPT:=yes}
  read -p "Do you want to use letsencryt? (If no, add your certs and key in traefik/certs)yes/no[$USELETSENCRYPT]: " input
  USELETSENCRYPT=${input:=$USELETSENCRYPT}
  sed -i '/USELETSENCRYPT/d' $FILE
  echo "USELETSENCRYPT=$USELETSENCRYPT" >> $FILE


  PUBLIC_URL=${PUBLIC_URL:=dev.domain.de}
  read -p "Enter the url you want to enter the meetling ldap bridge [$PUBLIC_URL]: " input
  PUBLIC_URL=${input:=$PUBLIC_URL}
  sed -i '/PUBLIC_URL/d' $FILE
  echo "PUBLIC_URL=$PUBLIC_URL" >> $FILE

  echo --------------------------------------------------------------------------
  echo -----------------We looking for all the other parameters-------------------
  echo --------------------------------------------------------------------------
  echo -------------------------------------------------------------
  echo -----------------Mailer--------------------------------------
  echo -------------------------------------------------------------
  smtpHost=${smtpHost:=localhost}
  read -p "Enter smtp host: [$smtpHost]" input
  smtpHost=${input:=$smtpHost}
  sed -i '/smtpHost/d' $FILE
  echo "smtpHost=$smtpHost" >> $FILE

  smtpPort=${smtpPort:=587}
  read -p "Enter smtp port [$smtpPort]: " input
  smtpPort=${input:=$smtpPort}
  sed -i '/smtpPort/d' $FILE
  echo "smtpPort=$smtpPort" >> $FILE

  smtpUsername=${smtpUsername:=username}
  read -p "Enter smtp username [$smtpUsername]: " input
  smtpUsername=${input:=$smtpUsername}
  sed -i '/smtpUsername/d' $FILE
  echo "smtpUsername=$smtpUsername" >> $FILE


  smtpPassword=${smtpPassword:=password}
  read -p "Enter smtp password [$smtpPassword]: " input
  smtpPassword=${input:=$smtpPassword}
  sed -i '/smtpPassword/d' $FILE
  echo "smtpPassword=$smtpPassword" >> $FILE


  smtpEncryption=${smtpEncryption:=none}
  read -p "Enter SMTP encrytion tls/ssl/none: [$smtpEncryption]" input
  smtpEncryption=${input:=$smtpEncryption}
  sed -i '/smtpEncryption/d' $FILE
  echo "smtpEncryption=$smtpEncryption" >> $FILE

  smtpFrom=${smtpFrom:=test@local.de}
  read -p "Enter smtp FROM mail:[$smtpFrom] " input
  smtpFrom=${input:=$smtpFrom}
  sed -i '/smtpFrom/d' $FILE
  echo "smtpFrom=$smtpFrom" >> $FILE


  echo -------------------------------------------------------------
  echo -----------------we build the KEycloak-----------------------
  echo -------------------------------------------------------------
sed -i "s|<clientsecret>|$NEW_UUID|g" keycloak/realm-export.json
sed -i "s|<clientUrl>|$HTTP_METHOD://$PUBLIC_URL|g" keycloak/realm-export.json

sed -i "s|<smtpPassword>|$smtpPassword|g" keycloak/realm-export.json
sed -i "s|<smtpPort>|$smtpPort|g" keycloak/realm-export.json
sed -i "s|<smtpHost>|$smtpHost|g" keycloak/realm-export.json
sed -i "s|<smtpFrom>|$smtpFrom|g" keycloak/realm-export.json
sed -i "s|<smtpUser>|$smtpUsername|g" keycloak/realm-export.json


if [ "$smtpEncryption" == 'tls' ]; then
   sed -i "s|<smtpEncyption>|\"starttls\": \"true\",|g" keycloak/realm-export.json
elif [ "$smtpEncryption" == 'ssl' ]; then
   sed -i "s|<smtpEncyption>| \"ssl\": \"true\",|g" keycloak/realm-export.json
   else
     sed -i "s|<smtpEncyption>| \"ssl\": \"false\",\n\"starttls\": \"false\",|g" keycloak/realm-export.json
fi

  echo -------------------------------------------------------------
  echo -----------------we build the Database-----------------------
  echo -------------------------------------------------------------
sed -i "s|<keycloak-pw>|$KEYCLOAK_PW|g" docker-entrypoint-initdb.d/init-userdb.sql


export MAILER_DSN=smtp://$smtpUsername:$smtpPassword@$smtpHost:$smtpPort
export laF_baseUrl=$HTTP_METHOD://$PUBLIC_URL
export VICH_BASE=$HTTP_METHOD://$PUBLIC_URL
export MERCURE_JWT_SECRET=$MERCURE_JWT_SECRET
export PUBLIC_URL=$PUBLIC_URL
export OAUTH_KEYCLOAK_CLIENT_SECRET=$NEW_UUID
export HTTP_METHOD=https
export KEYCLOAK_PW=$KEYCLOAK_PW
export KEYCLOAK_ADMIN_PW=$KEYCLOAK_ADMIN_PW
export registerEmailAdress=$smtpFrom
RANDOMTAG=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1);
export RANDOMTAG


if [ "$USELETSENCRYPT" == 'yes' ]; then
  docker-compose -f docker-compose_letsencrypt.yml build
  docker-compose -f docker-compose_letsencrypt.yml up -d
else
  docker-compose -f docker-compose.yml build
  docker-compose -f docker-compose.yml up -d
fi
RED='\033[0;31m'
NC='\033[0m' # No Color
printf "Browse to ${RED}%s://%s${NC} and visit your own ldap-bridge\n" $HTTP_METHOD $PUBLIC_URL
printf "To change any LDAP setting browse to${RED} %s://%s${NC} and there the username is:admin and the password %s\n" $HTTP_METHOD $PUBLIC_URL $KEYCLOAK_ADMIN_PW
printf "Any settings and password can be found in the ${RED}docker.conf${NC} file\n"
printf "To find your loadbalancer go to ${RED}%s://traefik.%s${NC} and enter the user:test and the password:test\n" $HTTP_METHOD $PUBLIC_URL

