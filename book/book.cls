%##############################################################################################################%
% book.sty for Journal of Hamradio Informatics                                                                 %
%##############################################################################################################%
\ProvidesClass{book}
\LoadClassWithOptions{ltjreport}
\RequirePackage[no-math,hiragino-pro]{luatexja-preset}
\ltjsetparameter{xkanjiskip={.2\zw plus 1pt minus 1pt}}

%##############################################################################################################%
% graphic packages                                                                                             %
%##############################################################################################################%
\RequirePackage{graphicx}
\RequirePackage[suffix=]{epstopdf}

%##############################################################################################################%
% general packages                                                                                             %
%##############################################################################################################%
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{bm}
\RequirePackage{mathtools}
\RequirePackage{subfig}
\RequirePackage{xcolor}
\RequirePackage{xparse}

%##############################################################################################################%
% page size settings                                                                                           %
%##############################################################################################################%
\RequirePackage{geometry}
\geometry{vmargin=10truemm}
\geometry{hmargin=15truemm}
\geometry{includefoot}
\geometry{includehead}
\geometry{truedimen}

%##############################################################################################################%
% book cover commands                                                                                          %
%##############################################################################################################%
\RequirePackage{fancyhdr}
\RequirePackage{hyperref}

\NewDocumentCommand\book{m m m O{無線部} O{開発班} O{https://pafelog.net} m}{
\gdef\@maintitle{#1}
\gdef\@subtitle{#2}
\gdef\@volume{No.~#3}
\author{{#4}{#5}}
\gdef\@homepage{#6}
\gdef\@keywords{#7}
\header{#4}{#5}
\hypersetup{unicode}
\hypersetup{hidelinks}
\hypersetup{pdftitle=\@maintitle}
\hypersetup{pdfsubject=\@subtitle}
\hypersetup{pdfauthor=\@author}
\hypersetup{pdfkeywords=\@keywords}
}

\setlength{\headheight}{15pt}

\NewDocumentCommand\header{m m}{
\pagestyle{fancy}
\lhead{#1}
\rhead{#2}
\chead{-- \thepage{} --}
\cfoot{\@subtitle}
\renewcommand{\footrulewidth}{0.4pt}
}

\RenewDocumentCommand\chapter{}{
\clearpage
\thispagestyle{fancy}
\global\@topnum\z@
\@afterindenttrue
\secdef\@chapter\@schapter
}

%##############################################################################################################%
% book cover drawn by TikZ                                                                                     %
%##############################################################################################################%
\RequirePackage[pages=some]{background}
\RequirePackage{pxpgfmark}
\RequirePackage{tikz}

\backgroundsetup{scale=1}
\backgroundsetup{angle=0}
\backgroundsetup{opacity=1}
\backgroundsetup{contents={
\begin{tikzpicture}[remember picture, overlay]
\def\PW{\paperwidth}
\def\PH{\paperheight}
\definecolor{azure}{rgb}{0.0,0.0,0.5}
\definecolor{flame}{rgb}{1.0,0.0,0.0}
\definecolor{spark}{rgb}{1.0,1.0,0.0}
\usetikzlibrary{decorations.text}
\tikzset{white/.style={color=white}}
\tikzset{black/.style={color=black}}
\tikzset{spark/.style={color=spark}}
\tikzset{azure/.style={color=azure}}
\tikzstyle{every node}=[font=\bfseries\sffamily]
\draw[azure, line width=3mm] (-.50\PW,+.30\PH)--(+.50\PW,+.30\PH);
\draw[azure, line width=3mm] (-.50\PW,+.20\PH)--(+.50\PW,+.20\PH);
\draw[azure, line width=3mm] (-.50\PW,-.35\PH)--(+.50\PW,-.35\PH);
\draw[azure, line width=3mm] (-.50\PW,-.25\PH)--(+.50\PW,-.25\PH);
\draw[azure, line width=3mm] (+.00\PW,-.35\PH)--(+.00\PW,-.40\PH);
\draw[azure, line width=5mm] (-.09\PW,-.40\PH)--(+.09\PW,-.40\PH);
\draw[azure, line width=3mm] (-.06\PW,-.42\PH)--(+.06\PW,-.42\PH);
\draw[azure, line width=3mm] (-.03\PW,-.44\PH)--(+.03\PW,-.44\PH);
\draw[black, fill=black] (0,0) circle (.21\PW);
\draw[black, fill=white] (0,0) circle (.15\PW);
\begin{scope}
\clip (-.00\PW,+.00\PW) circle (.145\PW);
\draw[white, fill=flame] (0,0) circle(.145\PW);
\draw[white, fill=white] (-.02\PW,+.02\PW) circle (.14\PW);
\draw[azure, line width=3mm] (+.00\PW,+.04\PH)--(+.00\PW,-.25\PH);
\draw[azure, line width=3mm] (+.00\PW,-.03\PH)--(-.08\PW,+.04\PH)--(+.08\PW,+.04\PH)--cycle;
\end{scope}
\draw[black] (0,0) circle(.145\PW);
\draw[black] (0,0) circle(.215\PW);
\NewDocumentCommand\flogo{}{\fontsize{.04\PW}{0pt}\selectfont}
\tikzset{logos/.style={decoration={text align=center, text along path, reverse path, text color=spark}}}
\tikzset{eidos/.style={decoration={text align=center, text along path, reverse path, text color=black}}}
\path[decorate, logos, decoration={text=|\flogo|JOURNAL OF HAMRADIO}] (+.166\PW,0) arc (0:+180:.166\PW);
\path[decorate, logos, decoration={text=|\flogo|INFORMATICS LETTERS}] (-.166\PW,0) arc (-180:0:.166\PW);
\path[decorate, eidos, decoration={text=|\Large|\@volume~\@subtitle}] (+.220\PW,0) arc (0:+180:.220\PW);
\node[black] at (0,+.25\PH) {\Huge\textbf{\textsf{\@maintitle}}};
\node[black] at (0,-.30\PH) {\huge\textbf{\textsf{\@author\hspace*{1em}\@date}}};
\node[spark] at (0,-.40\PH) {\texttt{\href{\@homepage/\jobname.pdf}{\@homepage}}};
\end{tikzpicture}}}

\RenewDocumentCommand\maketitle{}{
\begin{titlepage}
\BgThispage
\mbox{}
\end{titlepage}
\setcounter{page}{2}
}

%##############################################################################################################%
% basic text & label formats                                                                                   %
%##############################################################################################################%
\setlength{\parindent}{0pt}
\setcounter{tocdepth}{1}

\RenewDocumentCommand\contentsname{}{目次}
\RenewDocumentCommand\appendixname{}{付録}
\RenewDocumentCommand\figurename{}{Fig.}
\RenewDocumentCommand\tablename{}{Table}

\RequirePackage{letltxmacro}
\LetLtxMacro{\oldeqref}{\eqref}
\NewDocumentCommand\chapref{m}{第\ref{chap:#1}章}
\NewDocumentCommand\sectref{m}{第\ref{sect:#1}節}
\RenewDocumentCommand\eqref{m}{式~\oldeqref{eq:#1}}
\NewDocumentCommand\Algref{m}{\ALG@name{}~\ref{alg:#1}}
\NewDocumentCommand\tabref{m}{\tablename{}~\ref{tab:#1}}
\NewDocumentCommand\figref{m}{\figurename{}~\ref{fig:#1}}
\NewDocumentCommand\subtabref{m m}{\tabref{#1}\subref{tab:#1:#2}}
\NewDocumentCommand\subfigref{m m}{\figref{#1}\subref{fig:#1:#2}}

%##############################################################################################################%
% chapter head                                                                                                 %
%##############################################################################################################%
\NewDocumentCommand\@makebookchapterhead{m}{
\vbox to 30mm{
\Huge\bfseries
\ifnum \c@secnumdepth >\m@ne
\vskip.5mm\hrule\@height.5mm
\vskip.5mm\hrule\@height.1mm
\vspace*{\stretch{1}}
#1
\vspace{\stretch{1}}
\vskip.5mm\hrule\@height.1mm
\vskip.5mm\hrule\@height.5mm
\vspace{.5\baselineskip}
\fi
}
\nobreak
}

\RenewDocumentCommand\@makechapterhead{m}{
\@makebookchapterhead{\@chapapp\thechapter\@chappos\hspace{1\zw}{#1}}
}
%
\RenewDocumentCommand\@makeschapterhead{m}{
\@makebookchapterhead{#1}
}

%##############################################################################################################%
% algorithm                                                                                                    %
%##############################################################################################################%
\RequirePackage{algorithm}
\RequirePackage{algpseudocode}
\algrenewcommand\Return{\State \algorithmicreturn{} }
\RenewDocumentCommand\algorithmicrequire{}{\textbf{Input:}}
\RenewDocumentCommand\algorithmicensure{}{\textbf{Output:}}

%##############################################################################################################%
% lstlisting (Do not use verbatim & fancyvrb because their vertical margin is not controllable)                %
%##############################################################################################################%
\@ifpackageloaded{fancyvrb}{
\PackageError{book}{Never use fancyvrb}{}
}

\definecolor{com}{rgb}{0.00,0.50,0.00}
\definecolor{kwd}{rgb}{0.00,0.00,1.00}
\definecolor{str}{rgb}{1.00,0.00,0.00}
\definecolor{bgc}{rgb}{0.96,0.96,0.96}

\RequirePackage{listings}
\lstset{basewidth=.55em}
\lstset{basicstyle=\ttfamily\small}
\lstset{commentstyle=\color{com}}
\lstset{keywordstyle=\color{kwd}}
\lstset{stringstyle=\color{str}}
\lstset{backgroundcolor=\color{bgc}}
\lstset{aboveskip=12pt plus 0pt minus 2pt}
\lstset{belowskip=12pt plus 0pt minus 2pt}
\lstset{showstringspaces=false}
\lstset{tabsize=2}
\lstset{frame=lines}

\RequirePackage{caption}
\def\lstfcap{\footnotesize}
\setbox01\hbox{\lstfcap{q}}
\DeclareCaptionFormat{listings}{\lstfcap{#3}}
\lstset{belowcaptionskip=\dp01}
\lstset{abovecaptionskip=\the\dimexpr-\baselineskip-\lst@belowcaption}
\captionsetup[lstlisting]{format=listings,singlelinecheck=off,font=tt}

\RequirePackage{etoolbox}
\lstnewenvironment{Verbatim}[2][]{\lstset{language=#2}\notblank{#1}{\lstset{title=#1}}{}}{}

%##############################################################################################################%
% table & column formats                                                                                       %
%##############################################################################################################%
\RequirePackage{array}
\RequirePackage{booktabs}
\RequirePackage{collcell}
\newcolumntype{D}{>{$\cdots$} l}
\newcolumntype{B}{>{\bfseries}l}
\newcolumntype{T}{>{\ttfamily}l}
\newcolumntype{C}{>{\centering\arraybackslash}p{2em}}

%##############################################################################################################%
% put figure[h] & table[h] here                                                                                %
%##############################################################################################################%
\RequirePackage{placeins}
\RenewDocumentEnvironment{figure}{O{\fps@figure}}{\@float{figure}[#1]}{\end@float\FloatBarrier}
\RenewDocumentEnvironment{table}{O{\fps@table}}{\@float{table}[#1]}{\end@float\FloatBarrier}

%##############################################################################################################%
% math commands                                                                                                %
%##############################################################################################################%
\DeclareMathOperator*{\argmin}{arg\,min}
\DeclareMathOperator*{\argmax}{arg\,max}

\LetLtxMacro\SUM\sum
\LetLtxMacro\PROD\prod
\LetLtxMacro\FRAC\frac

\RenewDocumentCommand\sum{}{\displaystyle\SUM}
\RenewDocumentCommand\prod{}{\displaystyle\PROD}
\RenewDocumentCommand\frac{m m}{\displaystyle\FRAC{#1}{#2}}

\NewDocumentCommand\seq{m}{\mathchoice{\left\{#1\right\}}{\{#1\}}{\left\{#1\right\}}{\left\{#1\right\}}}

%##############################################################################################################%
% linear algebra commands                                                                                      %
%##############################################################################################################%
\NewDocumentCommand\dprod{m m}{#1 \cdot #2}
\NewDocumentCommand\iprod{m m}{\left\langle #1,#2\right\rangle}
\NewDocumentCommand\pdiff{m m}{\frac{\partial #1}{\partial #2}}
\NewDocumentCommand\trans{m}{{}^t\!#1\ }
\NewDocumentCommand\where{}{\enspace\mathrm{where}\enspace}
\NewDocumentCommand\normal{m m m}{\frac{\hfill #3}{\sum_{#1}^{#2} #3}}
\NewDocumentCommand\Ii{m}{\mathbb{I}\left(#1\right)}
\NewDocumentCommand\Ik{m m}{\mathbb{I}_{#1}\!\left({#2}\right)}

%##############################################################################################################%
% statistical commands                                                                                         %
%##############################################################################################################%
\NewDocumentCommand\E{O{} m}{\underset{#1}{\mathbf{E}}\!\left[\,#2\,\right]}
\NewDocumentCommand\Var{m}{\mathbf{V}\!\left[\,#1\,\right]}
\NewDocumentCommand\Cov{m}{\mathbf{C}\!\left[\,#1\,\right]}

%##############################################################################################################%
% loss function commands                                                                                       %
%##############################################################################################################%
\NewDocumentCommand\Ece{}{E_\mathrm{CE}}
\NewDocumentCommand\Esq{}{E_\mathrm{sq}}
\NewDocumentCommand\KL{m m}{D\!\left(#1\|#2\right)}
\NewDocumentCommand\smax{}{f_\mathrm{smax}}
\NewDocumentCommand\sigm{}{f_\mathrm{sigm}}

%##############################################################################################################%
% probability distribution commands                                                                            %
%##############################################################################################################%
\NewDocumentCommand\Gd{m}{\Gamma\left(#1\right)}
\NewDocumentCommand\Nd{m}{\mathcal{N}\left(#1\right)}
\NewDocumentCommand\Md{m}{\mathrm{Mul}\left(#1\right)}
\NewDocumentCommand\Dd{m}{\mathrm{Dir}\left(#1\right)}
\NewDocumentCommand\Lk{m}{\mathcal{L}\left(#1\right)}

%##############################################################################################################%
% lstlisting definition for Scala                                                                              %
%##############################################################################################################%

\lstdefinelanguage{Scala}{
	morekeywords=[1]{
		abstract,
		case,
		catch,
		class,
		def,
		do,
		else,
		extends,
		false,
		final,
		finally,
		for,
		forSome,
		if,
		implicit,
		import,
		lazy,
		match,
		new,
		null,
		object,
		override,
		package,
		private,
		protected,
		return,
		sealed,
		super,
		this,
		throw,
		trait,
		try,
		true,
		type,
		val,
		var,
		while,
		with,
		yield
	},
	otherkeywords={
		=,
		=>,
		->,
		++,
		+:,
		:+
	},
	sensitive,
	morecomment=[n]{/*}{*/},
	morecomment=[l]//,
	morestring=[b]",
	morestring=[b]',
	morestring=[b]"""
}[keywords,comments,strings]

%##############################################################################################################%
% lstlisting definition for dlang                                                                              %
%##############################################################################################################%
\lstdefinelanguage{dlang}{
	morekeywords=[1]{
		abstract,
		alias,
		align,
		assert,
		auto,
		body,
		break,
		cast,
		catch,
		class,
		const,
		continue,
		debug,
		delegate,
		delete,
		deprecated,
		do,
		else,
		enum,
		export,
		false,
		final,
		finally,
		for,
		foreach,
		foreach_reverse,
		function,
		goto,
		if,
		immutable,
		import,
		in,
		inout,
		interface,
		invariant,
		is,
		lazy,
		macro,
		mixin,
		module,
		new,
		nothrow,
		null,
		out,
		override,
		package,
		pragma,
		private,
		protected,
		public,
		pure,
		ref,
		return,
		shared,
		static,
		struct,
		super,
		switch,
		synchronized,
		template,
		this,
		throw,
		true,
		try,
		typedef,
		typeid,
		typeof,
		union,
		unittest,
		volatile,
		while,
		with
	},
	morekeywords=[2]{enforce},
	morekeywords=[3]{
		byte,
		ubyte,
		short,
		ushort,
		int,
		uint,
		long,
		ulong,
		cent,
		ucent,
		void,
		bool,
		float,
		double,
		real,
		ushort,
		int,
		uint,
		long,
		ulong,
		float,
		char,
		wchar,
		dchar,
		string,
		wstring,
		dstring,
		ireal,
		ifloat,
		idouble,
		creal,
		cfloat,
		cdouble,
		size_t,
		ptrdiff_t,
		sizediff_t,
		equals_t,
		hash_t
	},
	morestring=[b]{"},
	morestring=[b]{'},
	morestring=[b]{`},
	comment=[l]{//},
	morecomment=[s]{/*}{*/},
	morecomment=[s]{/+}{+/},
	sensitive=true
}

%##############################################################################################################%
% lstlisting definition for Chapel                                                                             %
%##############################################################################################################%
\lstdefinelanguage{Chapel}{
	morekeywords=[1]{
		align,
		atomic,
		begin,
		break,
		by,
		class,
		cobegin,
		coforall,
		config,
		const,
		continue,
		delete,
		dmapped,
		do,
		domain,
		else,
		enum,
		export,
		extern,
		false,
		for,
		forall,
		here,
		if,
		in,
		index,
		inline,
		inout,
		iter,
		label,
		lambda,
		let,
		local,
		locale,
		module,
		new,
		nil,
		on,
		opaque,
		otherwise,
		out,
		param,
		proc,
		range,
		record,
		reduce,
		ref,
		return,
		scan,
		select,
		serial,
		single,
		string,
		sparse,
		subdomain,
		sync,
		then,
		these,
		this,
		true,
		type,
		union,
		use,
		var,
		when,
		where,
		while,
		with,
		yield,
		zip
	},
 	morekeywords=[2]{
		bool,
		imag,
		int,
		real,
		uint,
		void
	},
	sensitive,
	morecomment=[s]{/*}{*/},
	morecomment=[l]//,
	morestring=[b]",
	morestring=[b]',
}[keywords,comments,strings]
%##############################################################################################################%
% end of book.sty                                                                                              %
%##############################################################################################################%
