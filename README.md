# Rbone

[![Build Status](https://secure.travis-ci.org/majormajors/rbone.png)](http://travis-ci.org/majormajors/rbone)

Rbone makes it easy to write Arduino-style applications for your BeagleBone in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'rbone'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbone

## Usage

Blink an LED!

```ruby
#!/usr/bin/env ruby

require 'rbone'

Rbone::App.new do |app|
  app.setup do
    pinMode(P8_3, OUTPUT)
  end

  app.loop do
    digitalWrite(P8_3, HIGH)
    delay(1000)
    digitalWrite(P8_3, LOW)
    delay(1000)
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
