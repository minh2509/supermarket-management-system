# Supermarket Management System

He thong quan ly sieu thi gom 2 phan:
- **Backend**: Spring Boot + Spring Data JPA + SQL Server
- **Frontend**: Flutter (Web/Android/iOS/Desktop)

## 1) Cau truc thu muc tong quan

```text
supermarket/
|- .github/                                  # CI/CD, workflow
|- docs/                                     # Tai lieu + sequence/diagram
|- supermarket/
|  \- supermarket/                           # Backend Spring Boot
|     |- .mvn/
|     |- src/
|     |- mvnw
|     |- mvnw.cmd
|     |- pom.xml
|     |- seed-data-sqlserver.sql
|     \- seed-data-sqlserver.txt
|- supermarket_Manager_System/               # Frontend Flutter
|  |- android/
|  |- ios/
|  |- linux/
|  |- macos/
|  |- web/
|  |- windows/
|  |- lib/
|  |- test/
|  \- pubspec.yaml
\- README.md
```

## 2) Cau truc chi tiet Backend

Path goc backend:
`supermarket/supermarket`

```text
supermarket/supermarket/
|- src/main/java/com/supermarket/supermarket/
|  |- config/                                # Security, CORS, app config
|  |- controller/                            # REST API controllers
|  |- dto/                                   # DTO request/response
|  |- entity/                                # JPA entities
|  |- exception/                             # Exception + handler
|  |- repository/                            # Spring Data repositories
|  |- service/                               # Business logic
|  |- BCryptGenerator.java
|  \- SupermarketApplication.java            # Spring Boot entry point
|- src/main/resources/
|  |- application.properties
|  |- static/
|  \- templates/
|- pom.xml
|- seed-data-sqlserver.sql
\- seed-data-sqlserver.txt
```

## 3) Cau truc chi tiet Frontend

Path goc frontend:
`supermarket_Manager_System`

```text
supermarket_Manager_System/
|- lib/
|  |- core/                                  # Core utilities (neu co)
|  |- data/
|  |  |- local/                              # Local storage
|  |  \- services/                           # Goi API backend
|  |- domain/
|  |  \- models/                             # Models
|  |- presentation/
|  |  |- pages/                              # Screens/pages
|  |  \- widgets/                            # Shared widgets
|  |- utils/
|  |  |- api_constants.dart
|  |  |- api_constants_io.dart
|  |  \- api_constants_stub.dart
|  \- main.dart                              # Flutter entry point
|- android/
|- ios/
|- web/
|- windows/
|- macos/
|- linux/
|- test/
\- pubspec.yaml
```

## 4) Yeu cau moi truong

- Java 21
- Maven 3.9+
- Flutter SDK (Dart SDK `^3.10.4`)
- SQL Server 2019/2022 (hoac SQL Server Express)
- `sqlcmd` (SQL Server command-line tools) de seed du lieu

Kiem tra nhanh:

```bash
java -version
mvn -v
flutter --version
sqlcmd -?
```

## 5) Cau hinh Backend (SQL Server + Spring Boot)

File cau hinh:
`supermarket/supermarket/src/main/resources/application.properties`

Thong tin mac dinh hien tai:
- `spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=supermarket;encrypt=true;trustServerCertificate=true`
- `spring.datasource.username=sa`
- `spring.datasource.password=YourStrong@Passw0rd`
- `spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver`
- `spring.jpa.hibernate.ddl-auto=update`
- `spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect`

Dependency trong `pom.xml` (thay cho MySQL connector):

```xml
<dependency>
    <groupId>com.microsoft.sqlserver</groupId>
    <artifactId>mssql-jdbc</artifactId>
    <scope>runtime</scope>
</dependency>
```

Luu y bao mat:
- Khuyen nghi dua tai khoan mat khau DB va mail vao bien moi truong.
- Khong hard-code thong tin nhay cam khi deploy.
- Mat khau `sa` cua SQL Server bat buoc phai du manh (chu hoa, chu thuong, so, ky tu dac biet).

### Khoi dong SQL Server bang Docker (tuy chon)

```bash
docker run --name supermarket-sqlserver -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest
```

Tao database `supermarket` (SQL Server khong tu tao database qua JDBC URL):

```bash
sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -Q "IF DB_ID('supermarket') IS NULL CREATE DATABASE supermarket;"
```

### Seed du lieu mau

```bash
cd supermarket/supermarket
sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -d supermarket -i seed-data-sqlserver.sql
```

> Luu y: file seed cu viet cho MySQL can chuyen doi cu phap sang T-SQL (vi du `AUTO_INCREMENT` -> `IDENTITY(1,1)`, backtick `` ` `` -> ngoac vuong `[]`, `LIMIT` -> `TOP`, kieu `TINYINT(1)` -> `BIT`...).

## 6) Huong dan chay Backend

Tu thu muc goc repo:

```bash
cd supermarket/supermarket
mvn clean install
mvn spring-boot:run
```

Backend mac dinh chay port `8080` (neu chua set `server.port`).

API base URL:
`http://localhost:8080`

## 7) Huong dan chay Frontend

Tu thu muc goc repo:

```bash
cd supermarket_Manager_System
flutter pub get
flutter run
```

Chay Web voi port cu the:

```bash
flutter run -d chrome --web-port 50707
```

## 8) Cau hinh Frontend goi API

Frontend dung:
`supermarket_Manager_System/lib/utils/api_constants.dart`

Da ho tro chon host theo platform va override bang `--dart-define`.

Vi du:

```bash
# Android emulator
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Thiet bi that (cung mang LAN voi backend)
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

> Thay `192.168.1.50` bang IP LAN cua may chay backend.

## 9) Doi port nhanh

### Doi port backend

Sua `application.properties`:

```properties
server.port=9090
```

### Doi port SQL Server

Sua `spring.datasource.url`:

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1434;databaseName=supermarket;encrypt=true;trustServerCertificate=true
```

Neu chay Docker, nho map port tuong ung, vi du `-p 1434:1433`.

### Doi URL frontend toi backend moi

Chay app voi `--dart-define=API_BASE_URL=http://localhost:9090`
hoac cap nhat logic trong cac file `api_constants_*.dart`.

## 10) Lenh kiem tra nhanh

Backend:

```bash
cd supermarket/supermarket
mvn -DskipTests compile
```

Frontend:

```bash
cd supermarket_Manager_System
flutter analyze
flutter test
```

## 11) Ghi chu cho mobile local storage

Frontend dang su dung `sqflite` de luu session local (`supermarket_mobile.db`).

- Dang nhap thanh cong -> luu session
- Mo lai app -> restore session
- Dang xuat -> xoa session

Backend van su dung SQL Server; SQLite chi dung cho local state tren app.
