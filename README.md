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

    <%= form_for :thing, :html => { :id => 'upload' } do |form| %>
      <%= form.transloadit :s3_store %>
      <%= form.file_field :upload, 'File to upload' %>
    <% end %>
    
    <%= transloadify :upload %>
