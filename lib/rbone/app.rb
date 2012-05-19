require 'rbone'

module Rbone
  class PinRefError < StandardError; end

  class App

    DIGITAL_PINS = [
      P8_3,  P8_4,  P8_5,  P8_6,  P8_11, P8_12,
      P8_14, P8_15, P8_16, P8_17, P8_18, P8_20,
      P8_21, P8_22, P8_23, P8_24, P8_25, P8_26,
      P8_27, P8_28, P8_29, P8_30, P8_39, P8_40,
      P8_41, P8_42, P8_43, P8_44, P8_45, P8_46,
      P9_12, P9_15, P9_23, P9_25, P9_27, P9_42,
    ].freeze

    USR_LEDS = [
      USR0, USR1, USR2, USR3
    ].freeze

    ANALOG_PINS = [
      P9_33, P9_35, P9_36, P9_37, P9_38, P9_39, P9_40
    ].freeze

    def initialize
      @exported_pins = []
      if block_given?
        yield(self)
      end
    end

    def setup(&block)
      @setup = block
    end

    def loop(delay=nil, &block)
      @loop = block
      self.run unless delay == :delay
    end

    def run
      self.instance_eval(&@setup)
      self.instance_eval(&@loop) while true
    rescue Interrupt => e
      cleanup!
    rescue Exception => e
      cleanup!
      $stderr.puts e
    end

    def pinMode(pin, direction)
      if DIGITAL_PINS.include?(pin)
        File.open('/sys/class/gpio/export', 'w') do |f|
          f.write("%s" % [pin])
        end

        filename = '/sys/class/gpio/gpio%d/direction' % [pin]
        File.open(filename, 'w') do |f|
          if direction == INPUT
            f.write("in")
          else
            f.write("out")
          end
        end

        @exported_pins.push(pin)
      else
        raise PinRefError, "#{pin} is not a valid digital pin reference"
      end
    end

    def digitalWrite(pin, value)
      if DIGITAL_PINS.include?(pin)
        filename = '/sys/class/gpio/gpio%d/value' % [pin]
      elsif USR_LEDS.include?(pin)
        led_id = pin - USR0
        filename = '/sys/devices/platform/leds-gpio/leds/beaglebone::usr%s/brightness' % [led_id]
      else
        raise PinRefError, "#{pin} is not a valid digital pin reference"
      end

      if value == HIGH || value == LOW
        File.open(filename, 'w') do |f|
         f.write("%s" % [value])
        end
        return true
      else
        return false
      end
    end

    def digitalRead(pin)
      if DIGITAL_PINS.include?(pin)
        filename = '/sys/class/gpio/gpio%d/value' % [pin]
        value = open(filename).read
        case value.chomp
        when '0' then LOW
        when '1' then HIGH
        else nil
        end
      else
        raise PinRefError, "#{pin} is not a valid digital pin reference"
      end
    end

    def analogRead(pin)
      if ANALOG_PINS.include?(pin)
        filename = "/sys/devices/platform/tsc/#{pin}"
        File.open(filename, 'r') do |f|
          return
        end
      else
        raise PinRefError, "#{pin} is not a valid analog pin reference"
      end
    end

    def delay(ms)
      sleep(ms.to_f / 1000.0)
    end

    def cleanup!
    end

    def pinUnexport(pin)
    end
  end
end
