# Hamlbars

[Hamlbars](https://github.com/jamesotron/hamlbars) is a Ruby gem which allows you to easily generate [Handlebar](http://handlebarsjs.com) templates using [Haml](http://www.haml-lang.com).

# Attribute bindings

You can easily add attribute bindings by adding a `:bind` hash to the tag attributes, like so:

    %div{ :class => 'widget', :bind => { :title => 'App.widgetController.title' }

Which will generate the following output:

    <div class="widget" {{bindAttr title="App.widgetController.title"}}></div>

# Handlebar helper

You can use the `handlebars` helper (or just `hb` for short) to generate both Handlebar blocks and expressions.

## Expressions

Generating Handlebars expressions is as simple as using the `handlebars` helper and providing the expression as a string argument:

    = hb 'App.widgetController.title'

which will will generate:

    {{App.widgetController.title}}

## Blocks

Whereas passing a block to the `handlebars` helper will create a Handlebars block expression:

    %ul.authors
    = hb 'each authors' do
      %li<
	= succeed ',' do
	  = hb 'lastName'
	= hb 'firstName'

will result in the following markup:

    <ul class="authors">
       {{#each authors}}
         <li>{{lastName}}, {{firstName}}</li>
       {{/each}}
    </ul>

# Configuration options

`hamlbars` has two configuration options, which pertain to the generated JavaScript:

    Hamlbars::Template.template_destination    # default 'Handlebars.templates'
    Hamlbars::Template.template_compiler       # default 'Handlebars.compile'
    Hamlbars::Template.template_partial_method # default 'Handlebars.registerPartial'

These settings will work find by default if you are using Handlebars as a standalone JavaScript library, however if you ware using something that embeds Handlebars within it e.g. [Ember.js](http://www.emberjs.com) then you'll want to change these to:

    Hamlbars::Template.template_destination = 'Ember.TEMPLATES'
    Hamlbars::Template.template_compiler = 'Ember.Handlebars.compile'
    Hamlbars::Template.template_partial_method = 'Ember.Handlebars.registerPartial'

The good news is that if you're using the [emberjs-rails](http://www.rubygems.org/gems/emberjs-rails) gem then it will automatically detect hamlbars and change it for you. Magic!

# Asset pipeline

Hamlbars is specifically designed for use with Rails 3.1's asset pipeline.  Simply create templates ending in `.js.hamlbars` (or `.js.hbs`) and Sprockets will know what to do.

# License and Copyright.

Hamlbars is Copyright &copy; 2012 [Sociable Limited](http://sociable.co.nz/) and licensed under the terms of the MIT License.
