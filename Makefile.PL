use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME	=> 'PythonTech::Conv',
	      VERSION => '1.4',
	      ABSTRACT => 'Escaping and unescaping of strings',
	      AUTHOR => 'Colin Hogben <perl@pythontech.co.uk>',
	      PREREQ_PM => {
		Test::More => 0.32,
	      },
	      );
