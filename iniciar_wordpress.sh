#!/bin/bash
 cd /tmp #Ir ao diretório /tmp
 sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm #Baixar e instalar o SSM Agent
 sudo systemctl enable amazon-ssm-agent #Iniciar com a instância o SSM Agent
 sudo systemctl start amazon-ssm-agent #Iniciar com a instância o SSM Agent
 sudo yum update -y #Updte da instância/SO
 sudo amazon-linux-extras install -y docker #Instalações dos extras do docker vindas da Amazon
 sudo yum install -y docker #Instalação do docker
 sudo service docker start #Iniciado serviço Docker
 sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose #Baixado e instalado docker-compose de acordo com informações do Docker Hub do Docker-Compose
 sudo chmod +x /usr/local/bin/docker-compose #Permissões de execução do docker-compose
 sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose #Criação de link simbólico para o docker-compose caso falhe a instalação.
 sudo mkdir /wordpress #Criar o diretorio wordpress
 sudo cd /wordpress/
 sudo touch docker-compose.yml #Criar arquivo docker-compose-yml
 sudo tee -a docker-compose.yml > /dev/null <<EOT
version: '3'

services:
  # Base de dados
  db:
    image: mysql:5.7
    volumes:
      - ./volumes/mysql:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    networks:
      - wpsite
  # phpmyadmin
  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - '8080:80'
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: password
    networks:
      - wpsite
  # Wordpress
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - '8000:80'
    volumes:
    - ./volumes/wordpress/:/var/www/html
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    networks:
      - wpsite
networks:
  wpsite:
volumes:
  db_data:
EOT
 sudo docker-compose up -d #Iniciado docker-compose, onde nessa parte o próprio docker instala o wordpress na última versão
 sudo systemctl start docker.service #Iniciar o serviço Docker quando iniciar a instância.
 sudo systemctl enable docker.service #Iniciar o serviço Docker quando iniciar a instância.