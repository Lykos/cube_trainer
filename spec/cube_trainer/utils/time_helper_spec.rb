# frozen_string_literal: true

require 'cube_trainer/utils/time_helper'

describe Utils::TimeHelper do
  include described_class

  it 'computes the days between two times correctly' do
    expect(days_between(Time.zone.at(1_584_952_243), Time.zone.at(1_584_952_243) + 24 * 60 * 60)).to eq(1)
  end

  it 'computes the days between two times on the same day correctly' do
    expect(days_between(Time.zone.at(1_584_952_243), Time.zone.at(1_584_952_243) + 60 * 60)).to eq(0)
  end

  it 'rounds down the days between two times' do
    expect(days_between(Time.zone.at(1_584_921_600), Time.zone.at(1_584_921_600 + 5 * 24 * 60 * 60 - 1))).to eq(4)
  end
end
