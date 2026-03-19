# Backbone Todo App

A real-time, collaborative todo application built with **Backbone.js** on the frontend and **Ruby on Rails** on the backend, using **Pusher** for seamless synchronization across multiple users.

## Features

- **Real-time Collaboration**: Instantly see changes made by other users in the same list.
- **Backbone.js Architecture**: Clean separation of concerns with Models, Collections, and Views.
- **RESTful API**: Rails backend provides a JSON API for persistence.
- **Live Notifications**: Browser title updates when remote changes occur.

## Technology Stack

- **Backend**: Ruby on Rails (3.0.7)
- **Frontend**: Backbone.js, Underscore.js, jQuery
- **Real-time**: Pusher
- **Database**: SQLite3 (default for local development)

## Getting Started

### Prerequisites

- **Ruby**: Version compatible with Rails 3.0.x (e.g., Ruby 1.9.2, 2.7, or later with some adjustments).
- **Bundler**: `gem install bundler`
- **Pusher Account**: Obtain your `app_id`, `key`, and `secret` from [Pusher](https://pusher.com).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yukikumagai/backbone-todo-app.git
    cd backbone-todo-app
    ```

2.  **Install dependencies**:
    ```bash
    bundle install
    ```

3.  **Configure Pusher**:
    Update `config/initializers/pusher.rb` with your Pusher credentials:
    ```ruby
    Pusher.app_id = 'your-app-id'
    Pusher.key = 'your-key'
    Pusher.secret = 'your-secret'
    ```
    Also, update the Pusher key in `public/javascripts/application.js`:
    ```javascript
    var pusher = new Pusher('your-key');
    ```

4.  **Setup Database**:
    ```bash
    rake db:migrate
    ```

5.  **Run the Server**:
    ```bash
    rails s
    ```
    Visit `http://localhost:3000` to start creating your first todo list!

## How It Works

### Frontend (Backbone.js)

- **Models & Collections**: `app.Todo` and `app.TodoList` manage data and synchronization with the server.
- **Views**: `app.TodoView` and `app.AppView` handle user interaction and rendering using Underscore templates.
- **Backpusher**: A custom integration (`public/javascripts/backpusher.js`) that binds Pusher events directly to Backbone collections, ensuring all clients stay in sync.

### Backend (Ruby on Rails)

- **Lists**: Groups of todo items identified by a unique token.
- **Items**: Individual tasks within a list.
- **Synchronization**: When an item is created, updated, or destroyed, Rails triggers a Pusher event to notify all other clients subscribed to that list's channel.

## Code Structure

- `app/controllers`: Handles API requests for lists and items.
- `app/models`: Defines list and item logic.
- `app/views`: Provides the initial HTML layout and Backbone templates.
- `public/javascripts`: Contains all frontend logic and libraries.

---
*Based on the original [backbone.js todo-list example](http://documentcloud.github.com/backbone/docs/todos.html).*
