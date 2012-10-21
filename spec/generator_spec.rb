# coding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tobi'

APP_NAME = 'Sample'

shared_examples_for 'view template' do |v|
  cfg = Tobi::Config.new(APP_NAME, {ViewTemplate: v})
  let(:gen){ Tobi::Generator.new(cfg) }

  before do
    gen.instance_eval('@src[:gems]').clear
    gen.generate 
  end

  describe 'src[:view_template_require]' do
    context "は`require '#{v}'`であること" do
      it { gen.src[:view_template_require].should eq "require '#{v}'" }
    end
  end

  describe 'src[:view_template]' do
    context "は`#{v}`であること" do
      it { gen.src[:view_template].should eq v }
    end
  end

  if v == 'erb'
    describe 'src[:gems]' do
      context "は`#{v}`が含まれていないこと" do
        it { gen.src[:gems].should_not include v }
      end
    end
  else
    describe 'src[:gems]' do
      context "は`#{v}`が含まれていること" do
        it { gen.src[:gems].should include v }
      end
    end
  end
end

shared_examples_for 'css template' do |v|
  cfg = Tobi::Config.new(APP_NAME, {CssTemplate: v})
  let(:gen){ Tobi::Generator.new(cfg) }
  before do
    gen.instance_eval('@src[:gems]').clear
    gen.generate 
  end

  describe 'src[:css_template_require]' do
    if v == 'scss'
      context "は`require 'sass'`であること" do
        it { gen.src[:css_template_require].should eq "require 'sass'" }
      end
    else
      context "は`require '#{v}'`であること" do
        it { gen.src[:css_template_require].should eq "require '#{v}'" }
      end
    end
  end

  describe 'src[:css_template]' do
    context "は`#{v}`であること" do
      it { gen.src[:css_template].should eq v }
    end
  end

  describe 'src[:gems]' do
    if v == 'scss'
      context "は`sass`が含まれていること" do
        it { gen.src[:gems].should include 'sass' }
      end
    else
      context "は#{v}が含まれていること" do
        it { gen.src[:gems].should include v }
        if v == 'less'
          context "は'therubyracer'が含まれていること" do
            it { gen.src[:gems].should include 'therubyracer' }
          end
        end
      end
    end
  end
end

shared_examples_for 'test framework' do |v, m|
  cfg = Tobi::Config.new(APP_NAME, {TestFramework: v, ModularStyle: m})
  let(:gen){ Tobi::Generator.new(cfg) }
  before do
    gen.instance_eval('@src[:gems]').clear
    gen.generate 
  end

  describe 'src[:test_framework]' do
    context "は`#{v}`であること" do
      it { gen.src[:test_framework].should eq v }
    end
  end

  describe 'src[:gems]' do
    if v != 'testunit'
      context "は#{v}が含まれていること" do
        it { gen.src[:gems].should include v }
      end
    end
  end

  describe 'src[:test_run]' do
    if m
      context "は`#{APP_NAME}::App`であること" do
        it { gen.src[:test_run].should eq "#{gen.app_name}::App" }
      end
    else
      context 'は`Sinatra::Application`であること' do
        it { gen.src[:test_run].should eq 'Sinatra::Application' }
      end
    end
  end
end

describe Tobi::Generator do
  context 'ModularStyleがfalseのとき' do
    cfg = Tobi::Config.new(APP_NAME, {ModularStyle: false})
    let(:gen){ Tobi::Generator.new(cfg) }
    before { gen.generate }

    describe 'src[:base_require]' do
      context 'は`sinatra`であること' do
        it { gen.src[:base_require].should eq 'sinatra' }
      end
    end
  end

  context 'ModularStyleがtrueのとき' do
    cfg = Tobi::Config.new(APP_NAME, {ModularStyle: true})
    let(:gen){ Tobi::Generator.new(cfg) }
    before { gen.generate }

    describe 'src[:base_require]' do
      context 'は`sinatra/base`であること' do
        it { gen.src[:base_require].should eq 'sinatra/base' }
      end
    end
  end

  context 'Rackupがfalseのとき' do
    cfg = Tobi::Config.new(APP_NAME, {Rackup: false})
    let(:gen){ Tobi::Generator.new(cfg) }
    before { gen.generate }

    describe 'src[:cnf_run]' do
      context 'は`nil`であること' do
        it { gen.src[:cnf_run].should eq nil }
      end
    end

    describe 'src[:app_run]' do
      context "は`???::App.run! if $0 == __FILE__`であること" do
        it { gen.src[:app_run].should eq "#{gen.app_name}::App.run! if $0 == __FILE__" }
      end
    end
  end

  context 'Rackupがtrue' do
    context 'かつModularStyleがfalseのとき' do
      cfg = Tobi::Config.new(APP_NAME, {Rackup: true, ModularStyle: false})
      let(:gen){ Tobi::Generator.new(cfg) }
      before { gen.generate }

      describe 'src[:cnf_run]' do
        context 'は`run Sinatra::Application`であること' do
          it { gen.src[:cnf_run].should eq 'run Sinatra::Application' }
        end
      end

      describe 'src[:app_run]' do
        context "は`nil`であること" do
          it { gen.src[:app_run].should eq nil }
        end
      end
    end

    context 'かつModularStyleがtrueのとき' do
      cfg = Tobi::Config.new(APP_NAME, {Rackup: true, ModularStyle: true})
      let(:gen){ Tobi::Generator.new(cfg) }
      before { gen.generate }

      describe 'src[:cnf_run]' do
        context 'は`run ???::App`であること' do
          it { gen.src[:cnf_run].should eq "run #{gen.app_name}::App" }
        end
      end

      describe 'src[:app_run]' do
        context "は`nil`であること" do
          it { gen.src[:app_run].should eq nil }
        end
      end
    end
  end

  Tobi::OPT_VALUES[:ViewTemplate].each do |v|
    context "ViewTemplateが#{v}のとき" do
      it_behaves_like 'view template', v
    end
  end

  Tobi::OPT_VALUES[:CssTemplate].each do |v|
    context "CssTemplateが#{v}のとき" do
      it_behaves_like 'css template', v
    end
  end

  Tobi::OPT_VALUES[:TestFramework].each do |v|
    context "TestFrameworkが#{v}のとき" do
      [true, false].each do |modular_style|
        it_behaves_like 'test framework', v, modular_style
      end
    end
  end
end

