[![Build Status](https://travis-ci.org/transloadit/rails-sdk.png?branch=master)](https://travis-ci.org/transloadit/rails-sdk)

## rails-sdk

A **Rails** Integration for [Transloadit](https://transloadit.com)'s file uploading and encoding service

## Intro

[Transloadit](https://transloadit.com) is a service that helps you handle file uploads, resize, crop and watermark your images, make GIFs, transcode your videos, extract thumbnails, generate audio waveforms, and so much more. In short, [Transloadit](https://transloadit.com) is the Swiss Army Knife for your files.

This is a **Rails** SDK to make it easy to talk to the [Transloadit](https://transloadit.com) REST API.

*This gem provides browser integration. If you're looking to integrate Transloadit from your own serverside Ruby code checkout the [ruby-sdk](https://github.com/transloadit/ruby-sdk).*

## Install

```bash
$ gem install transloadit-rails
```

or add the 'transloadit-rails' gem to your Rails project's Gemfile and update your bundle.

```bash
$ echo "gem 'transloadit-rails'" >> Gemfile
$ bundle install
```

After installation you need to run the transloadit `install` generator to complete the setup.

```bash
$ rails g transloadit:install
```

## Configuration

Edit `config/transloadit.yml`. It has an `auth` section for your transloadit
credentials and a `templates` section to define or refer to existing
templates. It is highly recommended to [enable authentication](https://transloadit.com/docs/authentication) and signing for
the upload forms.

```yaml
auth:
  key     : 'TRANSLOADIT_KEY'
  secret  : 'TRANSLOADIT_SECRET' # optional, but highly recommended
  duration: 1800      # 30 minute validity period for signed upload forms

templates:
  # template identified by template_id
  s3_store: 'YOUR_TEMPLATE_ID'

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
    key     : 'TRANSLOADIT_KEY'
    ...

  templates:
    s3_store: 'YOUR_TEMPLATE_ID'
    ...

production:
  auth:
    key     : 'TRANSLOADIT_KEY'
    ...

  templates:
    s3_store: 'YOUR_TEMPLATE_ID'
    ...
```

## Usage

Refer to the templates (which you have set in the [config](https://github.com/transloadit/rails-sdk#configuration)) with the `transloadit` helper.

```erb
<%= form_for :upload, :html => { :id => 'upload' } do |form| %>
  <%= transloadit :s3_store %>
  <%= form.label      :file, 'File to upload' %>
  <%= form.file_field :file %>
  <%= form.submit %>
<% end %>

<%= javascript_include_tag '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js' %>
<%= transloadit_jquerify :upload %>
```

This requires jQuery, and loads the [Transloadit jQuery plugin](https://github.com/transloadit/jquery-sdk).
*(Be sure to exclude the `<%= javascript_include_tag '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js' %>` tag if you already have jQuery loaded.)*

It also uses JavaScript to ensure your form is encoded as `multipart/form-data`.

If you want to use the automatic transloadit parameter decoding, you have to include
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
<%= javascript_include_tag '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js' %>

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

## Example

An example rails application following the [tutorial above](https://github.com/transloadit/rails-sdk#tutorial) can be found in the [examples](https://github.com/transloadit/rails-sdk/tree/master/examples) directory.

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

## Compatibility

At a minimum, this gem should work on MRI 2.3.0, 2.2.0, 2.1.0, Rubinius, and JRuby.
It may also work on older ruby versions, but support for those Rubies is not guaranteed.
If it doesn't work on one of the officially supported Rubies, please file a bug report.
Compatibility patches for other Rubies are welcome.

Support for EOL'd Ruby 1.9.x and Ruby 2.0 has been dropped, please use version 1.2.0
if you need support for older Ruby versions.

Testing against these versions is performed automatically by [Travis CI](https://travis-ci.org/transloadit/rails-sdk).

### Support IE6 or jQuery < 1.9

If you have to support IE6 and use a jQuery version below 1.9, you have to change
the jquery_sdk_version in the config to 'v1.0.0':

```yaml
production:
  jquery_sdk_version: 'v1.0.0'
  auth:
    ...
```


## License

MIT, see [LICENSE](LICENSE)
