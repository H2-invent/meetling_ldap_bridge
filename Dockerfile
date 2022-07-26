FROM jboss/keycloak

COPY ./keycloak/theme/ /opt/jboss/keycloak/themes/ldapbridge/
COPY ./keycloak/logo/customizing /opt/jboss/keycloak/themes/ldapbridge/

