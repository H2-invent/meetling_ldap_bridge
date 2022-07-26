# Die Meetling LDAP-Bridge
## Verbindet was zusammengehört

Verknüpft einen Meetling Mandant mit einem internen LDAP oder einem internen OpenId Connect Provider.

Hierfür wird ein interner Docker-Keycloak Container deployt mit einer Datenbank und einem Reverse-Proxy, welcher bereits als Client für die H2-Cloud SSO-Lösung konfigueritert ist.

## Installation

````
git clone https://github.com/H2-invent/meetling_ldap_bridge.git
bash installDocker.sh
````

Folge den Links in der Ausgabe nach der Installation. 
Die LDAP-Bridge muss mit dem Admin-Account weiter konfiguriert werden. 

Dabei sind folgende Schritte zu beachten
1. Secret im Client H2-Invent neu generieren
2. Clients -> RootUrl Consumer IDP Alias ersetzen
3. Clients -> Valid Redirect URIs Consumer IDP Alias ersetzen

Auf der Consumer Seite
1. Neue IDP anlegen
2. keycloak-oidc auswählen
3. Alias und Name angeben
4. Enable und Hide on Loginpage anklicken
5. Authorization Url : https://<domain.org>/auth/realms/meetling/protocol/openid-connect/auth
6. Token Url: https://<domain.org>/auth/realms/meetling/protocol/openid-connect/token
7. Client Authentication: Client Secret send as Basic
8. Client ID und Client Secret aus der Meetling LDAP Bridge kopierne und einfügen
9. IDP alias als parameter "idp_provider" im theme eintragen