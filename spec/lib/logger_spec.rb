require 'spec_helper'

describe Vx::Lib::Instrumentation::Logger do
  let(:out)    { StringIO.new }
  let(:logger) { described_class.setup out }
  let(:result) {
    out.rewind
    JSON.parse(out.read)
  }

  it "should write string mesage" do
    logger.info "I am string"
    expect(result).to eq(
      "message"  => "I am string",
      "severity" => "info"
    )
  end

  it "should write a simple hash" do
    logger.info(key: "value")
    expect(result).to eq(
      'key'      => 'value',
      "severity" => "info"
    )
  end

  it "should write a nested hash" do
    logger.info(
      root: {
        child: {
          subchild: "value"
        }
      }
    )
    expect(result).to eq(
      "root"     => "{:child=>{:subchild=>\"value\"}}",
      "severity" => "info"
    )
  end

  it "should write nested hash with @fields" do
    logger.info(
      "@fields" => {
        child: {
          subchild: "value"
        }
      }
    )
    expect(result).to eq(
      "@fields" => {
        "child"=>"{:subchild=>\"value\"}"
      },
      "severity" => "info"
    )
  end

  it "should write nested hash with arrays" do
    logger.info(
      a: %w{ 1 2 3 },
      "@fields" => {
        c: %w{ 4 5 6 }
      }
    )
    expect(result).to eq(
      "a" => ["1", "2", "3"],
      "@fields" => {
        "c" => "4\n5\n6"
      },
      "severity" => "info"
    )
  end

  it "should work with default values" do
    Vx::Lib::Instrumentation.with(foo: "bar") do
      logger.info(key: "value")
    end
    expect(result).to eq(
      "foo" => "bar",
      "key" => "value",
      "severity" => "info"
    )
  end

  it "should work with nested default values" do
    Vx::Lib::Instrumentation.with("@fields" => {a: 1}) do
      logger.info("@fields" => {b: 2})
    end
    expect(result).to eq(
      "@fields" => {"a"=>1, "b"=>2},
      "severity" => "info"
    )
  end
end
