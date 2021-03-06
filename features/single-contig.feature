Feature: Locating annotations on single contig scaffold
  In order to add gff3 annotations to a scaffold
  A user can use scaffold-annotation-locator
  to return the updated coordinates of scaffold annotations

  Scenario: One annotation on a contig
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	4	13	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      scaffold	.	CDS	4	13	.	+	1	ID=gene1
      """

  Scenario: One annotation on a reversed contig
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
            reverse: true
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	1	6	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      scaffold	.	CDS	15	20	.	-	1	ID=gene1
      """

  Scenario: An annotation in a start trimmed region of the sequence
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
            start: 5
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      > insert1
      TTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	4	13	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      """

  Scenario: An annotation inside a stop trimmed region of the sequence
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
            stop: 12
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      > insert1
      TTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	4	13	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      """

  Scenario: An annotation bordering a stop trimmed region of the sequence
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
            stop: 13
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      > insert1
      TTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	4	13	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      scaffold	.	CDS	4	13	.	+	1	ID=gene1
      """

  Scenario: An annotation bordering a start trimmed region of the sequence
    Given a file named "scaf.yml" with:
      """
      ---
        - sequence:
            source: contig1
            start: 4
      """
    Given a file named "seq.fna" with:
      """
      > contig1
      AAAAAGGGGGCCCCCTTTTT
      """
    Given a file named "anno.gff" with:
      """
      ##gff-version 3
      contig1	.	CDS	4	13	.	+	1	ID=gene1
      """
    When I relocate the annotations using "scaf.yml", "seq.fna" and "anno.gff"
    Then the result should be:
      """
      ##gff-version 3
      scaffold	.	CDS	1	10	.	+	1	ID=gene1
      """

