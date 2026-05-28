# Role mikroways.workstation

Este role instala las herramientas que usamos a dirario en Mikroways. Es una
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

# Variables

Las variables se han separado en archivos según la siguiente clasificación:

## Docker

Estas variables son un wrapper de aquellas usadas por el [role del que
dependemos](https://github.com/geerlingguy/ansible-role-docker):

| Nombre                               | Default              | Descripción                          |
| ------------------------------------ | -------------------- | ------------------------------------ |
| `workstation_docker_enabled`         | `true`               | Instalar el engine docker            |
| `workstation_docker_install_compose` | `true`               | Instalar docker compose              |
| `workstation_docker_install_compose_plugin` | `true`               | Instalar docker compose como plugin             |
| `workstation_docker_compose_version` | `2.16.0`              | Versión de compose a instalar        |
| `workstation_docker_users`           | `{{ ansible_user }}` | Usuarios para interactuar con docker |

## Locales

Qué locales instalar en la máquina


| Nombre                               | Default                           | Descripción |
| ------------------------------------ | --------------------------------- | ----------- |
| `workstation_locales`         | `[ es_ES.UTF-8, es_AR.UTF8, en_US.UTF8]` | Locales     |

## Proxy


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

## Dotfiles

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


## mw-skills

[mw-skills](https://gitlab.com/mikroways/tools/mw-skills) es el repositorio de
skills de Claude Code y gemini-cli de Mikroways. El rol lo clona y ejecuta su
`install.sh`, que hace sparse clones de los repos de skills via SSH y crea los
symlinks correspondientes.

| Nombre                                  | Default | Descripción |
| --------------------------------------- | ------- | ----------- |
| `workstation_mw_skills_enabled`         | `true`  | Habilitar la instalación de mw-skills |
| `workstation_mw_skills_repository`      | `https://gitlab.com/mikroways/tools/mw-skills.git` | Repositorio de mw-skills |
| `workstation_mw_skills_directory`       | `{{ ansible_env.HOME }}/.mikroways/tools/mw-skills` | Directorio donde clonar mw-skills |
| `workstation_mw_skills_run_install`     | `true`  | Ejecutar `install.sh` tras el clone. Requiere acceso SSH a GitLab. Desactivar en entornos sin SSH (ej: contenedores) |


## Herramientas

Las herramientas se instalan con diferentes productos:

* asdf
* Descarga de binarios en el HOME del usuario que corre el playbook.

### Herramientas instaladas con asdf

Todo lo referente a asdf se configura con las siguientes variables:

| Nombre                           | Default | Descripción               |
| ----------------------------     | ------- | ------------------------- |
| `workstation_asdf_download_url`      | `https://github.com/asdf-vm/asdf/releases/download/...` | URL de descarga de GH releases |
| `workstation_asdf_dest` | `{{ ansible_env.HOME }}/.asdf` | Directorio donde se instalrá asdf |
| `workstation_asdf_version` | `v0.16.7` | Version de asd |
| `workstation_asdf_tools` | `{ plugin_name_1: [latest], plugin_name2: [] }`| Listado de versiones de diferentes herramientas a instalar. _A continuación explicamos el formato_ |
| `workstation_asdf_external_sources_plugins` | `{plugin_1: url, plugin2: url} ` | Listado de urls desde donde instalar plugins. _A continuación explicaremos el formato_  |

#### Formato de `workstation_asdf_tools`

Es un diccionario donde se mantiene como clave, el nombre del plugin y como
valor un listado de versiones a instalar. Si el listado de versiones es vacío,
**no se instala ninguna versión**. Si se setea una o más versiones, la última de
la lista **será la configurada como versión por defecto**.

> Puede usar **latest** para instalar la última versión de un utilitario.

Para ver un ejemplo, puede verse [`default/main/asdf.yml`](defaults/main/asdf.yml).

### Herramientas instaladas con el rol y sin asdf



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


# Tags ansible soportados

* system_packages
* docker
* tools
* dotfiles
* locales
* proxy

# Desarrollo

Para trabajar en el desarrollo del presente role, se recomienda instalar python.
El propio repositorio mantiene variables de ambiente usando direnv dentro del
`.envrc` y propone usar [**tox**](https://tox.wiki/) como librería para el
desarrollo e intergración con CI/CD.

> Si ya tenés un desktop de Mikroways instalado por este role, entonces todo va
> a ser más simple.

## Instalando los requerimientos

Instalar las versiones de python con las que probar. Dado que las versiones de
python soportadas por [ansible dependen de ansible-core](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-community-changelogs),
se codifica contemplando las últimas versiones de ansible-core. Para ello, puede
observarse que se confecciona una matriz de pruebas en `tox.ini` justamente con
dos versiones de python y 2 de ansible. Para que esto funcione, explicaremos los
pasos a seguir usando asdf:

```bash
asdf install
asdf reshim python
pip3.10 install -r requirements.txt
pip3.11 install -r requirements.txt
```
## Uso de tox

Tox tiene una serie de comandos, pero lo más importante es comprender los
ambientes configurados en `tox.ini`. Los ambientes pueden verse con:

```
tox list
```

Al correr simplemente `tox` se ejecuta `tox run`. Pero nosotros podemos
manipular `tox run` con las opciones que se ven con `--help`. Lo más importante
a mencionar es:

```
tox r -e py310-ansible-10 -- -vvv converge
```

> Esto ejecuta únicamente el ambiente `py310-ansible-10` y al `command`
> configurado en `tox.ini` le pasa los argumentos luego de `--`, es decir, con
> la configuración actual, correrá `molecule -vvv converge`

Otro comando útil con tox, es ejecutar otro comando, por ejemplo ansible-lint.
¿Cómo es posible hacer eso?:

```
tox exec -e py310-ansible-10 -- ansible-lint .
```

# TODO

* [ ] Analizar si funcionan los tags mencionados
