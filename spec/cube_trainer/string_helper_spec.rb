require 'cube_trainer/string_helper'

include CubeTrainer
include StringHelper

describe StringHelper do

  it 'should transform to camel case correctly' do
    expect(camel_case_to_snake_case('TheOldShitIsDumb')).to be == 'the_old_shit_is_dumb'
    expect(camel_case_to_snake_case('MSlice')).to be == 'm_slice'
    expect(camel_case_to_snake_case('OOOMyGod')).to be == 'ooo_my_god'
    expect(camel_case_to_snake_case('this2is3The3Shit')).to be == 'this2is3_the3_shit'
  end
  
end
