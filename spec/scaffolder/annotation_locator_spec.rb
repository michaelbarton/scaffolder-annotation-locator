require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Scaffolder::AnnotationLocator do

  def relocate(scaffold,records)

    GC.disable
    @scaffold_file, @sequence_file = generate_scaffold_files(scaffold)
    c = described_class.new(@scaffold_file.path, @sequence_file.path,
                        generate_gff3_file(records).path)

    GC.enable
    c
  end

  before do
    @contig = Sequence.new(:name => 'c1',:sequence => 'ATGCCC')
    @record = {:seqname => 'c1',
      :start => 4, :end => 6, :strand => '+',:phase => 1}
  end

  describe "relocating a single contig" do

    describe "with no annotations" do

      subject do
        relocate([@contig],[])
      end

      it "should return an empty annotation array" do
        subject.should be_empty
      end

    end

    describe "with a single annotation" do

      subject do
        relocate([@contig],[@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 4).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 6).only_for_the(:first) }

    end

    describe "reversed with a single annotation" do

      subject do
        relocate([@contig.clone.reverse(true)],[@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '-') }

      it{ should set_the_attribute(:start   => 1).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 3).only_for_the(:first) }

    end

    describe "start trimmed with a single annotation" do

      subject do
        relocate([@contig.clone.start(4)],[@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 1).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 3).only_for_the(:first) }

    end

    describe "with an insert before an annotation" do

      subject do
        relocate([@contig.clone.inserts(:open => 1, :close => 2, :sequence => 'TTT')],
                 [@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 5).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 7).only_for_the(:first) }

    end

    describe "with an insert after an annotation" do

      subject do
        relocate([@contig.clone.
                   inserts(:open => 7, :close => 8, :sequence => 'TTT').
                   sequence('ATGTTTCCC')],
                 [@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 4).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 6).only_for_the(:first) }

    end

    describe "with an insert before and after an annotation" do

      subject do
        relocate([@contig.clone.
                   inserts(:open => 1, :close => 2, :sequence => 'TTT').
                   inserts(:open => 7, :close => 8, :sequence => 'TTT').
                   sequence('ATGTTTCCC')],
                 [@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 5).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 7).only_for_the(:first) }

    end

    describe "reversed with an insert before an annotation" do

      subject do
        contig = @contig.clone.
                 reverse(true).
                 inserts(:open => 1, :close => 2, :sequence => 'TTT')
        relocate([contig],[@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '-') }

      it{ should set_the_attribute(:start   => 1).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 3).only_for_the(:first) }

    end

    describe "with an insert overlapping with an annotation" do

      subject do
        relocate([@contig.clone.
                   inserts(:open => 3, :close => 5, :sequence => 'TTT')],
                 [@record])
      end

      it "should not include this annotation" do
        subject.should be_empty
      end

    end

    describe "with an annotation in a start trimmed region" do

      subject do
        relocate([@contig.clone.start(5)],[@record])
      end

      it "should not include this annotation" do
        subject.should be_empty
      end

    end

    describe "with an annotation in a stop trimmed region" do

      subject do
        relocate([@contig.clone.stop(5)],[@record])
      end

      it "should not include this annotation" do
        subject.should be_empty
      end

    end

  end

  describe "relocating two contigs" do

    describe "with an annotation on each contig" do

      subject do
        second = @record.clone
        second[:seqname] = 'c2'
        relocate([@contig, @contig.clone.name('c2')],[@record,second])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 4).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 6).only_for_the(:first) }

      it{ should set_the_attribute(:start   => 10).only_for_the(:second) }
      it{ should set_the_attribute(:end     => 12).only_for_the(:second) }

    end

    describe "where the two annotations are unordered annotations" do

      subject do
        second = @record.merge({:seqname => 'c2', :strand => '-'})
        relocate([@contig, @contig.clone.name('c2')],[second,@record])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }

      it{ should set_the_attribute(:start   => 4).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 6).only_for_the(:first) }
      it{ should set_the_attribute(:strand  => '+').only_for_the(:first) }

      it{ should set_the_attribute(:start   => 10).only_for_the(:second) }
      it{ should set_the_attribute(:end     => 12).only_for_the(:second) }
      it{ should set_the_attribute(:strand  => '-').only_for_the(:second) }

    end

    describe "where the first of the two contigs is start trimmed" do

      subject do
        second = @record.clone
        second[:seqname] = 'c2'

        relocate([@contig.clone.start(4),@contig.clone.name('c2')],[@record,second])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 1).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 3).only_for_the(:first) }

      it{ should set_the_attribute(:start   => 7).only_for_the(:second) }
      it{ should set_the_attribute(:end     => 9).only_for_the(:second) }

    end

    describe "where the first of two contigs is stop trimmed" do

      subject do
        first = @record.clone
        first[:start] = 1
        first[:end]   = 3

        second = @record.clone
        second[:seqname] = 'c2'

        relocate([@contig.clone.stop(3),@contig.clone.name('c2')],[first,second])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 1).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 3).only_for_the(:first) }

      it{ should set_the_attribute(:start   => 7).only_for_the(:second) }
      it{ should set_the_attribute(:end     => 9).only_for_the(:second) }

    end

    describe "separated by an unresolved region" do

      subject do
        second = @record.clone
        second[:seqname] = 'c2'

        unresolved = Unresolved.new(:length => 10)
        relocate([@contig,unresolved,@contig.clone.name('c2')],[@record,second])
      end

      it{ should set_the_attribute(:seqname => 'scaffold') }
      it{ should set_the_attribute(:phase   => 1) }
      it{ should set_the_attribute(:strand  => '+') }

      it{ should set_the_attribute(:start   => 4).only_for_the(:first) }
      it{ should set_the_attribute(:end     => 6).only_for_the(:first) }

      it{ should set_the_attribute(:start   => 20).only_for_the(:second) }
      it{ should set_the_attribute(:end     => 22).only_for_the(:second) }

    end

  end

  describe "#records" do

    subject do
      second = @record.clone
      second[:seqname] = 'c2'

      relocate([@contig,@contig.clone.name('c2')],[@record,second]).records
    end

    it "should return the gff records grouped by sequence" do
      subject['c1'].length.should == 1
      subject['c2'].length.should == 1
    end

  end

end
