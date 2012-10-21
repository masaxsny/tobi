require 'tobi/version'
require 'tobi/config'
require 'tobi/generator'

module Tobi
  # オプションのデフォルト値
  DEFAULT_OPTS = { ModularStyle:  false,
                   Rackup:        false,
                   ViewTemplate:  'haml',
                   CssTemplate:   'scss',
                   TestFramework: nil }

  # オプションのとるべき値
  OPT_VALUES = { ModularStyle:  [false, true],
                 Rackup:        [false, true],
                 ViewTemplate:  %w(haml erb erubis liquid radius markaby slim),
                 CssTemplate:   %w(sass scss less),
                 TestFramework: %w(testunit rspec) }

  # ソースコード情報のデフォルト値
  DEFAULT_SRC = { gems: [],
                  rackup_run: nil,
                  app_run: nil,
                  locals: nil }

  # 配列の値を英文の列挙表現にして返す。
  #
  # enum - 配列(Array)
  #
  # 戻り値: 列挙表現(String)
  def self.enum_in_sentence(enum)
    str = ''
    len = enum.length
    enum.each_with_index do |v, i|
      if i > 0
        link = i == len - 1 ? ' and ' : ', '
        str << "#{link}#{v.to_s}"
      else
        str << v.to_s
      end
    end
    return str
  end
end

