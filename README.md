# transloadit-rails

Fantastic file uploading for your Rails application.

## Description

This is the official Rails gem for [Transloadit](transloadit.com). It allows
you to automate uploading files through the Transloadit REST API.

## Install

    gem install transloadit

## Getting started

To get started, you need to add the 'transloadit-rails' gem to your Rails
project's Gemfile.

    gem 'transloadit-rails'

Now update your bundle and run the generator.

    $ bundle install
    $ rails g transloadit:install

## Configuration

Edit `config/transloadit.yml`. It has an `auth` section for your transloadit
credentials and a `templates` section to define or refer to existing
templates.

    auth:
      key   : '4d2e...'
      secret: '8ad1...' # optional, but highly recommended
    
    templates:
        # template identified by template_id
        s3_store: '4d2e...'
        
        # template defined inline
        image_resize:
          steps:
            resize:
              robot : '/image/resize'
              width : 320
              height: 200

## Usage

Refer to the templates with the `transloadify` helper. This requires jQuery,
and loads the [Transloadit jQuery plugin](https://github.com/transloadit/jquery-sdk).
It also uses JavaScript to ensure your form is encoded as `multipart/form-data`.

    <%= form_for :upload, :html => { :id => 'upload' } do |form| %>
      <%= form.transloadit :s3_store %>
      <%= form.label      :file, 'File to upload' %>
      <%= form.file_field :file %>
      <%= form.submit %>
    <% end %>
    
    <%= transloadit_jquerify :upload %>

## Tutorial

In this tutorial, you are going to learn how to use transloadit in a freshly
setup rails project.

If you haven't already done so, go ahead an install rails as well as the
transloadit gem:

    $ gem install rails
    $ gem install transloadit

With rails installed, let's create a new app called 'my_app':

    $ rails new my_app
    $ cd my_app

In order to use transloadit in this app, we need to add the gem to our Gemfile
and bundle things up:

    $ echo "gem 'transloadit-rails'" >> Gemfile
    $ bundle install

With that in place, it's time to generate our transloadit configuration, as
well as a basic UploadsController:

    $ rails generate transloadit:install
    $ rails generate controller uploads new create

The controller generator we just executed has probably put two GET routes into
your `config/routes.rb`. We don't want those, so lets go ahead an overwrite
them with this:

    MyApp::Application.routes.draw do
      resources :uploads
    end

Next we need to configure our `config/transloadit.yml` file. For this tutorial,
just put in your credentials, and define an image resize step as indicated
below:

    auth:
      key   : '4d2e...'
      secret: '8ad1...'

    templates:
        image_resize:
          steps:
            resize:
              robot : '/image/resize'
              format: 'jpg'
              width : 320
              height: 200

Alright, time to create our upload form. In order to do that, please open
`app/views/uploads/new.html.erb`, and put the following code in:

    <%= javascript_include_tag '//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js' %>

    <h1>Upload an image</h1>
    <%= form_for :upload, :html => { :id => 'upload' } do |form| %>
      <%= form.transloadit :image_resize %>
      <%= form.label      :file, 'File to upload' %>
      <%= form.file_field :file %>
      <%= form.submit %>
    <% end %>

    <%= transloadit_jquerify :upload, :wait => true %>

Now let's open up our `uploads_controller.rb` in order to modify our `create`
action to parse the response JSON we get from the jQuery plugin:

    def create
      @upload = ActiveSupport::JSON.decode(params[:transloadit])
    end

With this in place, we can modify the `create.html.erb` view to render the
uploaded and resized image:

    <h1>Resized upload image</h1>
    <%= image_tag @upload['results']['resize'].first['url'] %>

That's it. If you've followed the steps closely, you should now be able to
try your first upload. Don't forget do start your rails server first:

    $ rails server

Then go to http://localhost:3000/uploads/new, and upload an image. If you did
everything right, you should see the uploaded and resized file as soon as the
upload finishes.
