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

### Дополнительное задание
Сгенерировать валидный сертификат для домена 35-210-119-1.sslip.io:
```console
[me@bastion ~]$ sudo yum install certbot
[me@bastion ~]$ sudo certbot certonly --standalone \
>                       --register-unsafely-without-email \
>                       --preferred-challenges http \
>                       -d 35-210-119-1.sslip.io
```

Проверить установленный сертификат:
```console
mbp-feodor:~ me$ curl -v https://35-210-119-1.sslip.io 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
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

## Lesson 6: homework 4
GCE: автоматизация при помощи gcloud.  
Работа выполнялась на CentOS 7, скрипты установкли лежат в `cloud-testapp/centos7/`.  
PR: [Otus-DevOps-2019-08/ftaskaev_infra#3](https://github.com/Otus-DevOps-2019-08/ftaskaev_infra/pull/4)

testapp_IP = 35.240.75.50  
testapp_port = 9292

### Дополнительное задание
Создать VM с CentOS 7 и установить необходимое ПО с помощью [startup-script](https://gist.github.com/ftaskaev/20d92458978807c2ab7caa358ec29e43):
```console
gcloud compute instances create reddit-ap \
    --boot-disk-size=10GB \
    --image-family centos-7 \
    --image-project=centos-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata startup-script-url=https://gist.githubusercontent.com/ftaskaev/20d92458978807c2ab7caa358ec29e43/raw/2b10ed67878a8db22cb5ce77333478272ca81d9b/puma-server-install.sh
```

Создать правило фильтрации для тэга puma-server:
```console
gcloud compute firewall-rules create default-puma-server \
    --description="Allow traffic to puma-server" \
    --allow=tcp:9292 \
    --target-tags=puma-server
```

