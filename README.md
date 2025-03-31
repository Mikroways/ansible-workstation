# Role mikroways.workstation

Este role instala las herramientas que usamos día a día en Mikroways. Es una
forma de mantener el workstation de nuestros talentos con las versiones de
aquellas herramientas usadas en el día a día.

En resumen, este role realiza las siguientes tareas:

* Configura el proxy en caso de tener que instalar un equipo en una red
  restringida al acceso a internet por medio de un proxy.
* Instala una serie de paquetes del sistema esenciales en nuestros desktops
* Instala docker y compose.
* Herramientas varias, que en general corren como un binario que se descarga en
  el home del usuario y no es una instalación de paquetes del sistema. Estas
  herramientas no quedarán en el PATH si no se utilizan los dotfiles de
  Mikroways, por lo que debe tenerse en cuenta este punto.
* Manejadores de lenguajes que flexibilizan el trabajo con diferentes versiones
  de distintos lenguajes: go, node, ruby, python.
* Instala en el usuario que corre el role (y que se asume e sudoer), los
  dotfiles de Mikroways.
* Además, se instalan los plugins de helm y krew más usados por nuestros
  ingenieros DevOps.

## Requerimientos

Dependemos de los roles especificados en [`meta/requirements.yml`](meta/requirements.yml).
Por ello, cuando se instale este role, se instalarán los roles que son
dependencias de forma automática.

**ES MUY IMPORTANTE LEERLOS**, porque simplifica mucho el trabajo. Considerar
que ya soporta un role que configura proxy, docker, etc.

## Uso

Simplemente agregás en `requirements.yml` las siguientes lineas:

```yaml
- name: mikroways.workstation
  version: 2.1.2
```

> ¡Verificar si no hay una nueva version!

## Variables

Las variables se han separado en archivos según la siguiente clasificación:

### Docker

Estas variables son un wrapper de aquellas usadas por el [role del que
dependemos](https://github.com/geerlingguy/ansible-role-docker):

| Nombre                               | Default              | Descripción                          |
| ------------------------------------ | -------------------- | ------------------------------------ |
| `workstation_docker_enabled`         | `true`               | Instalar el engine docker            |
| `workstation_docker_install_compose` | `true`               | Instalar docker compose              |
| `workstation_docker_compose_version` | `2.6.1`              | Versión de compose a instalar        |
| `workstation_docker_users`           | `{{ ansible_user }}` | Usuarios para interactuar con docker |

### Locales

Qué locales instalar en la máquina


| Nombre                               | Default                           | Descripción |
| ------------------------------------ | --------------------------------- | ----------- |
| `workstation_locales`         | `[ es_ES.UTF-8, es_AR.UTF8, en_US.UTF8]` | Locales     |

### Proxy


Estas variables son un wrapper de aquellas usadas por el [role del que
dependemos](https://github.com/ruzickap/ansible-role-proxy_settings/)

| Nombre                           | Default | Descripción               |
| ----------------------------     | ------- | ------------------------- |
| `workstation_proxy_enabled`      | `false` | Habilitar el uso de proxy |
| `workstation_proxy_http`         |         | Datos del proxy http      |
| `workstation_proxy_https`        |         | Datos del proxy https     |
| `workstation_proxy_no_proxy`     |         | Direcciones de no proxy   |
| `workstation_proxy_ftp`          |         | Datos del proxy ftp       |
| `workstation_proxy_yum`          |         | Habilitar yum proxy       |
| `workstation_proxy_yum_username` |         | Yum proxy username        |
| `workstation_proxy_yum_password` |         | Yum proxy password        |

### Tools

Las herramientas se instalan con diferentes productos:

* asdf
* Descarga de binarios en el HOME del usuario que corre el playbook.

Las tools que se instalarán con asdf son especificadas con el diccionario
`workstation_asdf_tools:`. Los valores del diccionario son el nombre del plugin
asdf y la versión del paquete a instalar por defecto y configurar como global
para el usuario.


| Nombre                                | Default                                 | Descripción                            |
| ------------------------------------- | --------------------------------------- | -------------------------------------- |
| `workstation_tools_install_directory` | `{{ ansible_env.HOME }}/.mikroways/bin` | Directorio donde descargar utilitarios |
| `workstation_tools_only`              | `[]`                                    | Qué utilitatios instalar de todos      |
| `workstation_tools`                   | arreglo de utilitarios (ver abajo)      |                                        |}

La variable `workstation_tools` se compone como un arreglo de arreglos separado
en diferentes archivos que nos simplifica la gestión de las herramientas según:

* `workstation_kubernetes_tools`: herramientas para interactuar con kubernetes
  no soportadas por asdf.
* `workstation_other_tools`: otras herramientas que no se contemplan por asdf.

### Helm plugins

Lista de plugins de helm:

| Nombre                     | Default | Descripción                  |
| -------------------------- | ------- | ---------------------------- |
| `workstation_helm_plugins` | `[...]` | Plugins usados por Mikroways |

> Se instalan sólo si helm fue seleccionado como tool

### Krew plugins

Lista de plugins de kubectl instalados con krew:

| Nombre                     | Default | Descripción                  |
| -------------------------- | ------------------------------- | ------------------------------- |
| `workstation_krew_path` | `{{ ansible_env.HOME }}/.krew/bin` | Directorio donde se instala kew |
| `workstation_krew_plugins` | `[...]`                         | Plugins usados por Mikroways    |

> Se instalan sólo si krew fue seleccionado como tool


## Tags ansible soportados

* system_packages
* docker
* tools
* dotfiles
* locales
* proxy
