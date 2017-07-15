# Blinder

This is a work in progress! Of course, what isn't? Essentially, I wanna use this textbook Rails app
to handle CFP collections for conferences. At some point, I'll have to write a _real_ README.

## Get started

* Run `bin/setup`
* Run `foreman start`
* Visit `http://localhost:5000/`

Yes, this is tailored for SCRC 2014. Take a look at `db/seeds.rb` and customize that for your needs, then run `bin/setup` again to reload the data.

## Running the tests

All the tests are integration tests implemented in Cucumber.

* Run `foreman start`

* To run tests for only one feature, from the project root, run `cucumber features/<featurename>.feature -r features`

* To run tests for all features, from the project root, run `cucumber -r features`

For the time being, Cucumber is configured to launch whatever the default browser is for your system.
If your default browser happens to be Chrome, launching Cucumber will not work for you unless you install Chromedriver.

Information on the installation of Chromedriver may be found here:  https://code.google.com/p/selenium/wiki/ChromeDriver

## Oauth Setup

[https://github.com/jnf/blinder/wiki/GitHub-Oauth](https://github.com/jnf/blinder/wiki/GitHub-Oauth)

## Generating a .env for use with Foreman

Use Foreman to start the web server and automatically load the .env variables by using `foreman start`.

## Deploying to heroku
