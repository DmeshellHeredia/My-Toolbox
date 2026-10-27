# My Toolbox

**My Toolbox** es una aplicación Android desarrollada con **Flutter y Dart** como proyecto académico del **Instituto Tecnológico de las Américas (ITLA)**. Reúne siete herramientas en una interfaz sencilla, adaptable y construida con Material Design 3.

## Funcionalidades

| Herramienta | Descripción | Servicio utilizado |
| --- | --- | --- |
| **Predicción de género** | Consulta una predicción estadística a partir de un nombre, con resultados diferenciados por color y un estado cuando no hay datos suficientes. | [Genderize](https://genderize.io/) |
| **Persona aleatoria** | Genera un perfil con nombre, apellido, fotografía, fecha de nacimiento y edad. | [Random User](https://randomuser.me/) |
| **Universidades** | Busca instituciones por país escrito en inglés y muestra sus dominios y enlaces web. | [Adamix](https://adamix.net/proxy.php?country=Dominican+Republic) |
| **Clima RD** | Muestra el clima actual de Santo Domingo, sensación térmica, humedad, viento y pronóstico del día. | [Open-Meteo](https://open-meteo.com/) |
| **Pokémon** | Permite buscar Pokémon y consultar su imagen, experiencia base, habilidades y sonido. | [PokéAPI](https://pokeapi.co/) |
| **Noticias WordPress** | Presenta tres publicaciones de WP Tavern con título, resumen y enlace al artículo original. | [WP Tavern](https://wptavern.com/) / WordPress REST API |
| **Acerca de** | Presenta el perfil académico y profesional del autor, sus tecnologías y enlaces de contacto. | Recursos de la aplicación |

La pantalla principal incluye una fotografía de una caja de herramientas. El icono de Android incorpora una fotografía del autor.

## Tecnologías

- **Flutter y Dart** para la aplicación Android.
- **Material Design 3** para la interfaz.
- **HTTP y JSON** para las consultas a servicios externos.
- **XML/RSS** como alternativa de recuperación de noticias.
- **audioplayers** para la reproducción de sonidos Pokémon.
- **url_launcher** para abrir enlaces externos y acciones de contacto.
- **flutter_test** para pruebas automatizadas.

## Requisitos

- Flutter SDK instalado y configurado.
- Un dispositivo Android o un emulador compatible.
- Conexión a Internet para las funciones que consultan API externas.

Consulta las versiones y dependencias concretas en [`pubspec.yaml`](pubspec.yaml).

## Instalación y ejecución

1. Clona el repositorio:

   ```bash
   git clone https://github.com/DmeshellHeredia/My-Toolbox.git
   cd My-Toolbox
   ```

2. Instala las dependencias:

   ```bash
   flutter pub get
   ```

3. Comprueba los dispositivos disponibles y ejecuta la aplicación:

   ```bash
   flutter devices
   flutter run
   ```

   Si utilizas el emulador empleado durante el desarrollo, puedes ejecutar:

   ```bash
   flutter run -d emulator-5554 --no-dds
   ```

> **Nota:** la URL de clonación será válida cuando se cree y publique el repositorio `DmeshellHeredia/My-Toolbox` en GitHub.

## Verificación y pruebas

```bash
flutter analyze
flutter test
```

Durante el desarrollo, el proyecto alcanzó **17 pruebas automatizadas aprobadas** y el analizador de Flutter no reportó problemas. Estos resultados corresponden al entorno de desarrollo comprobado, no a una garantía de disponibilidad permanente de las API externas.

## Generar el APK

Para producir un APK de distribución:

```bash
flutter build apk --release
```

El archivo generado normalmente se encuentra en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Para generar APK separados por arquitectura, como alternativa:

```bash
flutter build apk --release --split-per-abi
```

## Estructura general del proyecto

```text
my_toolbox/
├── android/             # Configuración y recursos Android
├── assets/
│   ├── icon/            # Icono personalizado
│   ├── images/          # Fotografía de la portada
│   ├── pokemon/         # Recursos locales de Pokémon
│   └── profile/         # Fotografía de perfil
├── lib/
│   ├── models/          # Modelos de datos
│   ├── screens/         # Pantallas de la aplicación
│   ├── services/        # Consultas y lógica de servicios
│   ├── widgets/         # Componentes reutilizables
│   └── main.dart        # Entrada y navegación
├── test/                # Pruebas automatizadas
└── pubspec.yaml         # Dependencias y recursos
```

## Manejo de errores y conectividad

La aplicación contempla estados de carga, mensajes de error y acciones de reintento en varias consultas. Para Pokémon se implementaron reintentos, fuentes alternativas para imágenes y sonidos, y recursos locales para los ejemplos principales. El funcionamiento de las consultas remotas depende de la conectividad y la disponibilidad de cada proveedor.

## Autor

**Michael Dmeshell Sanchez Heredia**  
**Matrícula:** 20240063  
**Institución:** Instituto Tecnológico de las Américas (ITLA)  
**Programa:** Desarrollo de Software  
**GitHub:** [@DmeshellHeredia](https://github.com/DmeshellHeredia)

## Avisos y atribuciones

- Las predicciones de Genderize son estadísticas y **no determinan la identidad de género** de una persona.
- Los perfiles de Random User son datos generados para demostración.
- La información meteorológica procede de Open-Meteo.
- Los nombres, imágenes y sonidos Pokémon pertenecen a sus respectivos titulares; los recursos se utilizan aquí con fines académicos.
- Los titulares y resúmenes de WP Tavern se atribuyen a su sitio original y se enlazan a su fuente.
- La fotografía de perfil corresponde al autor del proyecto.

Este repositorio se publica para documentar un proyecto académico. **No se declara una licencia de reutilización del código ni de los recursos gráficos mediante este README.**
