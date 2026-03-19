/**
 * application.js
 *
 * Backbone.js Todo application with Pusher real-time sync.
 *
 * Organised into four namespaced layers:
 *   app.models    – Backbone Model + Collection
 *   app.views     – Backbone Views (TodoView, AppView)
 *   app.realtime  – Pusher / Backpusher wiring
 *   app.init      – Bootstrap on DOM-ready
 */

;(function ($, Backbone, _, Pusher, Backpusher) {
  'use strict';

  /* ------------------------------------------------------------------ */
  /* Namespace                                                            */
  /* ------------------------------------------------------------------ */
  window.app = window.app || {};

  /* ------------------------------------------------------------------ */
  /* Constants                                                            */
  /* ------------------------------------------------------------------ */
  var KEYS = { ENTER: 13 };
  var TOOLTIP_SHOW_DELAY  = 400;   // ms before tooltip appears
  var TOOLTIP_HIDE_DELAY  = 2400;  // ms tooltip stays visible
  var TITLE_RESET_DELAY   = 2000;  // ms after focus to reset title

  /* ================================================================== */
  /* Models                                                               */
  /* ================================================================== */

  /**
   * Todo – represents a single to-do item.
   */
  app.Todo = Backbone.Model.extend({
    EMPTY: 'Empty todo…',

    url: function () {
      var id   = this.get('id');
      var base = app.list_path + '/items';
      return (id ? base + '/' + id : base) + '.json';
    },

    initialize: function () {
      if (!this.get('shortdesc')) {
        this.set('shortdesc', this.EMPTY);
      }
    },

    /** Toggle the isdone flag and persist immediately. */
    toggle: function () {
      this.save({ isdone: !this.get('isdone') });
    },

    /** Destroy on the server and remove the view from the DOM. */
    clear: function () {
      this.destroy();
    }
  });

  /**
   * TodoList – ordered collection of Todo models.
   */
  app.TodoList = Backbone.Collection.extend({
    model: app.Todo,

    url: function () {
      return app.list_path + '/items.json';
    },

    done: function () {
      return this.filter(function (todo) { return todo.get('isdone'); });
    },

    remaining: function () {
      return this.filter(function (todo) { return !todo.get('isdone'); });
    },

    comparator: function (todo) {
      return todo.get('id');
    }
  });

  /* Singleton collection used throughout the app */
  app.Todos = new app.TodoList();

  /* ================================================================== */
  /* Views                                                                */
  /* ================================================================== */

  /**
   * TodoView – renders a single list item and handles its interactions.
   */
  app.TodoView = Backbone.View.extend({
    tagName: 'li',

    template: null, // assigned after DOM-ready in app.init

    events: {
      'click   .check':            'toggleDone',
      'click   span.todo-edit':    'edit',
      'click   span.todo-destroy': 'clear',
      'keypress .todo-input':      'updateOnEnter'
    },

    initialize: function () {
      _.bindAll(this, 'render', 'remove', 'close');
      this.model.on('change',  this.render,  this);
      this.model.on('destroy', this.remove,  this);
    },

    render: function () {
      this.$el.html(this.template(this.model.toJSON()));
      this._cacheEditInput();
      this._refreshContent();
      return this;
    },

    /* -- private helpers -- */

    _cacheEditInput: function () {
      this.editInput = this.$('.todo-input');
      this.editInput.on('blur', this.close);
    },

    _refreshContent: function () {
      var shortdesc = this.model.get('shortdesc');
      this.$('.todo-content').text(shortdesc);
      this.editInput.val(shortdesc);
    },

    /* -- event handlers -- */

    toggleDone: function () {
      this.model.toggle();
    },

    edit: function () {
      this.$el.addClass('editing');
      this.editInput.focus();
    },

    close: function () {
      var val = $.trim(this.editInput.val());
      if (val) {
        this.model.save({ shortdesc: val });
      }
      this.$el.removeClass('editing');
    },

    updateOnEnter: function (e) {
      if (e.which === KEYS.ENTER) { this.close(); }
    },

    clear: function () {
      this.model.clear();
    }
  });

  /**
   * AppView – top-level view that owns the todo list and the stats bar.
   */
  app.AppView = Backbone.View.extend({
    el: '#todoapp',

    statsTemplate: null, // assigned after DOM-ready in app.init

    events: {
      'keypress  #new-todo':          'createOnEnter',
      'focus     #new-todo':          'showTooltip',
      'blur      #new-todo':          'hideTooltip',
      'click     .todo-clear a':      'clearCompleted',
      'click     .title p input':     'selectShareUrl',
      'dblclick  .title p input':     'selectShareUrl'
    },

    initialize: function () {
      _.bindAll(this, 'addOne', 'removeOne', 'addAll', 'render',
                      'showTooltip', 'hideTooltip');

      this.input   = this.$('#new-todo');
      this.tooltip = this.$('.ui-tooltip-top').hide();

      app.Todos.on('add',   this.addOne,   this);
      app.Todos.on('remove', this.removeOne, this);
      app.Todos.on('reset', this.addAll,   this);
      app.Todos.on('all',   this.render,   this);

      app.Todos.fetch();
    },

    render: function () {
      this.$('#todo-stats').html(this.statsTemplate({
        total:     app.Todos.length,
        done:      app.Todos.done().length,
        remaining: app.Todos.remaining().length
      }));
    },

    addOne: function (todo) {
      var view = new app.TodoView({ model: todo });
      view.template = app.TodoView.prototype.template; // inherit compiled tpl
      this.$('#todo-list').append(view.render().el);
    },

    removeOne: function (todo) {
      this.$('#todo-item-' + todo.id).closest('li').remove();
    },

    addAll: function () {
      var self = this;
      app.Todos.each(function (todo) {
        var view = new app.TodoView({ model: todo });
        view.template = app.TodoView.prototype.template;
        self.$('#todo-list').prepend(view.render().el);
      });
    },

    createOnEnter: function (e) {
      if (e.which !== KEYS.ENTER) { return; }
      var val = $.trim(this.input.val());
      if (!val) { return; }

      app.Todos.create({ shortdesc: val, isdone: false });
      this.input.val('').blur();
    },

    clearCompleted: function (e) {
      e.preventDefault();
      _.invoke(app.Todos.done(), 'clear');
    },

    showTooltip: function () {
      var self = this;
      document.title = 'Todos';
      this._clearTooltipTimer();
      this.tooltipTimer = _.delay(function () {
        self.tooltip.fadeIn(300);
        self.tooltipTimer = _.delay(self.hideTooltip, TOOLTIP_HIDE_DELAY);
      }, TOOLTIP_SHOW_DELAY);
    },

    hideTooltip: function () {
      this._clearTooltipTimer();
      this.tooltip.fadeOut(300);
    },

    selectShareUrl: function (e) {
      $(e.currentTarget).select();
    },

    _clearTooltipTimer: function () {
      if (this.tooltipTimer) {
        clearTimeout(this.tooltipTimer);
        this.tooltipTimer = null;
      }
    }
  });

  /* ================================================================== */
  /* Real-time (Pusher / Backpusher)                                      */
  /* ================================================================== */

  app.realtime = {
    /**
     * Initialise Pusher and Backpusher.
     * Called once on DOM-ready after the collection is set up.
     */
    init: function (pusherKey, channelName) {
      var pusher  = new Pusher(pusherKey);
      var channel = pusher.subscribe(channelName);
      var bp      = new Backpusher(channel, app.Todos);

      bp.bind('remote_create',  function () { app.realtime._bumpTitle('new'); });
      bp.bind('remote_update',  function () { app.realtime._bumpTitle('updated'); });
      bp.bind('remote_destroy', function () { app.realtime._bumpTitle('removed'); });
    },

    /**
     * Append a [n <verb>] counter to the document title.
     * Resets to 'Todos' when the window regains focus.
     */
    _bumpTitle: function (verb) {
      var title   = document.title;
      var matches = title.match(/\[(\d+) (\w+)\]/);

      if (matches && matches[2] === verb) {
        var count = parseInt(matches[1], 10) + 1;
        document.title = 'Todos [' + count + ' ' + verb + ']';
      } else {
        document.title = 'Todos [1 ' + verb + ']';
      }
    }
  };

  /* ================================================================== */
  /* Bootstrap                                                            */
  /* ================================================================== */

  app.init = function () {
    // Compile Underscore templates once, share the reference on prototypes.
    app.TodoView.prototype.template  = _.template($('#item-template').html());
    app.AppView.prototype.statsTemplate = _.template($('#stats-template').html());

    // Mount the application view.
    window.AppInstance = new app.AppView();

    // Wire up real-time sync.
    app.realtime.init('511a5abb7486107ce643', app.list_channel);

    // Reset title counter when the window is focused.
    $(window).on('focus', function () {
      setTimeout(function () { document.title = 'Todos'; }, TITLE_RESET_DELAY);
    });
  };

  /* Run on DOM-ready */
  $(app.init);

}(jQuery, Backbone, _, Pusher, Backpusher));
