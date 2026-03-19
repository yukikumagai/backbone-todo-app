# backbone-todo-app

A real-time collaborative todo list app built with **Backbone.js** on the client and **Ruby on Rails (3.0.7)** on the server, using **Pusher** to broadcast changes to connected clients.

## Features

- Create and manage todo items
- Real-time updates across clients via Pusher
- Backbone.js models/collections/views on the frontend
- Rails backend with database persistence

## Tech stack

- Frontend: Backbone.js + jQuery + Underscore
- Backend: Ruby on Rails 3.0.7
- Real-time: Pusher
- Database: SQLite (default for local dev)

## Getting started

### Prerequisites

- Ruby (compatible with Rails 3.0.7)
- Bundler
- SQLite

### Setup

1. Install gems:

   - `bundle install`

2. Set up the database:

   - `rake db:migrate`

3. Start the server:

   - `rails s`

4. Open the app:

   - http://localhost:3000/

## Code tour

- Pusher + Backbone integration: `public/javascripts/backpusher.js`
- App wiring and usage: `public/javascripts/application.js`
- Rails config entrypoint: `config.ru`

## Notes

This repo is based heavily on the Backbone.js todos example.

## License

See the repository license (or add one if missing).
