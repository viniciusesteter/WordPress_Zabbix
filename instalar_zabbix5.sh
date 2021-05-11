#Instalar Zabbix Server 5 no Amazon Linux 2

#Atualização do Linux
sudo yum -y update
sudo systemctl reboot

#EPEL repositório Instalação - EPEL contém alguns pacotes que são dependentes da instalação do Zabbix 5
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
#Banco de dados MariaDB
sudo tee /etc/yum.repos.d/mariadb.repo<<EOF 
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

#Começar a instalar o índice de cache do pacote do SO
sudo yum makecach

#Instalação do Banco de dados MariaDB no AMI Linux 2
sudo yum -y install MariaDB-server MariaDB-client

#Habilitar e iniciar o banco MariaDB com o Linux
sudo systemctl enable mariadb
sudo systemctl start mariadb

#Instalação do Banco e é necessário colocar senha
sudo mysql_secure_installation
#Enter current password for root (enter for none): Just press Enter
#Set root password? [Y/n] Y 
#New password:  New-root-password
#Re-enter new password: Re-enter New-root-password
#Remove anonymous users? [Y/n] Y 
#Disallow root login remotely? [Y/n] Y 
#Remove test database and access to it? [Y/n] Y 
#Reload privilege tables now? [Y/n] Y 
#Thanks for using MariaDB!

#Conectar ao MariaDB e configurar um banco de dados e um usuário
mysql -u root -p

#Enter password:
#Welcome to the MariaDB monitor.  Commands end with ; or \g.
#Your MariaDB connection id is 13
#Server version: 10.5.8-MariaDB MariaDB Server

#Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

#Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

#MariaDB [(none)]> SELECT VERSION ();
#+----------------+
#| VERSION ()     |
#+----------------+
#| 10.5.8-MariaDB |
#+----------------+
#1 row in set (0.000 sec)

#MariaDB [(none)]> \q
#Bye

#Seguintes comando para iniciar o banco dentro do MariaDBCREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin; 
#CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'DBStr0ngP@ssword'; #Escolher a senha
#GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; 
#FLUSH PRIVILEGES; 
#EXIT

#Instalar o Servidor WEB HTTPD
sudo yum -y install httpd vim bash-completion

#Habilitar e iniciar o serviço HTTPD com o SO
sudo systemctl enable httpd
sudo systemctl start httpd

#Opcional, confirmar o status do serviço HTTPD
systemctl status httpd

#Definir o nome do servidor dentro das configurações do HTTPD e configurar um e-mail para recebimento de problemas caso queira
sudo vim /etc/httpd/conf/httpd.conf
#ServerName zabbix.example.com
#ServerAdmin admin@example.com

#Após as alterações nas configurações do servidor web HTTPD, reiniciar o serviço.
sudo systemctl restart httpd

#Instalação do Servidor Zabbix no Amazon Linux 2
sudo yum -y install https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm

#Instalação dos pacotes
sudo yum -y install zabbix-server-mysql zabbix-agent zabbix-get

#Instalação do Zabbix FrontEnd
sudo tee /etc/yum.repos.d/centos-scl.repo<<EOF
[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
baseurl=http://mirror.centos.org/centos/7/sclo/x86_64/sclo/
gpgcheck=0
enabled=1

[centos-sclo-rh]
name=CentOS-7 - SCLo rh
baseurl=http://mirror.centos.org/centos/7/sclo/x86_64/rh/
gpgcheck=0
enabled=1
EOF

#Atualização da lista de repositórios YUM após adicionar o repositório acima
sudo yum makecache

#Habilitar o repositório FrontEnd Zabbix e instalação dos pacotes
sudo yum-config-manager --enable zabbix-frontend
sudo yum -y install zabbix-web-mysql-scl zabbix-apache-conf-scl

#Importar o esqueda de banco de dados para MySQL do servidor Zabbix. Se atentar a senha criada anteriormente.
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p'DBStr0ngP@ssword' zabbix

#Habilitar e iniciar os serviços Zabbix com o SO
sudo systemctl start zabbix-server zabbix-agent
sudo systemctl enable zabbix-server zabbix-agent

#Verificar se os serviços estão em execução 
systemctl status zabbix-server zabbix-agent

#Opcional para verificar a porta que o zabbix-server(padrão 10050) e o zabbix-agent (padrão 10051) estão sendo executados
sudo ss -tlnup | grep 10050
sudo ss -tnlup | grep 10051

#Configurar o servidor Zabbix no Amazon Linux 2
sudo vim /etc/zabbix/zabbix_server.conf
#DBHost=localhost 
#DBName=zabbix 
#DBUser=zabbix 
#DBPassword=DBStr0ngP@ssword - Se atendar a senha que foi criada anteriormente.

#Definir o fuso horário
sudo vim /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
#php_value[date.timezone] = America/Sao_Paulo

#Habilitar e restartar todos os serviços.
sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm

#Agora configuração manual no navegador - http://(hostname do servidor Zabbix ou endereço IP)/zabbix/
#Clique na  próxima etapa  para ir para a próxima página onde os status dos pré-requisitos são mostrados.
#Clique em Próxima etapa para definir os detalhes da conexão do banco de dados - nome do banco de dados, usuário e senha.
#Na próxima página, configure os detalhes do servidor, incluindo o nome do servidor.
#Confirme o resumo da instalação e clique em “ Próxima etapa ” para concluir a instalação.
#Se a instalação foi bem-sucedida, você deve receber a mensagem mostrada - Congratulations.
#Clique em  Concluir  para ser direcionado à página de login do Zabbix. Os detalhes de login padrão:
#Faça login com o usuário Admin e senha zabbix.