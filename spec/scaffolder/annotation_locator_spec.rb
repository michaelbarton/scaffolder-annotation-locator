require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Scaffolder::AnnotationLocator do

  def generate_gff3_file(annotations)
    gff = Bio::GFF::GFF3.new
    gff.records = annotations.map do |a|
      Bio::GFF::GFF3::Record.new(a[:seqname], a[:source], 'CDS', a[:start],
       a[:end], nil, a[:strand],  a[:phase])
    end

    tmp = Tempfile.new(Time.new).path
    File.open(tmp,'w'){ |out| out.print gff }
    tmp
  end

  describe "relocating a single annotation on a single contig" do

    before do
      entries = [{:name => 'seq1', :nucleotides => 'ATGC', :start => 4}]

      @record = { :seqname => 'contig1',
        :start => 4, :end => 6, :strand => '+',:phase => 1}
      @gff3_file = generate_gff3_file([@record])
      @scaffold_file = write_scaffold_file(entries)
      @sequence_file = write_sequence_file(entries)
    end

    subject do
      described_class.new(@scaffold_file, @sequence_file, @gff3_file).first
    end

    it "should have scaffold as sequence name" do
      subject.seqname.should == "scaffold"
    end

    it "should have same start position" do
      subject.start.should == @record[:start]
    end

    it "should have same end position" do
      subject.end.should == @record[:end]
    end

    it "should have same strand" do
      subject.strand.should == @record[:strand]
    end

    it "should have same phase" do
      subject.phase.should == @record[:phase]
    end

  end

end
