require 'spec_helper'

describe Vx::Lib::Instrumentation do
  let(:out)  { StringIO.new }
  let(:inst) { described_class }
  let(:result) {
    out.rewind
    JSON.parse out.read
  }

  it "should successfully install" do
    expect(inst.install out).to be
    expect(inst.activate!).to be
  end

  it "should work with default values" do
    inst.with(x: "y") do
      inst.with(a: "b") do
        expect(inst.default).to eq(
          x: "y",
          a: "b"
        )
      end
      expect(inst.default).to eq(x: "y")
    end
    expect(inst.default).to eq({})
  end

  it "should handle exception" do
    inst::Logger.setup out
    ex = Exception.new("message")
    inst.handle_exception('event.name', ex, {key: "value"})
    expect(result["@event"]).to eq 'event.name'
    expect(result["@tags"]).to eq ["event", "name", "exception"]
    expect(result["@fields"]).to eq("key" => "value")
    expect(result["exception"]).to eq 'Exception'
    expect(result["message"]).to eq 'message'
  end
end
