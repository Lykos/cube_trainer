![CodeQL](https://github.com/Lykos/cube_trainer/workflows/CodeQL/badge.svg)
![Rubocop](https://github.com/Lykos/cube_trainer/workflows/Rubocop/badge.svg)
![Ruby](https://github.com/Lykos/cube_trainer/workflows/Ruby/badge.svg)
![Ruby](https://github.com/Lykos/cube_trainer/workflows/Typescript/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# CubeTrainer

This is the repository for https://www.cubetrainer.org, which is a small website that contains some tools to support Rubik's Cube training with a focus on blindfolded solving.

## Install

### Clone the repository

```shell
git clone git@github.com:Lykos/cube_trainer.git
cd cube_trainer
```

### Install OS dependencies

This example is what I did on Ubuntu, but I'm sure you can figure out how to install
Ruby, PostgreSQL and npm on your OS, too.

```shell
sudo apt install ruby postgresql libpq-dev npm
```

### Install Ruby & JS dependencies

Using [Bundler](https://github.com/bundler/bundler) and [npm](https://github.com/npm/cli):

```shell
bundle install && npm install
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
bundle exec rake db:create db:migrate
```

### Build the frontend

```shell
bundle exec rails npm:build
```

### Run tests

```shell
bundle exec rails spec
```

### Run frontend tests

```shell
bundle exec rails npm:test
```

### Run server

In two separate terminals, run these two commands:

```shell
bundle exec rails npm:start
bundle exec rails server
```

Now you can access the site at http://localhost:4200. Note that accessing it via http://localhost:3000 might also work, but you won't get automatic refreshes on TypeScript changes, so it's not recommended.

## Production Setup

The website is hosted on Heroku and is automatically deployed if CI on the master branch on Github passes. It uses Mailgun for sending mails.

## Using the Website

Navigate to https://www.cubetrainer.org/signup to create an account. After the signup process, you can log in via https://www.cubetrainer.org/login and then create training sessions in https://www.cubetrainer.org/modes. What the website is best at is training blind algs with smart sampling that will show you algorithms more that you don't know well.

## Background

This website started as a bunch of command line scripts that helped me practicing and eventually I added a database, than a small web frontend and eventually I turned it into a full website. The entire backstory can be found in https://www.cubetrainer.org/about.