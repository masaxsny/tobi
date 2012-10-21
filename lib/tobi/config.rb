# coding: utf-8

module Tobi
  # アプリケーション設定情報の保持と設定値のチェック
  class Config
    # アプリケーション名(String)
    attr_reader :app_name
    # 各種設定(Hash)
    attr_reader :options

    # アプリケーション設定情報の作成とチェックを行う。
    #
    # app_name - アプリケーション名(Stirng)
    # opts - 各種設定(Hash)
    def initialize(app_name, opts = {})
      @app_name = app_name
      @options = merge_options(opts)
      check
    end

    private

    # 各種設定情報のデフォルト値と指定値をマージする。
    #
    # opts - 指定値(Hash)
    #
    # 戻り値: マージされた各種設定情報(Hash)
    def merge_options(opts)
      DEFAULT_OPTS.merge(opts)
    end

    # アプリケーション設定情報の値が正しいかチェックする。
    #
    # 戻り値: なし
    def check
      check_app_name(@app_name)
      @options.each {|k, v| check_opt_value(k, v)}
    end

    # アプリケーション名が不正であればプログラムを終了する。
    #
    # アプリケーション名(String)
    #
    # 戻り値: なし
    def check_app_name(str)
      unless /^[a-zA-Z]+/ =~ str
        msg = "Application name `#{str}` is invalid."
        msg << 'The heading charactar should specify the alphabet.'
        puts msg
        exit(0)
      end
    end

    # 各種設定の値が不正であればプログラムを終了する。
    #
    # key - 設定キー
    # value - 設定値
    #
    # 戻り値: なし
    def check_opt_value(key, value)
      return unless value
      unless OPT_VALUES[key].include?(value)
        puts "The Value `#{value}` set as the key `#{key}` is invalid."
        exit(0)
      end
    end
  end
end

