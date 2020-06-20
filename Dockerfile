version: '3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_volume:/var/lib/mysql
    env_file:
      - ./.env
volumes:
  db_volume:
