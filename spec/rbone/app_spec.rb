require 'spec_helper'
require 'rbone/app'

describe Rbone::App do
  before :each do
    @app = Rbone::App.new

    FileUtils.mkdir_p('/sys/class/gpio')
    FileUtils.touch(%w(export unexport))

    # mock USR leds
    %w(0 1 2 3).map{ |n| "/sys/devices/platform/leds-gpio/leds/beaglebone::usr#{n}" }.each do |base_dir|
      FileUtils.mkdir_p(base_dir)
      FileUtils.touch(%w(brightness max_brightness trigger uevent).map{ |f| "#{base_dir}/#{f}" })
    end

    # mock pin mux files
    FileUtils.mkdir_p("/sys/kernel/debug/omap_mux")
    Rbone::App::PIN_MUX_REF.values.each do |pin_mux_file|
      FileUtils.touch("/sys/kernel/debug/omap_mux/%s" % [pin_mux_file])
    end
  end

  after :each do
    FileUtils.rm_rf('/sys')
  end

  def mock_export(pin)
    base_dir = "/sys/class/gpio/gpio%s" % [pin]
    FileUtils.mkdir_p(base_dir)
    FileUtils.touch(%w(active_low direction edge uevent value).map{ |f| "#{base_dir}/#{f}" })
  end

  def read_value(file)
    f = File.open(file, 'r')
    value = f.read
    f.close
    value
  end

  describe '#pinMode' do
    it "writes the appropriate value to the export file" do
      mock_export(P8_3)
      @app.pinMode(P8_3, OUTPUT).should be_true
      read_value("/sys/class/gpio/export").should == "38"
    end

    it "adds the exported pin to the list" do
      mock_export(P8_3)
      @app.pinMode(P8_3, OUTPUT).should be_true
      @app.instance_variable_get(:@exported_pins).include?(38).should be_true
    end

    it "writes the appropriate value to the pin's direction file" do
      mock_export(P8_3)
      @app.pinMode(P8_3, INPUT).should be_true
      read_value("/sys/class/gpio/gpio38/direction").should == 'in'
    end

    it "raises an exception if the pin is invalid" do
      lambda{ @app.pinMode(9001, INPUT) }.should raise_error(Rbone::PinRefError)
    end
  end

  describe '#digitalWrite' do
    it "sets the GPIO pin to HIGH" do
      mock_export(P8_3)
      @app.digitalWrite(P8_3, HIGH).should be_true
      read_value("/sys/class/gpio/gpio38/value").should == '1'
    end

    it "sets the GPIO pin to LOW" do
      mock_export(P8_3)
      @app.digitalWrite(P8_3, LOW).should be_true
      read_value("/sys/class/gpio/gpio38/value").should == '0'
    end

    it "sets the USR LED to HIGH" do
      @app.digitalWrite(USR1, HIGH).should be_true
      read_value("/sys/devices/platform/leds-gpio/leds/beaglebone::usr1/brightness").should == '1'
    end

    it "sets the USR LED to LOW" do
      @app.digitalWrite(USR1, LOW).should be_true
      read_value("/sys/devices/platform/leds-gpio/leds/beaglebone::usr1/brightness").should == '0'
    end

    it "returns false if an invalid value is supplied" do
      @app.digitalWrite(USR0, 3).should be_false
    end
  end
end
