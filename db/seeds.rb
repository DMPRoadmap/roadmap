#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true


load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb")) # load seed file based on different environment
