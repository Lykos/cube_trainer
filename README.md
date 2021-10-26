![CodeQL](https://github.com/Lykos/cube_trainer/workflows/CodeQL/badge.svg)
![Rubocop](https://github.com/Lykos/cube_trainer/workflows/Rubocop/badge.svg)
![Ruby](https://github.com/Lykos/cube_trainer/workflows/Ruby/badge.svg)
![Yarn](https://github.com/Lykos/cube_trainer/workflows/Yarn%20Test/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# CubeTrainer
TODO: Write more than just installation instructions

## Install

### Clone the repository

```shell
git clone git@github.com:Lykos/cube_trainer.git
cd cube_trainer
```

### Install OS dependencies

This example is for Linux, but I'm sure you can figure out how to install
Ruby, PostgreSQL and Yarn on your OS, too.

```shell
sudo apt install ruby postgresql libpq-dev
```

Install yarn as described here (you have to add a package source and then install via apt): https://classic.yarnpkg.com/en/docs/install/#debian-stable

### Install Ruby & JS dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle install && yarn install
```

### Setup DB User

```shell
sudo su - postgres
createuser cube_trainer -d -E -P
cube_trainer
exit
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
