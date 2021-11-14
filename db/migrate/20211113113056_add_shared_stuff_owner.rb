=begin
Simple models to make this migration work:

class User < ActiveRecord::Base
  has_one :color_scheme
  has_one :letter_scheme_scheme
end

class ColorScheme < ActiveRecord::Base
  belongs_to :user
end

class LetterSchemeMapping < ActiveRecord::Base
end

class LetterScheme < ActiveRecord::Base
  belongs_to :user
  has_many :letter_scheme_mapping
end
=end

SPEFFZ_MAPPINGS = {
  'Corner:UFL' => 'd',
  'Corner:URF' => 'c',
  'Corner:ULB' => 'a',
  'Corner:UBR' => 'b',
  'Corner:FUR' => 'j',
  'Corner:FRD' => 'k',
  'Corner:FLU' => 'i',
  'Corner:FDL' => 'l',
  'Corner:RUB' => 'n',
  'Corner:RFU' => 'm',
  'Corner:RBD' => 'o',
  'Corner:RDF' => 'p',
  'Corner:LUF' => 'f',
  'Corner:LFD' => 'g',
  'Corner:LBU' => 'e',
  'Corner:LDB' => 'h',
  'Corner:BUL' => 'r',
  'Corner:BRU' => 'q',
  'Corner:BLD' => 's',
  'Corner:BDR' => 't',
  'Corner:DFR' => 'v',
  'Corner:DRB' => 'w',
  'Corner:DLF' => 'u',
  'Corner:DBL' => 'x',
  'Edge:UF' => 'c',
  'Edge:UR' => 'b',
  'Edge:UL' => 'd',
  'Edge:UB' => 'a',
  'Edge:FU' => 'i',
  'Edge:FR' => 'j',
  'Edge:FL' => 'l',
  'Edge:FD' => 'k',
  'Edge:RU' => 'm',
  'Edge:RF' => 'p',
  'Edge:RB' => 'n',
  'Edge:RD' => 'o',
  'Edge:LU' => 'e',
  'Edge:LF' => 'f',
  'Edge:LB' => 'h',
  'Edge:LD' => 'g',
  'Edge:BU' => 'q',
  'Edge:BR' => 't',
  'Edge:BL' => 'r',
  'Edge:BD' => 's',
  'Edge:DF' => 'u',
  'Edge:DR' => 'v',
  'Edge:DL' => 'x',
  'Edge:DB' => 'w',
  'XCenter:Ufl' => 'd',
  'XCenter:Urf' => 'c',
  'XCenter:Ulb' => 'a',
  'XCenter:Ubr' => 'b',
  'XCenter:Fur' => 'j',
  'XCenter:Frd' => 'k',
  'XCenter:Flu' => 'i',
  'XCenter:Fdl' => 'l',
  'XCenter:Rub' => 'n',
  'XCenter:Rfu' => 'm',
  'XCenter:Rbd' => 'o',
  'XCenter:Rdf' => 'p',
  'XCenter:Luf' => 'f',
  'XCenter:Lfd' => 'g',
  'XCenter:Lbu' => 'e',
  'XCenter:Ldb' => 'h',
  'XCenter:Bul' => 'r',
  'XCenter:Bru' => 'q',
  'XCenter:Bld' => 's',
  'XCenter:Bdr' => 't',
  'XCenter:Dfr' => 'v',
  'XCenter:Drb' => 'w',
  'XCenter:Dlf' => 'u',
  'XCenter:Dbl' => 'x',
  'TCenter:Uf' => 'c',
  'TCenter:Ur' => 'b',
  'TCenter:Ul' => 'd',
  'TCenter:Ub' => 'a',
  'TCenter:Fu' => 'i',
  'TCenter:Fr' => 'j',
  'TCenter:Fl' => 'l',
  'TCenter:Fd' => 'k',
  'TCenter:Ru' => 'm',
  'TCenter:Rf' => 'p',
  'TCenter:Rb' => 'n',
  'TCenter:Rd' => 'o',
  'TCenter:Lu' => 'e',
  'TCenter:Lf' => 'f',
  'TCenter:Lb' => 'h',
  'TCenter:Ld' => 'g',
  'TCenter:Bu' => 'q',
  'TCenter:Br' => 't',
  'TCenter:Bl' => 'r',
  'TCenter:Bd' => 's',
  'TCenter:Df' => 'u',
  'TCenter:Dr' => 'v',
  'TCenter:Dl' => 'x',
  'TCenter:Db' => 'w',
  'Midge:UF' => 'a',
  'Midge:UR' => 'b',
  'Midge:UL' => 'c',
  'Midge:UB' => 'd',
  'Midge:FU' => 'e',
  'Midge:FR' => 'f',
  'Midge:FL' => 'g',
  'Midge:FD' => 'h',
  'Midge:RU' => 'i',
  'Midge:RF' => 'j',
  'Midge:RB' => 'k',
  'Midge:RD' => 'l',
  'Midge:LU' => 'm',
  'Midge:LF' => 'n',
  'Midge:LB' => 'o',
  'Midge:LD' => 'p',
  'Midge:BU' => 'q',
  'Midge:BR' => 'r',
  'Midge:BL' => 's',
  'Midge:BD' => 't',
  'Midge:DF' => 'u',
  'Midge:DR' => 'v',
  'Midge:DL' => 'w',
  'Midge:DB' => 'x',
  'Wing:UFl' => 'i',
  'Wing:URf' => 'm',
  'Wing:ULb' => 'e',
  'Wing:UBr' => 'q',
  'Wing:FUr' => 'c',
  'Wing:FRd' => 'p',
  'Wing:FLu' => 'f',
  'Wing:FDl' => 'u',
  'Wing:RUb' => 'i',
  'Wing:RFu' => 'j',
  'Wing:RBd' => 't',
  'Wing:RDf' => 'v',
  'Wing:LUf' => 'd',
  'Wing:LFd' => 'l',
  'Wing:LBu' => 'r',
  'Wing:LDb' => 'x',
  'Wing:BUl' => 'a',
  'Wing:BRu' => 'n',
  'Wing:BLd' => 'h',
  'Wing:BDr' => 'w',
  'Wing:DFr' => 'k',
  'Wing:DRb' => 'o',
  'Wing:DLf' => 'g',
  'Wing:DBl' => 's'
}

class AddSharedStuffOwner < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
  end

  class ColorScheme < ApplicationRecord
  end

  class LetterScheme < ApplicationRecord
  end

  def change
    reversible do |change|
      change.up do
        user = User.create!(
          name: 'shared_stuff_owner',
          email: 'shared_stuff_owner@cubetrainer.org',
          # We should never log in as this user, so we might just choose
          # something arbitrary
          password: SecureRandom.hex(8)
        )

        wca_color_scheme = ColorScheme.create!(
          user: user,
          u: :white,
          f: :green,
          r: :red,
          l: :orange,
          b: :blue,
          d: :yellow
        )

        speffz_scheme = LetterScheme.create!(user: user)
        SPEFFZ_MAPPINGS.each { |part, letter| speffz_scheme.mappings.create!(part: part, letter: letter) }
      end

      change.down do
        User.find_by!(name: 'shared_stuff_owner').destroy
      end
    end
  end
end
