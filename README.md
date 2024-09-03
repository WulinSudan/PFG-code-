
# Desenvolupament d’una Aplicació Mòbil per a Pagaments amb Codis QR

Aquest projecte és una aplicació mòbil de codi obert desenvolupada en Flutter, optimitzada per a Android Studio, que permet als usuaris realitzar pagaments entre ells mitjançant codis QR.

## CLIENT

### Requisits Prèvies

Abans de començar, assegura't de tenir instal·lats els següents components al teu entorn de desenvolupament:

- **Flutter SDK**: Verifica que tens la versió més recent instal·lada.
- **Dart SDK**: Normalment inclòs amb Flutter.
- **Android Studio**: Configurat correctament per al desenvolupament d'aplicacions Flutter.
- **Dispositiu o emulador Android**: Pots utilitzar un dispositiu físic o un emulador d'Android Studio.
- **Plugin de Flutter per a Android Studio**: Necessari per integrar Flutter amb Android Studio.

### Instruccions d'Execució

1. Accedeix al directori /client.
2. Activa el dispositiu o emulador Android.
3. Executa el projecte des d'Android Studio o amb la comanda `flutter run`.

## SERVER

### Requisits Prèvies

Abans de començar a treballar amb el servidor, assegura't de tenir instal·lats i configurats els següents components:

- **Node.js**: Versió recomanada (indica la versió específica). Necessari per executar el servidor Apollo.
- **npm o yarn**: Gestor de paquets per instal·lar les dependències del projecte.
- **Visual Studio Code**: Editor de codi amb extensions recomanades per a GraphQL.
- **Extensions de Visual Studio Code**:
  - Apollo GraphQL: Proporciona eines per treballar amb GraphQL.
  - ESLint: Per mantenir la qualitat del codi.
  - Prettier: Per a la formatació automàtica del codi.

### Instruccions d'Execució

1. Accedeix al directori /server.
2. Executa `npm install` per instal·lar totes les dependències necessàries.
3. Executa `npm run start` per iniciar el servidor.

### Accés al Server

- Accedeix a [http://localhost:4000/](http://localhost:4000/) per utilitzar GraphQL Playground.

### Usuaris Disponibles a la Base de Dades

Per accedir a l'aplicació, utilitza els següents credencials de prova:

- **Usuari Client**
  - Nom: Eloi
  - Contrasenya: Eloi123
- **Usuari Administrador**
  - Nom: Admin
  - Contrasenya: Admin123
