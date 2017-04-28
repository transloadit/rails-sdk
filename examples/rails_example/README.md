# Example Usage of the Transloadit Rails SDK

In order to run this app, you need to install the bundle and generate your transloadit configuration.

```bash
$ bundle install
$ rails g transloadit:install
$ rake  db:migrate
```

Add your Transloadit credentials to the `config/transloadit.yml` file:

```yaml
auth:
  key     : 'TRANSLOADIT_KEY'
  secret  : 'TRANSLOADIT_SECRET'
```

Start the rails server:

```bash
$ rails server
```

Now go to http://localhost:3000/uploads/new, and upload an image. You should see the uploaded and resized file as soon as the
upload finishes.
