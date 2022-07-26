CREATE USER 'keycloak'@'%' IDENTIFIED BY '<keycloak-pw>';
CREATE DATABASE keycloak;
GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'%';
FLUSH PRIVILEGES;