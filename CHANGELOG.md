### 1.x.x / Not yet released ###

* MIT license
* Bumped transloadit dependency to >= 1.1.1

### 1.1.0 / 2013-03-16 ###

* Switch to Kramdown for RDoc formatting
* Support jRuby 1.8/1.9 and MRI 2.0.0 too
* Support for Rails 4.x
* Dropped support for Ruby 1.8.6
* Better generator & documentation for environment specific configuration (thanks @samullen)

### 1.0.8 / 2012-11-11 ###

* allow configuration per environment (thanks @samullen)

### 1.0.7 / 2012-07-09 ###

* Integrated RSpec helper (thanks @jstirk)

### 1.0.6 / 2012-04-13 ###

* Documentation fixes
* Don't sign requests when no secret is provided

### 1.0.5 / 2012-04-09 ###

* fix deprecation warning on Rails 3.2 by removing use of ActiveSupport::Memoizable

### 1.0.4 / 2012-02-23 ###

* Don't encode known callbacks to JSON

### 1.0.3 / 2011-11-15 ###

* Allow ERB in config files

### 1.0.2 / 2011-09-23 ###

* Fix default configuration template
* Bump dependency to transloadit gem to 1.0.2
* Allow duration to be configurable

### 1.0.1 / 2011-09-19 ###

* Use jQuery instead of $ to prevent problems with other libraries
* fixed "uninitialized constant Transloadit::Rails::ViewHelper"

### 1.0.0 / 2011-06-09 ###

* Fix View Helper
* Some optimizations for jQuery initialization
* Explicit including of the params decoder module instead of automatic magic
* Depend on railties, not Rails

### 0.9.2 / 2011-04-26 ###

* Automatically translate Transloadit API JSON

### 0.9.1 / 2011-04-19 ###

* Lazy-load configuration
* better error messages

### 0.9.0 / 2011-04-13 ###

* Initial release
