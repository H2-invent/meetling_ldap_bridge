FROM jboss/keycloak

COPY ./keycloak/theme/ /opt/jboss/keycloak/themes/ldapbridge/
COPY keycloak/customizing /opt/jboss/keycloak/themes/ldapbridge/

