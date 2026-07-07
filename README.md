# Role mikroways.workstation

Este role instala las herramientas que usamos a diario en Mikroways. Es una
forma de mantener el workstation de nuestros talentos con las versiones de
aquellas herramientas usadas, como así simplificar la generación de bastiones
que nos entregan nuestros clientes y nos permiten trabajar cómodamente.

## Qué incluye el role

En resumen, este role realiza las siguientes tareas:

* Configura un proxy en caso de tener que instalar un equipo en una red
  restringida al acceso a internet por medio de un proxy. Para ello, nos basamos
  en el role [ruzickap.proxy_settings](https://galaxy.ansible.com/ui/standalone/roles/ruzickap/proxy_settings/).
* Instala un conjunto de paquetes del sistema necesarios para poder luego
  instalar otras utilidades comunes.
* Instala docker y compose, como así también podman. Los dos primeros usando
  otro role de la comunidad, [geerlingguy.docker](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/docker/).
* Se instala [asdf](https://asdf-vm.com/) que es pieza fundamental de nuestras
  herramientas. A partir de él, varias utilidades más.
* Aquellas herramientas que no estén contempladas por asdf, se instalan con
  este role, dentro del home del usuario y no globalmente en el sistema. Estas
  herramientas no quedarán en el `PATH` si no se utilizan los [dotfiles de
  Mikroways](https://github.com/Mikroways/dotfiles). El mismo role los instala,
  simplemente lo mencionamos por si se configura no hacerlo.
* Instala en el usuario que corre el role los [dotfiles de
  Mikroways](https://github.com/Mikroways/dotfiles).
* Además, se instalan plugins de helm y krew que más usamos en Mikroways.

De esta forma, corriendo este role, disponemos de un desktop listo para empezar
a trabajar.

## Requerimientos

Dependemos de los roles especificados en [`meta/requirements.yml`](meta/requirements.yml).
Por ello, cuando se instale este role, se instalarán los roles que son
dependencias de forma automática.

**Es muy importante leer su documentación**, porque si bien este role, maneja
algunos valores de estos roles, otros valores más específicos pueden setearse
con otras variables.

## Uso

Simplemente agregás en `requirements.yml` las siguientes lineas:

```yaml
- name: mikroways.workstation
  version: 2.4.0
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
| `workstation_docker_install_compose_plugin` | `true`               | Instalar docker compose como plugin             |
| `workstation_docker_compose_version` | `2.16.0`              | Versión de compose a instalar        |
| `workstation_docker_users`           | `{{ ansible_user }}` | Usuarios para interactuar con docker |

### Locales

Qué locales instalar en la máquina

| Nombre                               | Default                           | Descripción |
| ------------------------------------ | --------------------------------- | ----------- |
| `workstation_locales`         | `[ es_ES.UTF-8, es_AR.UTF8, en_US.UTF8]` | Locales     |

### GitHub

La instalación inicial clona muchos plugins de asdf y descarga binarios desde GitHub, lo que puede
provocar errores HTTP 403 por rate limiting (60 requests/hora sin autenticación).

Para evitarlo, configurar un token de GitHub sin scopes (alcanza con acceso público):

| Nombre | Default | Descripción |
| ------ | ------- | ----------- |
| `workstation_github_api_token` | valor de `$GITHUB_API_TOKEN` | Token de GitHub para evitar rate limiting |

La forma más práctica es usando el `.envrc.private` (ver `.envrc.private.sample`):

```bash
cp .envrc.private.sample .envrc.private
# editar .envrc.private y completar GITHUB_API_TOKEN
direnv allow
```

El token puede ser **Classic** o **Fine-grained**. Para este uso no se necesita
ningún scope ni permiso — solo autenticación.

> **Nota**: La organización Mikroways bloquea fine-grained tokens con lifetime
> mayor a 366 días. Si usás fine-grained, configurá máximo 365 días de expiración.

* **Classic**: [github.com/settings/tokens/new](https://github.com/settings/tokens/new)
  * _Note_: `mw-asdf-rate-limit`
  * _Expiration_: No expiration
  * Sin seleccionar ningún scope

* **Fine-grained**: [github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new)
  * _Token name_: `mw-asdf-rate-limit`
  * _Description_: `Token para evitar rate limiting de GitHub al instalar plugins de asdf`
  * _Expiration_: 365 days
  * _Repository access_: Public repositories
  * Sin permisos adicionales

### Proxy

Estas variables son un wrapper de aquellas usadas por el [role del que
dependemos](https://github.com/ruzickap/ansible-role-proxy_settings/)

| Nombre                           | Default | Descripción               |
| ----------------------------     | ------- | ------------------------- |
| `workstation_proxy_enabled`      | `false` | Habilitar el uso de proxy |
| `workstation_proxy_http`         | `null` | Datos del proxy http      |
| `workstation_proxy_https`        | `null` | Datos del proxy https     |
| `workstation_proxy_no_proxy`     | `null` | Direcciones de no proxy   |
| `workstation_proxy_ftp`          | `null` | Datos del proxy ftp       |
| `workstation_proxy_yum`          | `null` | Habilitar yum proxy       |
| `workstation_proxy_yum_username` | `null` | Yum proxy username        |
| `workstation_proxy_yum_password` | `null` | Yum proxy password        |

### Dotfiles

Mikroways tiene sus propios [dotfiles](https://github.com/Mikroways/dotfiles).
Su instalación es fundamental para tener una experiencia diferencial usando este
role. Toda configuración se rige por las siguientes variables:

| Nombre                           | Default | Descripción               |
| ----------------------------     | ------- | ------------------------- |
| `workstation_dotfiles_enabled`   | `true`  | Habilitar el uso de los dotfiles |
| `workstation_antigen_directory`  | `{{ ansible_env.HOME }}/.antigen.zsh` | Indica donde se instala [antigen](https://antigen.sharats.me/), un requerimiento para nuestros dotfiles |
| `workstation_antigen_url`        | `https://git.io/antigen` | La url desde donde descargar antigen |
| `workstation_dotfiles_directory` | `{{ ansible_env.HOME }}/.mikroways/dotfiles` | Directorio donde instalar los dotfiles |
| `workstation_dotfiles_repository`| `https://github.com/Mikroways/dotfiles.git` | Repositorio de nuestros dotfiles |
| `workstation_dotfiles_version`   | `master` | Rama principal |
| `workstation_dotfiles_install_script` | `{{ workstation_dotfiles_directory }}/script/install` | Script de instalación de los dotfiles |
| `workstation_dotfiles_fonts_directory` | `{{ ansible_env.HOME }}/.local/share/fonts` | En consolas gráficas se usan fuentes que deben existir en el sistema. Para estos casos, se indica el directorio local de fuentes |
| `workstation_dotfiles_fonts` | `[]` | Lista de url de las fuentes necesarias en un desktop gráfico |

### Herramientas

Las herramientas se instalan con diferentes productos:

* asdf
* Descarga de binarios en el HOME del usuario que corre el playbook.

#### Herramientas instaladas con asdf

Todo lo referente a asdf se configura con las siguientes variables:

| Nombre                           | Default | Descripción               |
| ----------------------------     | ------- | ------------------------- |
| `workstation_asdf_download_url`      | `https://github.com/asdf-vm/asdf/releases/download/...` | URL de descarga de GH releases |
| `workstation_asdf_dest` | `{{ ansible_env.HOME }}/.asdf` | Directorio donde se instalará asdf |
| `workstation_asdf_version` | `v0.16.7` | Version de asd |
| `workstation_asdf_tools` | `{ plugin_name_1: [latest], plugin_name2: [] }`| Listado de versiones de diferentes herramientas a instalar. _A continuación explicamos el formato_ |
| `workstation_asdf_external_sources_plugins` | `{plugin_1: url, plugin2: url}` | Listado de urls desde donde instalar plugins. _A continuación explicaremos el formato_  |

##### Formato de `workstation_asdf_tools`

Es un diccionario donde se mantiene como clave, el nombre del plugin y como
valor un listado de versiones a instalar. Si el listado de versiones es vacío,
**no se instala ninguna versión**. Si se setea una o más versiones, la última de
la lista **será la configurada como versión por defecto**.

> Puede usar **latest** para instalar la última versión de un utilitario.

Para ver un ejemplo, puede verse [`default/main/asdf.yml`](defaults/main/asdf.yml).

#### Herramientas instaladas con el rol y sin asdf

| Nombre                                | Default                                 | Descripción                            |
| ------------------------------------- | --------------------------------------- | -------------------------------------- |
| `workstation_tools_install_directory` | `{{ ansible_env.HOME }}/.mikroways/bin` | Directorio donde descargar utilitarios |
| `workstation_tools_only`              | `[]`                                    | Qué utilitarios instalar de todos      |
| `workstation_tools`                   | arreglo de utilitarios (ver abajo)      |                                        |

La variable `workstation_tools` se compone como un arreglo de arreglos separado
en diferentes archivos que nos simplifica la gestión de las herramientas según:

* `workstation_kubernetes_tools`: herramientas para interactuar con kubernetes
  no soportadas por asdf.
* `workstation_other_tools`: otras herramientas que no se contemplan por asdf.

#### Helm plugins

Lista de plugins de helm:

| Nombre                     | Default | Descripción                  |
| -------------------------- | ------- | ---------------------------- |
| `workstation_helm_plugins` | `[...]` | Plugins usados por Mikroways |

> Se instalan sólo si helm fue seleccionado como tool

#### Krew plugins

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

## Desarrollo

El repositorio usa [**uv**](https://docs.astral.sh/uv/) para gestionar el
entorno de desarrollo y testing: `pyproject.toml` declara las dependencias
(molecule, ansible-lint, etc.) y `uv.lock` fija las versiones exactas. No hace
falta instalar python ni crear un venv a mano — uv resuelve todo, aislado del
sistema.

> Si ya tenés un desktop de Mikroways instalado por este role, uv ya está
> disponible via asdf (`asdf install`).

### Correr los tests

Los tests usan [molecule](https://ansible.readthedocs.io/projects/molecule/)
con el driver de docker (requiere docker corriendo):

```bash
uv run molecule test
```

> **Ojo con los tiempos:** `molecule test` hace la instalación completa del
> workstation en 4 plataformas (más la corrida de idempotencia, que repite
> todo), descargando docker, kubectl, helm, etc. en cada una. En CI tarda
> ~10 minutos; en una conexión hogareña puede superar los 40. Es el comando
> para CI o validación final, no para el día a día.

Para iterar durante el desarrollo el loop recomendado es `converge`, que
aplica el role de forma incremental sin destruir ni recrear los contenedores
en cada corrida:

```bash
uv run molecule converge   # aplica el role sobre los contenedores
uv run molecule verify     # corre las verificaciones
uv run molecule destroy    # limpia al terminar
```

Otras herramientas del entorno se corren igual:

```bash
uv run ansible-lint .
```

### Matriz de versiones de ansible

Dado que las versiones de python soportadas por
[ansible dependen de ansible-core](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-community-changelogs),
se prueba contra dos versiones de ansible definidas como dependency-groups en
`pyproject.toml`:

* `ansible11`: la versión en uso por Mikroways (grupo por defecto).
* `ansible14`: la última versión estable, para anticipar incompatibilidades.

Por defecto los comandos usan `ansible11`. Para probar contra otra versión:

```bash
uv run --no-default-groups --group ansible14 molecule test
```

CI corre la matriz completa (ambos grupos) en cada pull request.

## TODO

* [ ] Analizar si funcionan los tags mencionados
