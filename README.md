[![CodeQL](https://github.com/Lykos/cube_trainer/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/Lykos/cube_trainer/actions/workflows/codeql-analysis.yml)
[![Rubocop](https://github.com/Lykos/cube_trainer/actions/workflows/rubocop.yml/badge.svg)](https://github.com/Lykos/cube_trainer/actions/workflows/rubocop.yml)
[![Ruby](https://github.com/Lykos/cube_trainer/actions/workflows/ruby.yml/badge.svg)](https://github.com/Lykos/cube_trainer/actions/workflows/ruby.yml)
[![Typescript](https://github.com/Lykos/cube_trainer/actions/workflows/typescript.yml/badge.svg)](https://github.com/Lykos/cube_trainer/actions/workflows/typescript.yml)
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

### Postgresql

This example is what I did on Ubuntu, but I'm sure you can figure out how to install
PostgreSQL on your OS, too.

```shell
sudo apt install postgresql libpq-dev
```

### Ruby

Ruby is the programming language that is used for the CubeTrainer backend. If you only want to run the frontend, this dependency might not be necessary, but note that the frontend alone cannot do a lot, so this is only useful if you want to contribute something where the backend really isn't relevant.

You can install Ruby via any means you prefer. We recommend installing Ruby via [rbenv](https://github.com/rbenv/rbenv). This is a tool that lets you manage different Ruby versions. Check the first few lines in the [Gemfile](Gemfile) for the Ruby version that should be used for CubeTrainer. Other versions might work as well, but there is no guarantee.

You can try to use the Ruby installation that comes via your OS package manager, too, but there is a good chance that this will be an older Ruby version that won't work.

### Node.js and NPM

NPM is the package manager and toolchain we use for the CubeTrainer frontend and Node.js is the JavaScript runtime that NPM uses. If you only want to run the backend, this dependency might not be necessary, but note that the backend alone cannot do a lot, so this is only useful if you want to contribute something where the frontend really isn't relevant.

You can install Node.js and NPM via any means you prefer. We recommend installing it via [nvm](https://github.com/nvm-sh/nvm). This is a tool that lets you manage different Node.js and NPM versions. Check the first few line of the [package.json](package.json) (look for the string "engines") for the Node.js and NPM versions that should be used for CubeTrainer. Other versions might work as well, but there is no guarantee.

You can try to use the Node.js and NPM installation that comes via your OS package manager, too, but there is a good chance that this will be older versions that won't work.

### Filemagic

At the moment, cube trainer depends on the `ruby-filemagic` Gem that depends on the C magic library. We are trying to get rid of this, but while it is still active, you need to install it. This is what I did on Ubuntu:

```
sudo apt install libmagic-dev
```

### Mailcatcher (optional)

Optionally, you can install mailcatcher. This is a useful tool to debug emails that the website sends. Note that the documentation of mailcatcher recommends to set it up separately as a global gem and to not make it a gem dependency.

```shell
gem install mailcatcher
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

The best way to start all the necessary processes is to install [overmind](https://github.com/DarthSim/overmind) and then to simply run:

```shell
overmind start
```

Alternatively, you can run these commands in separate terminals. Mailcatcher is optional and only needed if you want to debug emails.

```shell
bundle exec rails npm:start
bundle exec rails server
mailcatcher # optional
```

Now you can access the site at http://localhost:4200. Note that accessing it via http://localhost:3000 might also work, but you won't get automatic refreshes on TypeScript changes, so it's not recommended.

## Dependencies

For the full list of dependencies, please check the [Gemfile](Gemfile) and the [package.json](package.json), but the most relevant ones are listed here:

* [Ruby on Rails](https://rubyonrails.org/) is the backend framework.
* Typescript with [Angular](https://angular.io/) is the frontend framework.
* [Angular Material](https://material.angular.io/) for the UI components.
* [PostgreSQL](https://www.postgresql.org/) for the backend database.
* [NgRx Store](https://ngrx.io/guide/store) for the state management of the frontend.
* [Devise Token Auth](https://github.com/lynndylanhurley/devise_token_auth) that is based on [Devise](https://github.com/heartcombo/devise) for authentication in the backend.
* [Angular Token](https://github.com/neroniaky/angular-token) for the frontend parts of authentication.
* [TwistyPuzzles](https://github.com/Lykos/twisty_puzzles) to deal with twisty puzzles (like the 3x3x3 cube) in the backend.
* [cubing.js](https://github.com/cubing/cubing.js) to display twisty puzzles in the frontend.
* [Redis](https://redis.io/) to run websockets for ActionCable. This is used to send notifications to the frontend.

For development, there are these relevant dependencies:

* [Rubocop](https://github.com/rubocop/rubocop) is an amazing linter on steroids that helped us a lot to use more idiomatic and modern Ruby constructs.
* [Rspec](https://rspec.info/) is our testing framework.
* [Capybara](https://github.com/teamcapybara/capybara) for integration tests that run a browser and use both frontend and backend. They can be found in the [spec/system](spec/system) directory.
* [Rantly](https://github.com/rantly-rb/rantly) to randomly generate test cases.

Note that the way we combine Angular and Ruby is a bit self-baked. They basically live in different directories and the only connection is a hand-crafted Rails controller that serves the index.html file compiled by Angular. We previously tried to use various other ways to integrate them. Some of them worked, but they were a huge pain, so we went for this handcrafted solution. The problems we encountered with other integrations included:

* We never got Angular components with separate HTML and TS files to work. This meant all the HTML was somehow inlined in a string in the TS file which was ugly and hard to work with.
* For some setups we tried, we couldn't get our integration tests to work. These integration tests are very valuable and we don't want to lose them.
* Somehow the setup forced us to depend on some old webpack versions with known security issues. It wasn't possible to upgrade because some dependencies really needed the old versions.

## Production Setup

The website is hosted on Heroku and is automatically deployed if CI on the master branch on Github passes. It uses the following Heroku plugins.

* It uses Mailgun Starter for sending mails. There's also some config on the Mailgun website.
* It uses Heroku Postgres Basic for the database.
* It uses Heroku Scheduler to regularly scrape sheets. It runs `bundle exec rails scheduler_scrape_sheets` once per day at 12:00 AM UTC.

Formerly it also used Redis-to-go for ActionCable. Redis-to-go was removed from Heroku in August 2023 and we don't have a replacement yet. I.e. the ActionCable related things don't work at the moment. Luckily, they are only used to notify the user of achievements, so it's not removing a lot of functionality.

## Using the Website

Navigate to https://www.cubetrainer.org/signup to create an account. After the signup process, you can log in via https://www.cubetrainer.org/login and then create training sessions in https://www.cubetrainer.org/modes. What the website is best at is training blind algs with smart sampling that will show you algorithms more that you don't know well.

## Background

This website started as a bunch of command line scripts that helped me practicing and eventually I added a database, than a small web frontend and eventually I turned it into a full website. The entire backstory can be found in https://www.cubetrainer.org/about.
