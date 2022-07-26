FROM jboss/keycloak

COPY ./keycloak/theme/ /opt/jboss/keycloak/themes/ldapbridge/
COPY ./keycloak/logo/logo.png /opt/jboss/keycloak/themes/ldapbridge/account/img/logo.png
COPY ./keycloak/logo/account.css /opt/jboss/keycloak/themes/ldapbridge/account/resources/account.css
COPY ./keycloak/logo/login.css /opt/jboss/keycloak/themes/ldapbridge/login/resources/login.css