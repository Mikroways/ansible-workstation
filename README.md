# Role mw-workstation-packages

Este role instala las herramientas que usamos día a día en Mikroways. Es una
forma de mantener los workstation de nuestro personal al día, unificando las
versiones de las aplicaciones que usamos, como así la suite de herramientas que
debe tener cada talento de Mikroways en su caja de pandora.

Si bien este role instala paquetes del sistema, otros paquetes se instalan en un
directorio que debe exponerse en el `PATH` para que sea útil. Por tanto, el role
por sí solo no es suficiente. Quien complementa este role, es el role
`mikroways.mw_home_environment`.

## Requerimientos

Este role depende de dos roles para la instalación de docker y podman. Sin
embargo, el role ya instala dichos roles porque se han definido como
requerimientos de éste.

## Variables

Si bien el role ya define los defaults, podemos modificar algunas cuestiones de
personalización. Como este role no es únicamente para el desktop de nuestros
talentos, sino además para VMs que serán bastión, a veces no necesitamos todas
las herramientas requeridas para el día a día. Es por ello, que proveemos las
siguientes variables que pueden modificarse:

* **`mw_workstation_local_install_directory`:** directorio donde se instalarán
    las herramientas de Mikroways. No se espera un directorio del sistema, sino
    un directorio relativo al usuario que lo vaya a usar. Por default el valor
    es `"{{ ansible_env.HOME }}/.mikroways/bin`.
* **`mw_workstation_local_packages_only`:**  lista de qué local packages
  instalar únicamente. Como se menciona arriba, esta variable puede usarse para
  sólo instalar paquetes usados desde un bastión y no todas las herramientas. Por
  defecto el valor es `[]` indicando que se instale todo.
* **`mw_workstation_local_packages:`** lista de paquetes a descargar e
  indicaciones de cómo instalarlo. Puede verse el archivo `default/main.yml`
  para comprender el formato.


## Ejemplo

Crear un archivo de requerimientos de galaxy `requirements.yml` con el siguiente
contenido:

```yaml
# from GitLab or other git-based scm
- name: mikroways.mw_workstation_packages
  src: git@gitlab.com:mikroways/ansible/mw-workstation-packages.git
  scm: git
  version: "1.0.0" 
```

Luego, en un playbook es posible invocar el role usando:

```yaml
- name: Some useful playbook
  hosts: all
  gather_facts: true
  tasks:
    - import_role:
        name: mikroways.mw_workstation_packages
```

## Nota sobre Pop!_OS

Si se desea utilizar en una distribución basada en este sistema operativo,
entonces debe setearse `ansible_distribution` a Ubuntu:

```
ansible-playbook ... -e ansible_distribution=Ubuntu
```

