![Ruby](https://github.com/Lykos/cube_trainer/workflows/Ruby/badge.svg)
![Rubocop](https://github.com/Lykos/cube_trainer/workflows/Rubocop/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# CubeTrainer
TODO: Write this

## Install

### Clone the repository

```shell
git clone git@github.com:Lykos/cube_trainer.git
cd cube_trainer
```

### Install OS dependencies

This example is for Linux, but I'm sure you can figure out how to install postgresql and yarn on
your OS, too.

```shell
sudo apt install postgresql libpq-dev yarn
```

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle install && yarn install
```

### Setup DB User

```shell
sudo su - postgres
createuser cube_trainer -d -E -P
cube_trainer
```

### Initialize the database

```shell
bundle exec rails db:create db:migrate
```

### Run tests

```shell
bundle exec rails spec
```

### Run server
```shell
bin/webpack-dev-server
bundle exec rails server
```

Now you can access the site at http://localhost:3000/signup
