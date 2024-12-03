# Sistema de Gestión de Consorcios

## Desarrollado por

### Facundo Alejandro Flores

### Curso

Seminario Final de Ingeniería en Software

### Universidad

Siglo 21

### Fecha

Junio 2024

## Descripción

Este proyecto consiste en un **Sistema de Gestión de Consorcios** desarrollado como parte del Seminario Final para la carrera de Ingeniería en Software en la Universidad Siglo 21. El sistema está diseñado para facilitar la administración de consorcios, permitiendo una gestión eficiente de las operaciones y procesos asociados.

## Funcionalidades

El sistema incluye las siguientes funcionalidades principales:

- **Gestión de Propietarios e Inquilinos**: Registro y seguimiento de los datos de contacto e información relevante.
- **Administración de Gastos y Pagos**: Control y seguimiento de los gastos comunes y pagos realizados por los propietarios e inquilinos.
- **Visualizacion de Balances e Historial de Transacciones**: Registro de balances por propiedad accesibles para consorcistas y administradores
- **Generación de Reportes**: Creación de informes detallados sobre la gestión del consorcio.
- ** Y mucho mas!**

## Tecnologías Utilizadas

El desarrollo del sistema se realizó utilizando las siguientes tecnologías:

- **Lenguajes de Programación**: Golang, Dart
- **Frameworks y Librerías**: Flutter, Gin
- **Base de Datos**: PostgreSQL
- **Herramientas de Desarrollo**: VSCode, Docker

## Instalación

Para instalar y configurar el sistema de gestión de consorcios, siga los siguientes pasos:

1. **Clonar el repositorio**:

   ```bash
   git clone https://github.com/FacFlores/SeminarioFinal2024.git
   ```

2. **Descargar Docker**:

<https://www.docker.com/products/docker-desktop/>

3. **Buildear Docker Compose**:

Desde la carpeta raiz del repositorio:

   ```bash
   docker-compose build
   ```

4. **Inicializar el sistema mediante Docker Compose**:

   ```bash
     docker-compose up
   ```

## Uso

Una vez instalado y configurado, puede acceder al sistema a través de su navegador web en la dirección <http://localhost:3000/>. Use las credenciales proporcionadas para iniciar sesión y comenzar a gestionar el consorcio.

### Credenciales

El sistema posee una base de datos precargada con informacion basica para testing, dentro de las cuales estan las credenciales basicas de
un usuario administrador y otro consorcista

**Credenciales de Admin**
admin@example.com
adminpassword

**Credenciales de Consorcista**
user@example.com
userpassword

## Tests de Backend

Adicionalmente dentro de la carpeta raiz del repositorio se encuentra una coleccion de Postman la cual puede ser utilizara para probar los
endpoints del sistema

 **Descargar Postman**

 <https://www.postman.com/downloads/>

 Una vez descargado e instalado, se puede importar el archivo Seminario.postman_collection.json para su prueba


 # VIDEO TUTORIAL

En caso de que no queden claras las instrucciones escritas se ha realizado un video instructivo de como poner en marcha el sistema
https://drive.google.com/file/d/1u1SCYDp8AOR86XRsImS0t5OYw8f_pEsf/view?usp=sharing

## Contacto

Para cualquier consulta o sugerencia, puede contactar al desarrollador:

- **Correo Electrónico**: <facundoalejan@hotmail.com>
- **LinkedIn**: <https://www.linkedin.com/in/facundo-alejandro-flores/>



docker run --name db `
  -e POSTGRES_USER=postgres `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=SeminarioFF `
  -v pgdata:/var/lib/postgresql/data `
  -p 5432:5432 `
  -d postgres:latest






  https://docs.google.com/presentation/d/1ILuLKzxNKqVxF4DZ8JxYfv17PNfMldbcqUSd_Lz7JtI/edit#slide=id.g133f6155f6d_0_30