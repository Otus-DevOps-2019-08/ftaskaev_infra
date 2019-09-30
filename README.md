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

## Основное задание
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

## Дополнительное задание № 1
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
        project = "otus-devops-infra-253221"
      ~ value   = <<~EOT
            appuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser
            appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser
          - appuser_web:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIHBOqX9G6pxyYhq8mUdNQrpat8WO4Q4ekSY1suknDJyzyDm+rbAeUew0DopinkojAiiCY6fAVfiKhNpNqAMXh+qWshfDYF85B5bJheObI7Oxd79thm3i0JiHU4NLZsVqRSspufdfzCrzheWE84IXn76X1vdR6rUZQvdAlyPnDB9XM1vSnKQOWLB3+wmjqeBwCNivtMWXXx2hh9flfw9zI5gWSyGTH2EVGpFOToswBde0QpW8CLde+mjV92GNQZIZjmh5B4Xolf1hXiVEFXchHvCHDxnnFBCO36xTKhzEZeXyvY5bchIJ+mf94ZJs7qCPlYjINKL9tiNZEj2MagWL3 appuser_web
        EOT
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

