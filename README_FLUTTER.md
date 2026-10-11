# App Flutter · Mundiales

Consume una API FastAPI conectada a MySQL y muestra KPIs animados, gráfica de barras,
dona de títulos y la lista de las finales con filtro por campeón.

## Backend Python + MySQL

El backend está en `backend/` y utiliza las tablas `selecciones` y `mundiales`
del esquema compartido. Flutter no se conecta directamente a MySQL: sus credenciales
se configuran únicamente en el backend.

### Conceptos que usa el backend

- **FastAPI** expone endpoints HTTP: Flutter llama a la API y recibe JSON.
- **MySQL Connector/Python** es el controlador entre Python y el servidor MySQL.
- **Entorno virtual (`venv`)** separa las librerías de este proyecto de las de otros.
- **`requirements.txt`** enumera las dependencias Python y fija versiones para que
  el equipo instale el mismo conjunto.
- **`.env`** guarda configuración local fuera del código. No se debe subir ni compartir.
- **Pool de conexiones** reutiliza conexiones a MySQL en lugar de abrir una por consulta.
- **Repository** mantiene las consultas SQL en `MundialesRepository`, separadas de las
  rutas HTTP.
- **Inyección de dependencias** (`Depends`) entrega el repositorio a cada endpoint y
  permite sustituirlo al probar la API.
- **Schemas Pydantic** validan y documentan el JSON que devuelve la API.

### Paso a paso en Windows

1. Verifica que MySQL esté encendido y que ya ejecutaste el SQL que crea
   `mundiales_db`, `selecciones`, `mundiales` y los datos.
2. En MySQL Workbench, usa `root` para administrar la base de datos; **no configures
   `root` en la API**. Crea o ajusta una cuenta exclusiva para la aplicación con solo
   permiso de lectura. Ejecuta una vez:

   ```sql
   CREATE USER IF NOT EXISTS 'mundiales_user'@'localhost'
     IDENTIFIED BY 'PON_AQUI_UNA_CLAVE_UNICA';
   ALTER USER 'mundiales_user'@'localhost'
     IDENTIFIED BY 'PON_AQUI_UNA_CLAVE_UNICA';
   REVOKE ALL PRIVILEGES, GRANT OPTION
     FROM 'mundiales_user'@'localhost';
   GRANT SELECT ON mundiales_db.* TO 'mundiales_user'@'localhost';
   ```

   Usa la misma clave nueva en ambas líneas y en `.env`. No reutilices la contraseña
   de `root`.
3. Abre PowerShell en `mundiales_app\backend` y crea el entorno virtual:

   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

   Si PowerShell bloquea la activación, puedes instalar y ejecutar con
   `.\.venv\Scripts\python.exe` sin activar el entorno.
4. Instala las dependencias y crea la configuración local:

   ```powershell
   python -m pip install -r requirements.txt
   Copy-Item .env.example .env
   ```

5. Abre `backend/.env` y escribe la conexión local de MySQL. Pon una clave única para
   `mundiales_user`; no uses la clave de `root` ni la publiques:

   ```env
   MYSQL_HOST=127.0.0.1
   MYSQL_PORT=3306
   MYSQL_DATABASE=mundiales_db
   MYSQL_USER=mundiales_user
   MYSQL_PASSWORD=LA_MISMA_CLAVE_UNICA
   ```

   El archivo `.env` está ignorado por Git. No lo envíes por chat ni lo agregues al
   repositorio.
6. Ejecuta las pruebas del repositorio y levanta la API desde `backend`:

   ```powershell
   python -m unittest discover -s tests -v
   uvicorn app.main:app --reload
   ```

   La documentación interactiva estará en `http://127.0.0.1:8000/docs`. Puedes probar
   allí `GET /mundiales/` y `GET /graficas/titulos-por-seleccion/datos`.
7. En otra terminal, desde `mundiales_app`, inicia Flutter:

   ```powershell
   flutter run -d chrome
   ```

   La app ya usa `http://127.0.0.1:8000` por defecto. En un emulador Android usa
   `http://10.0.2.2:8000`.

## 1. Crear el proyecto Flutter (una sola vez)

```
flutter create mundiales_app
cd mundiales_app
```

## 2. Copiar estos archivos encima

- Reemplaza la carpeta `lib/` por la de este zip.
- Reemplaza `pubspec.yaml` por el de este zip.
- Reemplaza `test/widget_test.dart` por el de este zip.

## 3. Instalar dependencias

```
flutter pub get
```

## Correr la app Flutter

```
flutter run -d chrome      # navegador
flutter run -d windows     # escritorio (requiere Visual Studio con "Desarrollo para escritorio con C++")
```

La API debe estar encendida antes de iniciar Flutter. En desarrollo local, Flutter
usa `http://127.0.0.1:8000` (Android emulador: `http://10.0.2.2:8000`).

## Si la API o MySQL están en otro PC

En el PC de la API:
```
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Configura `MYSQL_HOST` en el `.env` del backend con la dirección del servidor MySQL.
MySQL debe permitir conexiones desde el PC del backend y el firewall debe permitir
el puerto 3306. Si la API corre en otra máquina, crea un usuario MySQL restringido a la
IP del PC del backend y dale permiso `SELECT` sobre `mundiales_db`. No expongas MySQL
directamente a Internet ni uses `%` como host sin una necesidad justificada.

En el PC de Flutter, usa la IP real del PC donde corre la API:
```
flutter run -d chrome --dart-define=API_URL=http://192.168.1.50:8000
```
Ambos PCs deben estar en la misma red y el firewall debe permitir el puerto 8000.
