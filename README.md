# Colorcake

Find colors and generate palette. So you can show palette and search models by color

## Installation

Add this line to your application's Gemfile:

    gem 'colorcake'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install colorcake

## Usage
1. Run
    rails generate colorcake:install
to install initializer.
2. Add to your model include and method `image_path_for_color_generator`
model should have character field `palette`

      class Photo
        include Colorable

        def image_path_for_color_generator
          image.big.path
        end
      end

## Testing
Put images like 0.jpg .. 16.jpg in fixtures and run `rake test` then you should see html files with generated colors and photos

## TODO:

1. Migration files
2. View examples
3. Similarity search
4. Color generation speed optimization
5. Search speed optimization

## Contributing

`ruby-prof test/functionals/image_generation_test.rb`

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
