require "rbone/version"

module Rbone; end

LOW    = 0x00
HIGH   = 0x01

INPUT  = 0x00
OUTPUT = 0x01

GPIO0  = 0x00
GPIO1  = GPIO0 + 0x20
GPIO2  = GPIO1 + 0x20
GPIO3  = GPIO2 + 0x20

# Digital IO pins
P8_3   = GPIO1 + 0x06
P8_4   = GPIO1 + 0x07
P8_5   = GPIO1 + 0x02
P8_6   = GPIO1 + 0x03
P8_11  = GPIO1 + 0x0D
P8_12  = GPIO1 + 0x0C
P8_14  = GPIO0 + 0x1A
P8_15  = GPIO1 + 0x0F
P8_16  = GPIO1 + 0x0E
P8_17  = GPIO0 + 0x1B
P8_18  = GPIO2 + 0x01
P8_20  = GPIO1 + 0x1F
P8_21  = GPIO1 + 0x1E
P8_22  = GPIO1 + 0x05
P8_23  = GPIO1 + 0x04
P8_24  = GPIO1 + 0x01
P8_25  = GPIO1 + 0x00
P8_26  = GPIO1 + 0x1D
P8_27  = GPIO2 + 0x16
P8_28  = GPIO2 + 0x18
P8_29  = GPIO2 + 0x17
P8_30  = GPIO2 + 0x19
P8_39  = GPIO2 + 0x0C
P8_40  = GPIO2 + 0x0D
P8_41  = GPIO2 + 0x0A
P8_42  = GPIO2 + 0x0B
P8_43  = GPIO2 + 0x08
P8_44  = GPIO2 + 0x09
P8_45  = GPIO2 + 0x06
P8_46  = GPIO2 + 0x07
P9_12  = GPIO1 + 0x1C
P9_15  = GPIO1 + 0x10
P9_23  = GPIO1 + 0x11
P9_25  = GPIO3 + 0x15
P9_27  = GPIO3 + 0x13
P9_42  = GPIO0 + 0x07

USR0   = GPIO1 + 0x15
USR1   = GPIO1 + 0x16
USR2   = GPIO1 + 0x17
USR3   = GPIO1 + 0x18

# Analog input pins
P9_33  = 'ain4'
P9_35  = 'ain6'
P9_36  = 'ain5'
P9_37  = 'ain2'
P9_38  = 'ain3'
P9_39  = 'ain0'
P9_40  = 'ain1'

require "rbone/app"
