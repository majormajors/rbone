require 'spec_helper'
require 'rbone/app'

describe Rbone::App do
  before :all do
    FileUtils.mkdir_p('/sys/class/gpio')

    # mock USR leds
    %w(0 1 2 3).map{ |n| "/sys/devices/platform/leds-gpio/leds/beaglebone::usr#{n}" }.each do |base_dir|
      FileUtils.mkdir_p(base_dir)
      FileUtils.touch(%w(brightness max_brightness trigger uevent).map{ |f| "#{base_dir}/#{f}" })
    end
  end

  before :each do
    @app = Rbone::App.new
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
