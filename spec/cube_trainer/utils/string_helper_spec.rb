# frozen_string_literal: true

require 'twisty_puzzles/utils'

describe Utils::StringHelper do
  include described_class

  it 'transforms to camel case correctly' do
    expect(camel_case_to_snake_case('TheOldShitIsDumb')).to eq('the_old_shit_is_dumb')
    expect(camel_case_to_snake_case('MSlice')).to eq('m_slice')
    expect(camel_case_to_snake_case('OOOMyGod')).to eq('ooo_my_god')
    expect(camel_case_to_snake_case('this2is3The3Shit')).to eq('this2is3_the3_shit')
  end
end
