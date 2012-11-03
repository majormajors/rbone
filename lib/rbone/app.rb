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

    PIN_MUX_REF = {
      P8_3  => "gpmc_ad6",
      P8_4  => "gpmc_ad7",
      P8_5  => "gpmc_ad2",
      P8_6  => "gpmc_ad3",
      #P8_7  => "gpmc_advn_ale",
      #P8_8  => "gpmc_oen_ren",
      #P8_9  => "gpmc_ben0_cle",
      #P8_10 => "gpmc_wen",
      P8_11 => "gpmc_ad13",
      P8_12 => "gpmc_ad12",
      #P8_13 => "gpmc_ad9",
      P8_14 => "gpmc_ad10",
      P8_15 => "gpmc_ad15",
      P8_16 => "gpmc_ad14",
      P8_17 => "gpmc_ad11",
      P8_18 => "gpmc_clk",
      #P8_19 => "gpmc_ad8",
      P8_20 => "gpmc_csn2",
      P8_21 => "gpmc_csn1",
      P8_22 => "gpmc_ad5",
      P8_23 => "gpmc_ad4",
      P8_24 => "gpmc_ad1",
      P8_25 => "gpmc_ad0",
      P8_26 => "gpmc_csn0",
      P8_27 => "lcd_vsync",
      P8_28 => "lcd_pclk",
      P8_29 => "lcd_hsync",
      P8_30 => "lcd_ac_bias_en",
      #P8_31 => "lcd_data14",
      #P8_32 => "lcd_data15",
      #P8_33 => "lcd_data13",
      #P8_34 => "lcd_data11",
      #P8_35 => "lcd_data12",
      #P8_36 => "lcd_data10",
      #P8_37 => "lcd_data8",
      #P8_38 => "lcd_data9",
      P8_39 => "lcd_data6",
      P8_40 => "lcd_data7",
      P8_41 => "lcd_data4",
      P8_42 => "lcd_data5",
      P8_43 => "lcd_data2",
      P8_44 => "lcd_data3",
      P8_45 => "lcd_data0",
      P8_46 => "lcd_data1",
      #P9_11 => "gpmc_wait0",
      P9_12 => "gpmc_ben1",
      #P9_13 => "gpmc_wpn",
      #P9_14 => "gpmc_a2",
      P9_15 => "gpmc_a0",
      #P9_16 => "gpmc_a3",
      #P9_17 => "spi0_cs0",
      #P9_18 => "spi0_d1",
      #P9_19 => "uart1_rtsn",
      #P9_20 => "uart1_ctsn",
      #P9_21 => "spi0_d0",
      #P9_22 => "spi0_sclk",
      P9_23 => "gpmc_a1",
      #P9_24 => "uart1_txd",
      P9_25 => "mcasp0_ahclkx",
      #P9_26 => "uart1_rxd",
      P9_27 => "mcasp0_fsr",
      #P9_28 => "mcasp0_ahclkr",
      #P9_29 => "mcasp0_fsx",
      #P9_30 => "mcasp0_axr0",
      #P9_31 => "mcasp0_ahclkx",
      #P9_41 => "xdma_event_intr0",
      P9_42 => "ecap0_in_pwm0_out"
    }.freeze

    USR_LEDS = [
      USR0, USR1, USR2, USR3
    ].freeze

    ANALOG_PINS = [
      P9_33, P9_35, P9_36, P9_37, P9_38, P9_39, P9_40
    ].freeze

    def initialize
      @exported_pins = []
      @start_time = Time.now
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
          f.write(pin.to_s)
        end

        muxfile = File.open("/sys/kernel/debug/omap_mux/%s" % [PIN_MUX_REF[pin]], 'w')

        filename = '/sys/class/gpio/gpio%d/direction' % [pin]
        File.open(filename, 'w') do |f|
          if direction == INPUT
            f.write("in")
            muxfile.write("2F")
          else
            f.write("out")
            muxfile.write("7")
          end
        end

        muxfile.close

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
          f.write(value.to_s)
        end
        return true
      else
        return false
      end
    end

    def digitalRead(pin)
      if DIGITAL_PINS.include?(pin)
        filename = '/sys/class/gpio/gpio%d/value' % [pin]
        File.open(filename, 'r') do |f|
          value = f.read.chomp
        end
        case value
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
          return f.read.to_i
        end
      else
        raise PinRefError, "#{pin} is not a valid analog pin reference"
      end
    end

    def delay(ms)
      sleep(ms.to_f / 1000.0)
    end

    def delayMicroseconds(ms)
      sleep(ms.to_f / 1_000_000)
    end

    def millis
      (Time.now.to_i - @start_time.to_i) * 1000
    end

    def micros
      (Time.now.to_i - @start_time.to_i) * 1_000_000
    end

    def map(x, a1, a2, b1, b2)
      b1 + (x - a1) * (b2 - b1) / (a2 - a1)
    end

    def cleanup!
      f = File.open('/sys/class/gpio/unexport', 'w')
      while pin = @exported_pins.pop
        f.write(pin.to_s)
        f.flush
      end
      f.close
    end
  end
end
