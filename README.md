[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/ftaskaev_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-08/ftaskaev_infra)
# [Otus-DevOps-2019-08] Fedor Taskaev homeworks
Выполнение домашних заданий по курсу [DevOps практики и инструменты](https://otus.ru/lessons/devops-praktiki-i-instrumenty/) (август 2019 - март 2020).

## Lesson 3: homework 1
GitHub: получение доступа к [Otus-DevOps-2019-08](https://github.com/Otus-DevOps-2019-08).  
PR: [Otus-DevOps-2019-08/students#24](https://github.com/Otus-DevOps-2019-08/students/pull/24)

## Lesson 4: homework 2
ChatOps: интеграция GitHub, Travis CI и Slack.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#1](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/1)

## Lesson 5: homework 3
GCE: Bastion Host, Pritunl VPN.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#3](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/3)

bastion_IP = 35.210.119.1  
someinternalhost_IP = 10.132.0.4

<details>
  <summary>Основное задание</summary>

Для подключения к VM необходимо настроить `~/.ssh/config`:
```
Host bastion
 HostName 35.210.119.1
 User me
 IdentityFile ~/.ssh/gce-otus-infra

Host internal
 HostName internal.europe-west1-d.c.otus-devops-infra-253221.internal
 User me
 ForwardAgent yes
 ProxyCommand ssh me@bastion -W %h:%p
```
</details>

<details>
  <summary>Дополнительное задание</summary>

Сгенерировать валидный сертификат для домена 35-210-119-1.sslip.io:
```console
$ sudo yum install certbot
$ sudo certbot certonly --standalone \
>                       --register-unsafely-without-email \
>                       --preferred-challenges http \
>                       -d 35-210-119-1.sslip.io
```

Проверить установленный сертификат:
```console
$ curl -v https://35-210-119-1.sslip.io 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
* SSL connection using TLSv1.2 / ECDHE-ECDSA-AES128-GCM-SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=35-210-119-1.sslip.io
*  start date: Sep 17 23:57:32 2019 GMT
*  expire date: Dec 16 23:57:32 2019 GMT
*  subjectAltName: host "35-210-119-1.sslip.io" matched cert's "35-210-119-1.sslip.io"
*  issuer: C=US; O=Let's Encrypt; CN=Let's Encrypt Authority X3
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x7fdbf300b400)
* Connection state changed (MAX_CONCURRENT_STREAMS updated)!
* Connection #0 to host 35-210-119-1.sslip.io left intact
```
</details>

## Lesson 6: homework 4
GCE: автоматизация при помощи gcloud.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#4](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/4)

testapp_IP = 35.240.75.50  
testapp_port = 9292

<details>
  <summary>Дополнительное задание</summary>

Создать VM с Ubuntu 16.04 LTS и установить необходимое ПО с помощью [startup-script](https://gist.github.com/ftaskaev/20d92458978807c2ab7caa358ec29e43):
```console
$ gcloud compute instances create reddit-ap \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project==ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata startup-script-url=https://gist.githubusercontent.com/ftaskaev/20d92458978807c2ab7caa358ec29e43/raw/2b10ed67878a8db22cb5ce77333478272ca81d9b/puma-server-install.sh
```

Создать правило фильтрации для тэга puma-server:
```console
$ gcloud compute firewall-rules create default-puma-server \
    --description="Allow traffic to puma-server" \
    --allow=tcp:9292 \
    --target-tags=puma-server
```
</details>

## Lesson 7: homework 5
Packer: подготовка образовов для ускорения развёртывания VM.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#5](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/5)

<details>
  <summary>Основное задание</summary>

Собран образ `reddit-base-1569407504` на основе Ubuntu 16.04 LTS с предустановленными Ruby и MongoDB.
```console
$ gcloud compute images list --no-standard-images
NAME                    PROJECT                   FAMILY       DEPRECATED  STATUS
reddit-base-1569407504  ************************  reddit-base              READY
```
</details>

<details>
  <summary>Дополнительное задание</summary>

Создан образ `reddit-full-1569408139` на основе созданного ранее `reddit-base-1569407504` с предустановленными reddit server.  

```console
$ gcloud compute images list --no-standard-images
NAME                    PROJECT                   FAMILY       DEPRECATED  STATUS
reddit-base-1569407504  ************************  reddit-base              READY
reddit-full-1569408139  ************************  reddit-full              READY
```

Добавлен скрипт `create-redditvm.sh` для развёртывания VM из созданного образа.

```console
$ config-scripts/create-redditvm.sh
Created [https://www.googleapis.com/compute/v1/projects/************************/zones/europe-west1-d/instances/reddit-ap].
NAME       ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
reddit-ap  europe-west1-d  f1-micro                   10.132.0.46  34.76.12.56  RUNNING
```
```console
$ curl -I 34.76.12.56:9292
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Set-Cookie: rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTgzZjI4MTZmOGE4YmZhZTg5YTQy%0AMGU0MWRkNzBiNmQ2MmYwZDdmZDY2MjA0ZDBlOTU5YWM4YjEyYzA4NzI5ZDUG%0AOwBGSSIJY3NyZgY7AEZJIjE1MVAwNWdBRGc2UEUzVi8vcGpQUU0yVUFzQjlU%0AOTZoYWplUk5GVHpPczJJPQY7AEZJIg10cmFja2luZwY7AEZ7B0kiFEhUVFBf%0AVVNFUl9BR0VOVAY7AFRJIi01NmMxYTdkOWI2YjdjZjUyMTdkNTk1YjM4MjVm%0AZDc4MjI5MmIyNGNjBjsARkkiGUhUVFBfQUNDRVBUX0xBTkdVQUdFBjsAVEki%0ALWRhMzlhM2VlNWU2YjRiMGQzMjU1YmZlZjk1NjAxODkwYWZkODA3MDkGOwBG%0A--24740450230e9707b810bbaadb995e84a828a484; path=/; HttpOnly
Content-Length: 1861
```
</details>

## Lesson 8: homework 6
Terraform: автоматизация провижининга инфраструктуры.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#6](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/6)

<details>
  <summary>Основное задание</summary>

Добавим input переменные в `variables.tf`:
```
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "europe-west1-b"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
```

Используем переменные в `resource "google_compute_instance" "app"`:
```diff
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
- zone         = "europe-west1-b"
+ zone         = var.zone

  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "appuser"
    agent = false
    # путь до приватного ключа
-   private_key = file("~/.ssh/appuser")
+   private_key = file(var.private_key_path)
   }
}
```
</details>

<details>
  <summary>Дополнительное задание №1</summary>

- Добавление SSH-ключей к проекту.

Добавим input переменную для хранения логинов и публичных ключей в `variables.tf`:
```
variable "user_ssh_keys" {
  type = list(object({
    user = string
    key = string
  }))
}
```

Добавим пользователей с одинаковыми ключами в `terraform.tfvars`:
```
user_ssh_keys = [
  {
    user = "appuser"
    key = "~/.ssh/appuser.pub"
  },
  {
    user = "appuser1"
    key = "~/.ssh/appuser.pub"
  }
]
```

Добавим ресурс `google_compute_project_metadata_item` в `main.tf`, который будет добавлять пары `логин:ключ` в matadata проекта:
```
resource "google_compute_project_metadata_item" "ssh-keys" {
  key = "ssh-keys"
  value = join("\n", [for item in var.user_ssh_keys : "${item.user}:${file(item.key)}"])
}
```

Результат выполнения `terraform apply`:
```console
  # google_compute_project_metadata_item.ssh-keys will be created
  + resource "google_compute_project_metadata_item" "ssh-keys" {
      + id      = (known after apply)
      + key     = "ssh-keys"
      + project = (known after apply)
      + value   = "appuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser\n\nappuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser\n"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

- Создадим еще одного пользователя через web-интерфейс и повторно запустим `terraform apply`.
- При выполнении `terraform apply` пользовательские SSH-ключи, добавленные через web-интерфейс, удаляются.

```console
  # google_compute_project_metadata_item.ssh-keys will be updated in-place
  ~ resource "google_compute_project_metadata_item" "ssh-keys" {
        id      = "ssh-keys"
        key     = "ssh-keys"
        project = "************************"
      ~ value   = <<~EOT
            appuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser
            appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser
          - appuser_web:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser_web
        EOT
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```
</details>

<details>
  <summary>Дополнительное задание №2</summary>

Добавим переменную `node_count` для указания количества создаваемых VM:

```diff
 resource "google_compute_instance" "app" {
-  name         = "reddit-app"
+  count        = var.node_count
+  name         = "reddit-app-${count.index}"
   machine_type = "g1-small"
   zone         = var.zone
```

В `outputs.tf` добавим вывод публичных IP создаваемых VM и балансировщика: 

```console
$ terraform output
app_external_ip = [
  "35.240.124.75",
  "34.77.129.176",
]
lb_external_ip = 34.77.144.175
```

Проверим результат при помощи утилиты `gcloud`:

```console
$ gcloud compute forwarding-rules list
NAME                           REGION        IP_ADDRESS     IP_PROTOCOL  TARGET
reddit-app-lb-forwarding-rule  europe-west1  34.77.144.175  TCP          europe-west1/targetPools/reddit-app-lb-target-pool
```

```console
$ gcloud compute instances list
NAME          ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP    EXTERNAL_IP    STATUS
reddit-app-0  europe-west1-b  g1-small                   10.132.0.63    35.240.124.75  RUNNING
reddit-app-1  europe-west1-b  g1-small                   10.132.15.192  34.77.129.176  RUNNING
```

```console
$ gcloud compute target-pools describe reddit-app-lb-target-pool --format json | jq '.instances'
[
  "https://www.googleapis.com/compute/v1/projects/************************/zones/europe-west1-b/instances/reddit-app-0",
  "https://www.googleapis.com/compute/v1/projects/************************/zones/europe-west1-b/instances/reddit-app-1"
]
```
</details>

## Lesson 9: homework 7
Terraform: работы с модулями.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#7](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/7)

<details>
  <summary>Основное задание</summary>

При помощи packer созданы новые образы для раздельного деплоя reddit-db и reddit-app:

```console
$ gcloud compute images list --no-standard-images
NAME                        PROJECT                   FAMILY           DEPRECATED  STATUS
reddit-app-base-1571378434  ************************  reddit-app-base              READY
reddit-db-base-1571378176   ************************  reddit-db-base               READY
```

Созданы модули terraform `app`, `db` и `vpc`:

```console
$ tree ./modules/
./modules/
├── app
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── db
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── vpc
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

Созданы изолированные окружения `stage` и `prod`.
</details>

<details>
  <summary>Дополнительное задание № 1</summary>

Настроено хранение state-файлов terraform в Google Storage:

```console
$ gsutil ls -r gs://otus-devops-infra-ftaskaev/terraform/state/
gs://otus-devops-infra-ftaskaev/terraform/state/:

gs://otus-devops-infra-ftaskaev/terraform/state/prod/:
gs://otus-devops-infra-ftaskaev/terraform/state/prod/default.tfstate

gs://otus-devops-infra-ftaskaev/terraform/state/stage/:
gs://otus-devops-infra-ftaskaev/terraform/state/stage/default.tfstate
```
</details>

<details>
  <summary>Дополнительное задание № 2</summary>

Для провижининга reddit-app необходимо перенастроить Mongo на внешний IP.  
Для этого добавим provisioner в `modules/db/main.tf`:

```console
provisioner "remote-exec" {
  inline = [
    "sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf",
    "sudo systemctl restart mongod"
  ]
}
```

В `modules/db/outputs.tf` добавим вывод внутреннего IP db для передачи в провиженер app:

```console
output "db_internal_ip" {
  value = google_compute_instance.db.network_interface.0.network_ip
}
```

В `modules/app/main.tf` добавим провиженер файла с IP db, который используем в в качестве `EnvironmentFile` для puma.service:

```console
provisioner "remote-exec" {
  inline = [
    "sudo echo DATABASE_URL=${var.db_internal_ip} > /tmp/puma.env"
  ]
}
```

Для возможности отключать/включать провиженинг, создадим в `modules/app/main.tf` null_resource и перенесём провиженеры в него. Ресур будет исполняться в зависимости от значения переменной `app_provision`:

```console
resource "null_resource" "post-install" {
  # This code should run if app_provision is set true
  count = "${var.app_provision ? 1 : 0}"

  [... provisioner code ...]

}
```
</details>

## Lesson 10: homework 8
Ansible: написание ansible-плейбуков на основе имеющихся bash-скриптов.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#8](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/8)

<details>
  <summary>Основное задание</summary>

После удаления дирректории плейбук выполнился с результатом `changed=1`:

```console
$ ansible-playbook clone.yml

PLAY [Clone] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [appserver]

TASK [Clone repo] ***********************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP ******************************************************************************************************************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
</details>

<details>
  <summary>Дополнительное задание</summary>

Написал скрипт `ansible/inventator.py`, генерирующий динапический inventory при помощи API GCE.  
Для корректной работы необходимо указать PROJECT_ID, ZONE_ID и получить API-токен:

```console
gcloud auth application-default print-access-token
```

Работы ansible с использованием динапической inventory:

```console
$ ansible-inventory -i inventator.py --list
{
    "_meta": {
        "hostvars": {
            "reddit-app": {
                "ansible_host": "104.155.83.254"
            },
            "reddit-db": {
                "ansible_host": "35.205.107.59"
            }
        }
    },
    "all": {
        "children": [
            "ungrouped"
        ]
    },
    "ungrouped": {
        "hosts": [
            "reddit-app",
            "reddit-db"
        ]
    }
}
```

```console
$ ansible -i inventator.py -m ping all
reddit-app | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
reddit-db | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```
</details>

## Lesson 11: homework 9
Ansible: управление настройками хостов и деплой приложения при помощи Ansible.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#9](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/9)

<details>
  <summary>Основное задание</summary>

 * В ходе выполнения ДЗ были написаны playbook'и для развёртывания БД и приложения reddit.
 * Provisioners для packer'а были заменены на ansible, с их помощью пересобраны образы VM.
 * Добавлен playbook `site.yml` для развёртывания и обновления связки БД - приложение reddit.

Деплой посредством site.yml:

```console
$ ansible-playbook site.yml

PLAY [Configure MongoDB] ****************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] *********************************************************************************************************************
changed: [dbserver]

RUNNING HANDLER [restart mongod] ********************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] ********************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for puma] ***********************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] *****************************************************************************************************************
changed: [appserver]

TASK [Enable puma service] **************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ***********************************************************************************************************************
changed: [appserver]

PLAY [Deploy App] ***********************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] *************************************************************************************************
changed: [appserver]

TASK [bundle install] *******************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [restart puma] **********************************************************************************************************************
changed: [appserver]

PLAY RECAP ******************************************************************************************************************************************
appserver                  : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
dbserver                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
</details>

<details>
  <summary>Дополнительное задание</summary>

Для dynamic inventory воспользуемся модулем [gcp_compute](https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html).  
Статья на тему: [How to use Ansible GCP compute inventory plugin](http://matthieure.me/2018/12/31/ansible_inventory_plugin.html).  
Устанавливаем необходимые модули:

```console
pip install requests google-auth
```

Создаём сервисный аккаунт, получаем ключ для него и выдаем роль viewer для нашего проекта:

```console
gcloud iam service-accounts create sa-ansible-dynamic-inventory \
  --display-name='Service account for Ansible dynamic inventory'
```
```console
gcloud iam service-accounts keys create sa-ansible-dynamic-inventory.json \
  --iam-account=sa-ansible-dynamic-inventory@[ YOUR-PROJECT-ID ].iam.gserviceaccount.com
```
```console
gcloud projects add-iam-policy-binding [ YOUR-PROJECT-ID ] \
  --member serviceAccount:sa-ansible-dynamic-inventory@[ YOUR-PROJECT-ID ].iam.gserviceaccount.com \
  --role roles/viewer
```

Создаём файл `ansible/otus-devops-infra.gcp.yml`, который будет работать в качестве dynamic inventory.  
В нём необходимо указать ID проекта и путь до ключа сервисного аккаунта:

```console
plugin: gcp_compute
projects:
  - [ YOUR-PROJECT-ID ]
auth_kind: serviceaccount
service_account_file: /Users/me/sa-ansible-dynamic-inventory.json
hostnames:
  - name
compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

Добавляем в `ansible.cfg`:

```console
[defaults]
inventory = ./otus-devops-infra.gcp.yml

[inventory]
enable_plugins = gcp_compute
```

После этого все статические inventory удаляем.

Для корретной настройки приложения reddit в `templates/db_config.j2` берём приватный IP БД из inventory:

```django
DATABASE_URL={{ hostvars['reddit-db'].networkInterfaces[0].networkIP }}
```
</details>

## Lesson 12: homework 10
Ansible: написание ролей для управления конфигурацией сервисов и настройками хостов.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#11](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/11)

<details>
  <summary>Самостоятельное задание</summary>

В GCE по умолчанию есть правило для открытия HTTP/HTTPS. Чтобы оно применялось к инстансу reddit-app, достаточно добавить тег `web-host` в модуль `terraform/modules/app/main.tf`:

```diff
resource "google_compute_instance" "app" {
   name         = "reddit-app"
   machine_type = "g1-small"
   zone         = var.zone
-  tags         = ["reddit-app"]
+  tags         = ["reddit-app", "web-host"]
   boot_disk {
     initialize_params { image = var.app_disk_image }
   }
```

Добавляем роль `jdauphant.nginx` в `playbooks/app.yml`:

```console
---
- name: Configure App
  hosts: app
  become: true

  roles:
    - app
    - jdauphant.nginx
```
</details>

<details>
  <summary>Дополнительное задание №1</summary>

Для dynamic inventory воспользуемся модулем [gcp_compute](https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html).  
В дополнение к предыдущему заданию добавим разбивку хостов по группам:

```console
plugin: gcp_compute
projects:
  - [ YOUR-PROJECT-ID ]
auth_kind: serviceaccount
service_account_file: /Users/me/sa-ansible-dynamic-inventory.json
hostnames:
  - name
compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP

groups:
  app: "'-app' in name"
  db: "'-db' in name"
```
Проверим:

```console
$ ansible-inventory --graph
@all:
  |--@app:
  |  |--reddit-app
  |--@db:
  |  |--reddit-db
  |--@ungrouped:
```

Скопируем файл в `ansible/environments/prod/otus-devops-infra.gcp.yml` и `ansible/environments/prod/otus-devops-infra.gcp.yml`.
</details>

<details>
  <summary>Дополнительное задание №2</summary>

Для отладки тестов TravisCI утилитой trytravis необходимо было сделать fork репозитория и переименовать его в `trytravis_ftaskaev_infra`.  
В `.travis.yml` добавим задание, которое будет срабатывать по условию `if: branch = master`:

```yaml
jobs:
  include:
    - name: This should run only for master branch
      install:
        # Prepare bin directory
        - mkdir -p ${HOME}/bin ; export PATH=${PATH}:${HOME}/bin
        # Install terraform
        - curl --silent --output terraform.zip https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip
        - unzip terraform.zip -d ${HOME}/bin
        - chmod +x ${HOME}/bin/terraform
        # Install tflint
        - curl --silent -L --output tflint.zip https://github.com/terraform-linters/tflint/releases/download/v0.12.1/tflint_linux_amd64.zip
        - unzip tflint.zip -d ${HOME}/bin
        - chmod +x ${HOME}/bin/tflint
        # Install ansible and ansible-lint
        - pip install --user ansible
        - pip install --user ansible-lint
      before_script:
        - packer --version
        - terraform --version
        - tflint --version
        - ansible --version
        - ansible-lint --version
      script:
        # Packer tests
        - packer validate -var-file=packer/variables.json.example packer/app.json
        - packer validate -var-file=packer/variables.json.example packer/db.json
        # Terraform tests
        - cd ${TRAVIS_BUILD_DIR}/terraform/stage ; terraform init -backend=false ; terraform validate
        - cd ${TRAVIS_BUILD_DIR}/terraform/prod  ; terraform init -backend=false ; terraform validate
        # Tflint tests
        - tflint ${TRAVIS_BUILD_DIR}/terraform/stage
        - tflint ${TRAVIS_BUILD_DIR}/terraform/prod
        # Ansible-lint tests
        - cd ${TRAVIS_BUILD_DIR}/ansible/playbooks ; ansible-lint *

      if: branch = master
```
</details>

## Lesson 13: homework 11
Ansible: доработка имеющихся ролей локально с использование Vagrant.  
Тестирование конфигурации при помощи Molecule и TestInfra.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#12](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/12)

# Дополнительное задание №1

Для корректной работы роли `jdauphant.nginx` необходтмо добавить в `ansible.extra_vars` переменные, которые раньше определялись в `environments/env_name/group_vars/app`:

```diff
       ansible.extra_vars = {
-        "deploy_user" => "vagrant"
+        "deploy_user" => "vagrant",
+        "nginx_sites" => {
+          "default" => [
+            "listen 80",
+            "server_name _",
+            "location / { proxy_pass http://127.0.0.1:9292; }"
+          ]
         }
       }
```

