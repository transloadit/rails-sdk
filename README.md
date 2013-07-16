[![Build Status](https://travis-ci.org/transloadit/rails-sdk.png?branch=master)](https://travis-ci.org/transloadit/rails-sdk)

# transloadit-rails

Fantastic file uploading for your Rails application.

## Description

This is the official Rails gem for [Transloadit](http://transloadit.com). It allows
you to automate uploading files through the Transloadit REST API.

## Install

```bash
$ gem install transloadit-rails
```

## Getting started

To get started, you need to add the 'transloadit-rails' gem to your Rails
project's Gemfile.

```bash
$ echo "gem 'transloadit-rails'" >> Gemfile
```

Now update your bundle and run the generator.

```bash
$ bundle install
$ rails g transloadit:install
```

## Configuration

Edit `config/transloadit.yml`. It has an `auth` section for your transloadit
credentials and a `templates` section to define or refer to existing
templates. It is highly recommended to [enable authentication](https://transloadit.com/docs/authentication) and signing for
the upload forms.

```yaml
auth:
  key     : '4d2e...'
  secret  : '8ad1...' # optional, but highly recommended
  duration: 1800      # 30 minute validity period for signed upload forms

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
```

### Configuration by Environment

The transloadit configurations can be further broken up by environment tags to
match the environments used by the application (i.e.  development, test,
production).

Please note, the environment tags must match the application's environments
exactly in order to be used.

```yaml
development:
  auth:
    key     : '4d2e...'
    ...

  templates:
    s3_store: '4d2e...'
    ...

production:
  auth:
    key     : '123a...'
    ...

  templates:
    s3_store: '789b...'
    ...
```

## Support IE6 or jQuery < 1.9

If you have to support IE6 and use a jQuery version below 1.9, you have to change
the jquery_sdk_version in the config to 'v1.0.0':

```yaml
production:
  jquery_sdk_version: 'v1.0.0'
  auth:
    ...
```

## Usage

Refer to the templates with the `transloadit` helper. This requires jQuery,
and loads the [Transloadit jQuery plugin](https://github.com/transloadit/jquery-sdk).
It also uses JavaScript to ensure your form is encoded as `multipart/form-data`.

```erb
<%= form_for :upload, :html => { :id => 'upload' } do |form| %>
  <%= transloadit :s3_store %>
  <%= form.label      :file, 'File to upload' %>
  <%= form.file_field :file %>
  <%= form.submit %>
<% end %>

<%= transloadit_jquerify :upload %>
```

If you want to use the automatic transload parameter decoding, you have to include
the Transloadit::Rails::ParamsDecoder module into your controller

```ruby
class YourController
  include Transloadit::Rails::ParamsDecoder
end
```

that way the param[:transloadit] is automatically decoded for you, if it exists

## Tutorial

In this tutorial, you are going to learn how to use transloadit in a freshly
setup rails project.

If you haven't already done so, go ahead and install Rails.

```bash
$ gem install rails
```

With rails installed, let's create a new app called 'my_app'.

```bash
$ rails new my_app
$ cd my_app
```

In order to use transloadit in this app, we need to add the gem to our Gemfile
and bundle things up.

```bash
$ echo "gem 'transloadit-rails'" >> Gemfile
$ bundle install
```

With that in place, it's time to generate our transloadit configuration, as
well as a basic UploadsController and a dummy Upload model.

```bash
$ rails g transloadit:install
$ rails g controller uploads new create
$ rails g model upload
$ rake  db:migrate
```

The controller generator we just executed has probably put two GET routes into
your `config/routes.rb`. We don't want those, so lets go ahead an overwrite
them with this.

```ruby
MyApp::Application.routes.draw do
  resources :uploads
end
```

Next we need to configure our `config/transloadit.yml` file. For this tutorial,
just put in your credentials, and define an image resize step as indicated
below:

```yaml
auth:
  key     : '4d2e...'
  secret  : '8ad1...'
  duration: 1800      # 30 minute validity period for signed upload forms

templates:
  image_resize:
    steps:
      resize:
        robot : '/image/resize'
        format: 'jpg'
        width : 320
        height: 200
```

Note that we encourage you to enable authentication in your Transloadit Account
and put your secret into the ```config/transloadit.yml``` to have your requests
signed.

Alright, time to create our upload form. In order to do that, please open
`app/views/uploads/new.html.erb`, and put the following code in:

```erb
<%= javascript_include_tag '//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js' %>

<h1>Upload an image</h1>
<%= form_for Upload.new, :html => { :id => 'upload' } do |form| %>
  <%= transloadit :image_resize %>
  <%= form.label      :file, 'File to upload' %>
  <%= form.file_field :file %>
  <%= form.submit %>
<% end %>

<%= transloadit_jquerify :upload, :wait => true %>
```

With this in place, we can modify the `app/views/uploads/create.html.erb` view
to render the uploaded and resized image:

```erb
<h1>Resized upload image</h1>
<%= image_tag params[:transloadit][:results][:resize].first[:url] %>
```

In order to use the transloadit params in your controller and views you
have to include the ParamsDecoder into your controller. Let's do that for our
UploadsController.

Open up `app/controllers/uploads_controller.rb` and adapt it like that:

```ruby
class UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  def new
  end

  def create
  end

end
```

That's it. If you've followed the steps closely, you should now be able to
try your first upload. Don't forget do start your rails server first:

```bash
$ rails server
```

Then go to http://localhost:3000/uploads/new, and upload an image. If you did
everything right, you should see the uploaded and resized file as soon as the
upload finishes.

## Testing

### RSpec request specs

If you want to test your file uploads without relying on the network (a
good idea to keep them fast and lean) you can include some request spec
helpers to allow you to easily populate the `transloadit_params` and
`params[:transloadit]` in your actions.

First, in your `spec/spec_helper.rb` :
```ruby
require 'transloadit/rspec/helpers'
```

Now, in your request spec :
```ruby
# NOTE: It's important that you don't use :js => true, otherwise your
#       test will actually hit out using AJAX, making your test dependent on the
#       network.
it "can upload data files", :js => false do
  attach_file 'upload_file', Rails.root.join('spec', 'asset', 'example.pdf')

  # UploadsController should be replaced with the actual controller
  # you're expecting to POST to when the upload is done
  stub_transloadit!(UploadsController, example_json)

  click_button 'Submit'
end

def example_json
  "{ ... JSON content from a real POST ... }"
end
```

## License

MIT, see [LICENSE](LICENSE)
