require 'spec_helper'

describe Csgraph::DSL::Definitions do

	include Csgraph::DSL::Reader

  it 'can handle DSL syntax errors' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'really_wrong')
    expect { csg_require(path) }.to raise_error(Csgraph::DSL::Exceptions::SyntaxError) # the actual message can only be matched
  end
  
  it 'should be able to parse DSL-correct files' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_1')
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # now let's check if the parsing is correct
    #
    expect(csg_defs.keys.size).to eq(4)
    expect(csg_defs.keys).to eq(['1', '2', '3', '4'])
    csg_defs.each do
      |key, content|
      expect(content.class).to be(Csgraph::DSL::Instr)
      expect(content.features.size).to eq(1)
      expect(content.features.first.class).to be(Csgraph::DSL::Line)
      expect(content.features.first.xstart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.xstart.number).to eq(2)
      expect(content.features.first.xend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.xend.left.number).to eq(2)
      expect(content.features.first.xend.right.number).to eq(3)
      expect(content.features.first.xend.operator).to eq(:__plus__)
      expect(content.features.first.ystart.number).to eq(5)
      expect(content.features.first.yend.number).to eq(5)
    end
  end

  #
  # The following spec tests the following csg:
  #
  #   instr 1, 10 do
  #     line p2, p2+p3, 1000.2323 + p5, p5 + 990
  #   end
  #
  it 'should be able to parse DSL-correct files adding constants' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_plus_constants')
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # now let's check if the parsing is correct
    #
    expect(csg_defs.keys.size).to eq(2)
    expect(csg_defs.keys).to eq(['1', '10']) # keys are instruments
    csg_defs.each do
      |key, content|
      expect(content.class).to be(Csgraph::DSL::Instr)
      expect(content.features.size).to eq(1)
      expect(content.features.first.class).to be(Csgraph::DSL::Line)
      expect(content.features.first.xstart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.xstart.number).to eq(2)
      expect(content.features.first.xend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.xend.left.number).to eq(2)
      expect(content.features.first.xend.right.number).to eq(3)
      expect(content.features.first.xend.operator).to eq(:__plus__)
      expect(content.features.first.ystart.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.ystart.left.is_a?(Numeric)).to be(true)
      expect(content.features.first.ystart.left).to eq(1000.2323)
      expect(content.features.first.ystart.right.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.ystart.right.number).to eq(5)
      expect(content.features.first.yend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.yend.left.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.yend.left.number).to eq(5)
      expect(content.features.first.yend.right.is_a?(Numeric)).to be(true)
      expect(content.features.first.yend.right).to eq(990)
    end
  end

  #
  # The following spec tests the following csg:
  #
  #   instr 1, 10 do
  #     line p2, p2+p3, 1000.2323 - p5, p5 - 990
  #   end
  #
  it 'should be able to parse DSL-correct files subtracting constants' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_minus_constants')
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # now let's check if the parsing is correct
    #
    expect(csg_defs.keys.size).to eq(2)
    expect(csg_defs.keys).to eq(['1', '10']) # keys are instruments
    csg_defs.each do
      |key, content|
      expect(content.class).to be(Csgraph::DSL::Instr)
      expect(content.features.size).to eq(1)
      expect(content.features.first.class).to be(Csgraph::DSL::Line)
      expect(content.features.first.xstart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.xstart.number).to eq(2)
      expect(content.features.first.xend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.xend.left.number).to eq(2)
      expect(content.features.first.xend.right.number).to eq(3)
      expect(content.features.first.xend.operator).to eq(:__plus__)
      expect(content.features.first.ystart.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.ystart.operator).to eq(:__minus__)
      expect(content.features.first.ystart.left.is_a?(Numeric)).to be(true)
      expect(content.features.first.ystart.left).to eq(1000.2323)
      expect(content.features.first.ystart.right.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.ystart.right.number).to eq(5)
      expect(content.features.first.yend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.yend.operator).to eq(:__minus__)
      expect(content.features.first.yend.left.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.yend.left.number).to eq(5)
      expect(content.features.first.yend.right.is_a?(Numeric)).to be(true)
      expect(content.features.first.yend.right).to eq(990)
    end
  end

  it 'should be able to produce headers and trailers' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_1')
    expect((out = StringIO.new).class).to be(StringIO)
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # header
    #
    expect((out = StringIO.new).class).to be(StringIO)
    expect(csg_defs.header(out)).to be(nil)
    expect(out.size).to be > 0
    #
    # trailer
    #
    expect((out = StringIO.new).class).to be(StringIO)
    expect(csg_defs.trailer(out)).to be(nil)
    expect(out.size).to be > 0
  end

  #
  # This specs the following csg
  #
  # instr 1, 2, 3, 4 do
  #   line p2, p2+p3, cpspch(p5), cpspch(p5), :thickness => ampdb(p4)*3
  # end
  #

  it 'should be able to render a csg with csound ampdb and cpspch conversions' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_with_conversions_0')
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # now let's check if the parsing is correct
    #
    expect(csg_defs.keys.size).to eq(4)
    expect(csg_defs.keys).to eq(['1', '2', '3', '4']) # keys are instruments
    csg_defs.each do
      |key, content|
      expect(content.class).to be(Csgraph::DSL::Instr)
      expect(content.features.size).to eq(1)
      expect(content.features.first.class).to be(Csgraph::DSL::Line)
      expect(content.features.first.xstart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.xstart.number).to eq(2)
      expect(content.features.first.xend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.xend.left.number).to eq(2)
      expect(content.features.first.xend.right.number).to eq(3)
      expect(content.features.first.xend.operator).to eq(:__plus__)
      expect(content.features.first.ystart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.ystart.number).to eq(5)
      expect(content.features.first.ystart.converters).to eq([:cpspch])
      expect(content.features.first.yend.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.yend.number).to eq(5)
      expect(content.features.first.yend.converters).to eq([:cpspch])
      expect(content.features.first.options['thickness'].class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.options['thickness'].converters).to eq([])
      expect(content.features.first.options['thickness'].left.converters).to eq([:ampdb])
    end
  end

  #
  # This specs the following csg
  #
  # instr 1, 2, 3, 4 do
  #   line p2, p2+p3, cpsoct(p5), cpsoct(p5), :thickness => ampdbfs(p4)/1000.0
  # end
  #

  it 'should be able to render a csg with csound ampdbfs and cpsoct conversions' do
    path = File.join(SPEC_CSG_FIXTURE_PATH, 'simple_with_conversions_1')
    expect((csg_defs = csg_require(path)).class).to be(Csgraph::DSL::Definitions)
    #
    # now let's check if the parsing is correct
    #
    expect(csg_defs.keys.size).to eq(4)
    expect(csg_defs.keys).to eq(['1', '2', '3', '4']) # keys are instruments
    csg_defs.each do
      |key, content|
      expect(content.class).to be(Csgraph::DSL::Instr)
      expect(content.features.size).to eq(1)
      expect(content.features.first.class).to be(Csgraph::DSL::Line)
      expect(content.features.first.xstart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.xstart.number).to eq(2)
      expect(content.features.first.xend.class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.xend.left.number).to eq(2)
      expect(content.features.first.xend.right.number).to eq(3)
      expect(content.features.first.xend.operator).to eq(:__plus__)
      expect(content.features.first.ystart.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.ystart.number).to eq(5)
      expect(content.features.first.ystart.converters).to eq([:cpsoct])
      expect(content.features.first.yend.class).to be(Csgraph::DSL::PField)
      expect(content.features.first.yend.number).to eq(5)
      expect(content.features.first.yend.converters).to eq([:cpsoct])
      expect(content.features.first.options['thickness'].class).to be(Csgraph::DSL::PFieldExpression)
      expect(content.features.first.options['thickness'].converters).to eq([])
      expect(content.features.first.options['thickness'].left.converters).to eq([:ampdbfs])
    end
  end

end
