require 'spec_helper'

describe Vx::Instrumentation::Rack::HandleExceptionsMiddleware do
  let(:env)        { {} }
  let(:app)        { ->(e){ e.merge(foo: :bar) } }
  let(:output)     { StringIO.new }
  let(:middleware) { described_class.new(app) }
  let(:result) {
    output.rewind
    c = output.read
    if c.to_s != ""
      JSON.parse c
    end
  }

  before do
    Vx::Instrumentation::Logger.setup output
  end

  it "should work when no exceptions raised" do
    expect(middleware.call(env)).to eq(foo: :bar)
    expect(result).to be_nil
  end

  it "should catch raised exception" do
    app = ->(_) { raise RuntimeError, "Ignore Me" }
    mid = described_class.new(app)
    expect{ mid.call(env) }.to raise_error(RuntimeError, 'Ignore Me')

    expect(result["@tags"]).to eq ["handle_exception", "rack", "exception"]
    expect(result["@event"]).to eq 'handle_exception.rack'
    expect(result['exception']).to eq 'RuntimeError'
    expect(result['message']).to eq 'Ignore Me'
    expect(result['backtrace']).to_not be_empty
  end
end
