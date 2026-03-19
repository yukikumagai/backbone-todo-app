# Backbone Todo App

A real-time collaborative to-do list built with **Ruby on Rails 3**, **Backbone.js**, and **Pusher**.

## Features

- Create, edit, complete, and delete to-do items.
- Share any list via its unique URL.
- Changes sync to all connected clients in real time via Pusher.

---

## Getting Started

### Prerequisites

- Ruby ≥ 1.9.2
- Bundler
- A [Pusher](https://pusher.com) account (free tier is sufficient)

### Setup

```bash
git clone https://github.com/yukikumagai/backbone-todo-app.git
cd backbone-todo-app

bundle install

cp .env.example .env
# Edit .env and fill in your Pusher credentials and a SECRET_TOKEN

bundle exec rake db:create db:migrate
bundle exec rails server
```

Open `http://localhost:3000` in your browser.

---

## Environment Variables

| Variable         | Description                                     |
|------------------|-------------------------------------------------|
| `SECRET_TOKEN`   | Rails cookie-signing secret (≥ 30 characters)  |
| `PUSHER_APP_ID`  | Pusher application ID                           |
| `PUSHER_KEY`     | Pusher publishable key                          |
| `PUSHER_SECRET`  | Pusher secret key                               |

Never commit real secrets to version control. Use `.env` (git-ignored) or your platform's config vars (e.g. Heroku).

---

## Running Tests

```bash
bundle exec rake test
```

---

## Architecture

```
app/
  controllers/
    lists_controller.rb   # Creates lists; redirects unknown tokens to root
    items_controller.rb   # JSON CRUD for items; fires Pusher events
  models/
    list.rb               # Generates a unique URL token; owns items
    item.rb               # Validates presence of shortdesc
  views/
    layouts/application.html.erb
    lists/show.html.erb   # Backbone templates + minimal boot data

public/javascripts/
  application.js   # Backbone app (models, views, realtime, bootstrap)
```

---

## Credits

- Original TodoMVC implementation by [Jérôme Gravel-Niquet](http://jgn.me/)
- Real-time layer by [Pusher](https://pusher.com)
- Icons by [@somerandomdude](http://somerandomdude.com/projects/iconic/)
