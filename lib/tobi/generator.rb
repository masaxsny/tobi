# coding: utf-8
require 'erb'

module Tobi
  # アプリケーション設定情報からアプリケーションのソースコードを生成する。
  class Generator
    # アプリケーション名(String)
    attr_reader :app_name
    # 各種設定情報(Hash)
    attr_reader :config
    # 埋め込みソースコード(Hash)
    attr_reader :src

    # アプリケーション設定情報の読み込みと、
    # 埋め込みソースコードのデフォルト設定をする。
    #
    # cfg - アプリケーション設定情報(Tobi::Config)
    def initialize(cfg)
      @app_name = cfg.app_name
      @app_path = File.join(Dir.pwd, @app_name)
      @config = cfg.options
      @src = DEFAULT_SRC.dup
    end

    # アプリケーションのソースコードを生成する。
    #
    # 戻り値: なし
    def generate
      set_source_code
      begin
        output_app_files
      rescue => e
        msg = "Output error: #{e.message}"
        STDERR.puts msg
        exit(1)
      end
    end

    private

    # 埋め込みソースコードを設定する。
    #
    # 戻り値: なし
    def set_source_code
      # app.rb
      @src[:base_require] = @config[:ModularStyle] ? 'sinatra/base' : 'sinatra'
      @src[:app_run] = if @config[:Rackup] 
                         nil
                       else
                         "#{@app_name.capitalize}::App.run! if $0 == __FILE__"
                       end

      # config.ru
      if @config[:Rackup]
        @src[:cnf_run] = if @config[:ModularStyle] 
                           "run #{@app_name.capitalize}::App" 
                         else
                           'run Sinatra::Application'
                         end
      end

      # ビューテンプレート関連
      vt = @config[:ViewTemplate]
      @src[:view_template_require] = "require '#{vt}'"
      @src[:view_template] = vt
      @src[:gems] << vt unless vt == 'erb'
      if %w(liquid radius).include?(vt)
        @src[:locals] = ", locals: { app_name: '#{@app_name}', ua: @ua }"
      end

      # CSSテンプレート関連
      ct = @config[:CssTemplate]
      if ct == 'scss'
        @src[:css_template_require] = "require 'sass'"
        @src[:gems] << 'sass'
      else
        @src[:css_template_require] = "require '#{ct}'"
        @src[:gems] << ct
      end
      @src[:css_template] = ct
      @src[:gems] << 'therubyracer' if ct == "less"

      # テストフレームワーク関連
      if @config[:TestFramework]
        tf = @config[:TestFramework]
        @src[:test_framework] = tf
        @src[:gems] << tf if tf != 'testunit'
        @src[:test_run] = if @config[:ModularStyle]
                            "#{@app_name.capitalize}::App"
                          else
                            'Sinatra::Application'
                          end
      end
    end

    # アプリケーションのファイルを出力する。
    #
    # 戻り値: なし
    def output_app_files
      # アプリケーションのルートディレクトリ
      check_root_dir
      Dir.mkdir(@app_path) unless File.exists?(@app_path)

      # app.rb
      buf = read_template_file(@config[:ModularStyle] ? "mod_app.rb" : "app.rb")
      write_file(buf, "app.rb")

      # views/index.*
      dir = "views"
      ext = @config[:ViewTemplate] == "markaby" ? "mab" : @config[:ViewTemplate]
      fn = "index.#{ext}"
      mkdir_and_output(dir, fn)

      # views/style.*
      dir = "views"
      fn = "style.#{@config[:CssTemplate]}"
      mkdir_and_output(dir, fn)

      # Gemfile
      unless @src[:gems].empty?
        buf = read_template_file("Gemfile")
        write_file(buf, "Gemfile")
      end

      # config.ru
      if @config[:Rackup]
        buf = read_template_file("config.ru")
        write_file(buf, "config.ru")
      end

      # app_test.rb, app_spec.rb
      if @src[:test_framework] == "testunit"
        dir = "test"
        fn = "app_test.rb"
        mkdir_and_output(dir, fn)
      elsif @src[:test_framework] == "rspec"
        dir = "spec"
        fn = "app_spec.rb"
        mkdir_and_output(dir, fn)
      end
    end

    # 指定されたディレクトリが存在したら警告表示し処理を続けるか確認する。
    #
    # 戻り値: なし
    def check_root_dir
      if File.exists?(@app_path)
        puts "Directory `#{@app_path}` already exists."
        str = ''
        loop do
          print 'Is processing continued?(y/n): '
          str = STDIN.getc.downcase
          break if str == 'y' || str == 'n'
        end
        exit(0) if str == 'n'
      end
    end

    # ディレクトリの生成とファイル入出力
    #
    # d - ディレクトリ
    # f - ファイル名
    #
    # 戻り値: なし
    def mkdir_and_output(d, f)
      unless File.exists?(File.join("#{@app_path}", "#{d}"))
        Dir.mkdir(File.join("#{@app_path}", "#{d}"))
      end
      buf = read_template_file(File.join("#{d}", "#{f}"))
      write_file(buf, File.join("#{d}", "#{f}"))
    end

    # テンプレートerbファイルを読み込み、結果を返す。
    #
    # fname - erbファイルパス
    #
    # 戻り値: 指定されたerbファイルの変換結果
    def read_template_file(fname)
      fpath = File.join(File.dirname(__FILE__), 'templates', "#{fname}")
      erb = ERB.new(File.read(fpath), nil, '-')
      erb.result(binding)
    end

    # 指定したデータを指定されたファイルへ出力する。
    #
    # data - データ
    # fname - 出力ファイルパス
    #
    # 戻り値: なし
    def write_file(data, fname)
      File.open(File.join("#{@app_path}", "#{fname}"), "w") do |f|
        f.write(data)
      end
    end
  end
end

