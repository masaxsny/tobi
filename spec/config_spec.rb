# coding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tobi'

shared_examples_for 'invalid value' do |key|
  before { cfg.instance_eval('@options')[key] = 'xxxx' }
  context 'プログラムは終了すること' do
    it { lambda { cfg.instance_eval('check') }.should raise_error(SystemExit) }
  end
end

describe Tobi::Config do
  context 'オプション指定なしのとき' do
    cfg = Tobi::Config.new('Sample')
    describe 'options' do
      context 'はデフォルト値である' do
        it { cfg.options.should eq Tobi::DEFAULT_OPTS }
      end
    end
  end

  context 'オプション指定ありのとき' do
    opt = { ModularStyle:  true,
            Rackup:        false,
            ViewTemplate:  'slim',
            CssTemplate:   'sass',
            TestFramework: 'rspec' }
    cfg = Tobi::Config.new('Sample', opt)
    describe 'options' do
      context 'は指定された値である' do
        it { cfg.options.should eq opt }
      end
    end
  end

  context '不正な値が指定されたとき' do
    before { STDOUT.stub(:puts).and_return(nil) }
    let(:cfg){ Tobi::Config.new('Sample') }
    Tobi::DEFAULT_OPTS.each do |k, v|
      it_behaves_like 'invalid value', k
    end
  end
end

