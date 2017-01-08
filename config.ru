# frozen_string_literal: true
require 'faye'
require './init.rb'


use Faye::RackAdapter, :mount => '/faye', :timeout => 2000
run DevRankAPI
