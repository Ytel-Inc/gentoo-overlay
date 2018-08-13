<!DOCTYPE html>
<html lang='en'>
<head>
<title>scylla-tools-2.2.0.ebuild\scylla-tools\app-admin - dev/ultrabug.git - Developer overlay</title>
<meta name='generator' content='cgit v1.2.1'/>
<meta name='robots' content='index,follow'/>
<link rel='stylesheet' type='text/css' href='/cgit.css'/>
<link rel='shortcut icon' href='//www.gentoo.org/favicon.ico'/>
<link rel='alternate' title='Atom feed' href='https://gitweb.gentoo.org/dev/ultrabug.git/atom/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild?h=master' type='application/atom+xml'/>
<link rel='vcs-git' href='git://anongit.gentoo.org/dev/ultrabug.git' title='dev/ultrabug.git Git repository'/>
<link rel='vcs-git' href='https://anongit.gentoo.org/git/dev/ultrabug.git' title='dev/ultrabug.git Git repository'/>
<link rel='vcs-git' href='http://anongit.gentoo.org/git/dev/ultrabug.git' title='dev/ultrabug.git Git repository'/>
<link rel='vcs-git' href='git+ssh://git@git.gentoo.org/dev/ultrabug.git' title='dev/ultrabug.git Git repository'/>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="theme-color" content="#54487a">
<meta name="description" content="Browse the Gentoo Git repositories">
<link href="https://assets.gentoo.org/tyrian/bootstrap.min.css" rel="stylesheet" media="screen">
<link href="https://assets.gentoo.org/tyrian/tyrian.min.css" rel="stylesheet" media="screen">
</head>
<body>
<header>
  <div class="site-title">
    <div class="container">
      <div class="row">
        <div class="site-title-buttons">
          <div class="btn-group btn-group-sm">
            <a href="https://get.gentoo.org/" role="button" class="btn get-gentoo"><span class="fa fa-fw fa-download"></span> <strong>Get Gentoo!</strong></a>
            <div class="btn-group btn-group-sm">
              <a class="btn gentoo-org-sites dropdown-toggle" data-toggle="dropdown" data-target="#" href="#">
                <span class="fa fa-fw fa-map-o"></span> <span class="hidden-xs">gentoo.org sites</span> <span class="caret"></span>
              </a>
              <ul class="dropdown-menu dropdown-menu-right">
                <li><a href="https://www.gentoo.org/" title="Main Gentoo website"><span class="fa fa-home fa-fw"></span> gentoo.org</a></li>
                <li><a href="https://wiki.gentoo.org/" title="Find and contribute documentation"><span class="fa fa-file-text-o fa-fw"></span> Wiki</a></li>
                <li><a href="https://bugs.gentoo.org/" title="Report issues and find common issues"><span class="fa fa-bug fa-fw"></span> Bugs</a></li>
                <li><a href="https://forums.gentoo.org/" title="Discuss with the community"><span class="fa fa-comments-o fa-fw"></span> Forums</a></li>
                <li><a href="https://packages.gentoo.org/" title="Find software for your Gentoo"><span class="fa fa-hdd-o fa-fw"></span> Packages</a></li>
                <li class="divider"></li>
                <li><a href="https://planet.gentoo.org/" title="Find out what's going on in the developer community"><span class="fa fa-rss fa-fw"></span> Planet</a></li>
                <li><a href="https://archives.gentoo.org/" title="Read up on past discussions"><span class="fa fa-archive fa-fw"></span> Archives</a></li>
                <li><a href="https://sources.gentoo.org/" title="Browse our source code"><span class="fa fa-code fa-fw"></span> Sources</a></li>
                <li class="divider"></li>
                <li><a href="https://infra-status.gentoo.org/" title="Get updates on the services provided by Gentoo"><span class="fa fa-server fa-fw"></span> Infra Status</a></li>
              </ul>
            </div>
          </div>
        </div>
        <div class="logo">
          <a href="/" title="Back to the homepage" class="site-logo">
            <object data="https://assets.gentoo.org/tyrian/site-logo.svg" type="image/svg+xml">
              <img src="https://assets.gentoo.org/tyrian/site-logo.png" alt="Gentoo Linux Logo">
            </object>
          </a>
          <span class="site-label">GitWeb</span>
        </div>
      </div>
    </div>
  </div>
  <nav class="tyrian-navbar" role="navigation">
    <div class="container">
      <div class="row">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-main-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>
        <div class="collapse navbar-collapse navbar-main-collapse">
          <ul class="nav navbar-nav">
            <li><a href="/">Home</a></li>
            <li><a href="/repo/gentoo.git">Gentoo Repository</a></li>
            <li><a href="/repo/">Repositories</a></li>
            <li><a href="/proj/">Projects</a></li>
            <li><a href="/dev/">Developer Overlays</a></li>
            <li><a href="/user/">User Overlays</a></li>
            <li><a href="/data/">Data</a></li>
            <li><a href="/sites/">Websites</a></li>
          </ul>
        </div>
      </div>
    </div>
  </nav>
</header>

<div class="container">
  <div class="row">
  <div class="col-md-12">
<div id='cgit'><table id='header'>
<tr>
<td class='logo' rowspan='2'><a href='/'><img src='/cgit.png' alt='cgit logo'/></a></td>
<td class='main'><a href='/'>index</a> : <a title='dev/ultrabug.git' href='/dev/ultrabug.git/'>dev/ultrabug.git</a></td><td class='form'><form method='get'>
<select name='h' onchange='this.form.submit();'>
<option value='master' selected='selected'>master</option>
</select> <input type='submit' value='switch'/></form></td></tr>
<tr><td class='sub'>Developer overlay</td><td class='sub right'>Ultrabug &lt;ultrabug@gentoo.org</td></tr></table>
<table class='tabs'><tr><td>
<a href='/dev/ultrabug.git/'>summary</a><a href='/dev/ultrabug.git/refs/'>refs</a><a href='/dev/ultrabug.git/log/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>log</a><a class='active' href='/dev/ultrabug.git/tree/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>tree</a><a href='/dev/ultrabug.git/commit/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>commit</a><a href='/dev/ultrabug.git/diff/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>diff</a></td><td class='form'><form class='right' method='get' action='/dev/ultrabug.git/log/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>
<select name='qt'>
<option value='grep'>log msg</option>
<option value='author'>author</option>
<option value='committer'>committer</option>
<option value='range'>range</option>
</select>
<input class='txt' type='search' size='10' name='q' value=''/>
<input type='submit' value='search'/>
</form>
</td></tr></table>
<div class='path'>path: <a href='/dev/ultrabug.git/tree/'>root</a>/<a href='/dev/ultrabug.git/tree/app-admin'>app-admin</a>/<a href='/dev/ultrabug.git/tree/app-admin/scylla-tools'>scylla-tools</a>/<a href='/dev/ultrabug.git/tree/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>scylla-tools-2.2.0.ebuild</a></div><div class='content'>blob: 9d41e14fc469a3f25273261e551a29f9375b41c6 (<a href='/dev/ultrabug.git/plain/app-admin/scylla-tools/scylla-tools-2.2.0.ebuild'>plain</a>)
<table summary='blob content' class='blob'>
<tr><td class='linenumbers'><pre><a id='n1' href='#n1'>1</a>
<a id='n2' href='#n2'>2</a>
<a id='n3' href='#n3'>3</a>
<a id='n4' href='#n4'>4</a>
<a id='n5' href='#n5'>5</a>
<a id='n6' href='#n6'>6</a>
<a id='n7' href='#n7'>7</a>
<a id='n8' href='#n8'>8</a>
<a id='n9' href='#n9'>9</a>
<a id='n10' href='#n10'>10</a>
<a id='n11' href='#n11'>11</a>
<a id='n12' href='#n12'>12</a>
<a id='n13' href='#n13'>13</a>
<a id='n14' href='#n14'>14</a>
<a id='n15' href='#n15'>15</a>
<a id='n16' href='#n16'>16</a>
<a id='n17' href='#n17'>17</a>
<a id='n18' href='#n18'>18</a>
<a id='n19' href='#n19'>19</a>
<a id='n20' href='#n20'>20</a>
<a id='n21' href='#n21'>21</a>
<a id='n22' href='#n22'>22</a>
<a id='n23' href='#n23'>23</a>
<a id='n24' href='#n24'>24</a>
<a id='n25' href='#n25'>25</a>
<a id='n26' href='#n26'>26</a>
<a id='n27' href='#n27'>27</a>
<a id='n28' href='#n28'>28</a>
<a id='n29' href='#n29'>29</a>
<a id='n30' href='#n30'>30</a>
<a id='n31' href='#n31'>31</a>
<a id='n32' href='#n32'>32</a>
<a id='n33' href='#n33'>33</a>
<a id='n34' href='#n34'>34</a>
<a id='n35' href='#n35'>35</a>
<a id='n36' href='#n36'>36</a>
<a id='n37' href='#n37'>37</a>
<a id='n38' href='#n38'>38</a>
<a id='n39' href='#n39'>39</a>
<a id='n40' href='#n40'>40</a>
<a id='n41' href='#n41'>41</a>
<a id='n42' href='#n42'>42</a>
<a id='n43' href='#n43'>43</a>
<a id='n44' href='#n44'>44</a>
<a id='n45' href='#n45'>45</a>
<a id='n46' href='#n46'>46</a>
<a id='n47' href='#n47'>47</a>
<a id='n48' href='#n48'>48</a>
<a id='n49' href='#n49'>49</a>
<a id='n50' href='#n50'>50</a>
<a id='n51' href='#n51'>51</a>
<a id='n52' href='#n52'>52</a>
<a id='n53' href='#n53'>53</a>
<a id='n54' href='#n54'>54</a>
<a id='n55' href='#n55'>55</a>
<a id='n56' href='#n56'>56</a>
<a id='n57' href='#n57'>57</a>
<a id='n58' href='#n58'>58</a>
<a id='n59' href='#n59'>59</a>
<a id='n60' href='#n60'>60</a>
<a id='n61' href='#n61'>61</a>
<a id='n62' href='#n62'>62</a>
<a id='n63' href='#n63'>63</a>
<a id='n64' href='#n64'>64</a>
<a id='n65' href='#n65'>65</a>
<a id='n66' href='#n66'>66</a>
<a id='n67' href='#n67'>67</a>
<a id='n68' href='#n68'>68</a>
<a id='n69' href='#n69'>69</a>
<a id='n70' href='#n70'>70</a>
<a id='n71' href='#n71'>71</a>
<a id='n72' href='#n72'>72</a>
<a id='n73' href='#n73'>73</a>
<a id='n74' href='#n74'>74</a>
<a id='n75' href='#n75'>75</a>
<a id='n76' href='#n76'>76</a>
<a id='n77' href='#n77'>77</a>
<a id='n78' href='#n78'>78</a>
<a id='n79' href='#n79'>79</a>
<a id='n80' href='#n80'>80</a>
<a id='n81' href='#n81'>81</a>
<a id='n82' href='#n82'>82</a>
<a id='n83' href='#n83'>83</a>
<a id='n84' href='#n84'>84</a>
<a id='n85' href='#n85'>85</a>
<a id='n86' href='#n86'>86</a>
<a id='n87' href='#n87'>87</a>
<a id='n88' href='#n88'>88</a>
<a id='n89' href='#n89'>89</a>
<a id='n90' href='#n90'>90</a>
<a id='n91' href='#n91'>91</a>
</pre></td>
<td class='lines'><pre><code><style>.highlight .hll { background-color: #ffffcc }
.highlight .c { color: #888888 } /* Comment */
.highlight .err { color: #a61717; background-color: #e3d2d2 } /* Error */
.highlight .k { color: #008800; font-weight: bold } /* Keyword */
.highlight .ch { color: #888888 } /* Comment.Hashbang */
.highlight .cm { color: #888888 } /* Comment.Multiline */
.highlight .cp { color: #cc0000; font-weight: bold } /* Comment.Preproc */
.highlight .cpf { color: #888888 } /* Comment.PreprocFile */
.highlight .c1 { color: #888888 } /* Comment.Single */
.highlight .cs { color: #cc0000; font-weight: bold; background-color: #fff0f0 } /* Comment.Special */
.highlight .gd { color: #000000; background-color: #ffdddd } /* Generic.Deleted */
.highlight .ge { font-style: italic } /* Generic.Emph */
.highlight .gr { color: #aa0000 } /* Generic.Error */
.highlight .gh { color: #333333 } /* Generic.Heading */
.highlight .gi { color: #000000; background-color: #ddffdd } /* Generic.Inserted */
.highlight .go { color: #888888 } /* Generic.Output */
.highlight .gp { color: #555555 } /* Generic.Prompt */
.highlight .gs { font-weight: bold } /* Generic.Strong */
.highlight .gu { color: #666666 } /* Generic.Subheading */
.highlight .gt { color: #aa0000 } /* Generic.Traceback */
.highlight .kc { color: #008800; font-weight: bold } /* Keyword.Constant */
.highlight .kd { color: #008800; font-weight: bold } /* Keyword.Declaration */
.highlight .kn { color: #008800; font-weight: bold } /* Keyword.Namespace */
.highlight .kp { color: #008800 } /* Keyword.Pseudo */
.highlight .kr { color: #008800; font-weight: bold } /* Keyword.Reserved */
.highlight .kt { color: #888888; font-weight: bold } /* Keyword.Type */
.highlight .m { color: #0000DD; font-weight: bold } /* Literal.Number */
.highlight .s { color: #dd2200; background-color: #fff0f0 } /* Literal.String */
.highlight .na { color: #336699 } /* Name.Attribute */
.highlight .nb { color: #003388 } /* Name.Builtin */
.highlight .nc { color: #bb0066; font-weight: bold } /* Name.Class */
.highlight .no { color: #003366; font-weight: bold } /* Name.Constant */
.highlight .nd { color: #555555 } /* Name.Decorator */
.highlight .ne { color: #bb0066; font-weight: bold } /* Name.Exception */
.highlight .nf { color: #0066bb; font-weight: bold } /* Name.Function */
.highlight .nl { color: #336699; font-style: italic } /* Name.Label */
.highlight .nn { color: #bb0066; font-weight: bold } /* Name.Namespace */
.highlight .py { color: #336699; font-weight: bold } /* Name.Property */
.highlight .nt { color: #bb0066; font-weight: bold } /* Name.Tag */
.highlight .nv { color: #336699 } /* Name.Variable */
.highlight .ow { color: #008800 } /* Operator.Word */
.highlight .w { color: #bbbbbb } /* Text.Whitespace */
.highlight .mb { color: #0000DD; font-weight: bold } /* Literal.Number.Bin */
.highlight .mf { color: #0000DD; font-weight: bold } /* Literal.Number.Float */
.highlight .mh { color: #0000DD; font-weight: bold } /* Literal.Number.Hex */
.highlight .mi { color: #0000DD; font-weight: bold } /* Literal.Number.Integer */
.highlight .mo { color: #0000DD; font-weight: bold } /* Literal.Number.Oct */
.highlight .sa { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Affix */
.highlight .sb { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Backtick */
.highlight .sc { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Char */
.highlight .dl { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Delimiter */
.highlight .sd { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Doc */
.highlight .s2 { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Double */
.highlight .se { color: #0044dd; background-color: #fff0f0 } /* Literal.String.Escape */
.highlight .sh { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Heredoc */
.highlight .si { color: #3333bb; background-color: #fff0f0 } /* Literal.String.Interpol */
.highlight .sx { color: #22bb22; background-color: #f0fff0 } /* Literal.String.Other */
.highlight .sr { color: #008800; background-color: #fff0ff } /* Literal.String.Regex */
.highlight .s1 { color: #dd2200; background-color: #fff0f0 } /* Literal.String.Single */
.highlight .ss { color: #aa6600; background-color: #fff0f0 } /* Literal.String.Symbol */
.highlight .bp { color: #003388 } /* Name.Builtin.Pseudo */
.highlight .fm { color: #0066bb; font-weight: bold } /* Name.Function.Magic */
.highlight .vc { color: #336699 } /* Name.Variable.Class */
.highlight .vg { color: #dd7700 } /* Name.Variable.Global */
.highlight .vi { color: #3333bb } /* Name.Variable.Instance */
.highlight .vm { color: #336699 } /* Name.Variable.Magic */
.highlight .il { color: #0000DD; font-weight: bold } /* Literal.Number.Integer.Long */</style><div class="highlight"><pre><span></span><span class="c1"># Copyright 1999-2018 Gentoo Foundation</span>
<span class="c1"># Distributed under the terms of the GNU General Public License v2</span>

<span class="nv">EAPI</span><span class="o">=</span><span class="m">6</span>

<span class="k">if</span> <span class="o">[[</span> <span class="si">${</span><span class="nv">PV</span><span class="si">}</span> <span class="o">==</span> <span class="s2">&quot;9999&quot;</span> <span class="o">]]</span> <span class="p">;</span> <span class="k">then</span>
	<span class="nv">EGIT_REPO_URI</span><span class="o">=</span><span class="s2">&quot;https://github.com/scylladb/scylla-tools-java.git&quot;</span>
	inherit git-r3
<span class="k">else</span>
	<span class="nv">MY_PV</span><span class="o">=</span><span class="s2">&quot;</span><span class="si">${</span><span class="nv">PV</span><span class="p">/_rc/.rc</span><span class="si">}</span><span class="s2">&quot;</span>
	<span class="nv">MY_P</span><span class="o">=</span><span class="s2">&quot;</span><span class="si">${</span><span class="nv">PN</span><span class="si">}</span><span class="s2">-</span><span class="si">${</span><span class="nv">MY_PV</span><span class="si">}</span><span class="s2">&quot;</span>
	<span class="nv">SRC_URI</span><span class="o">=</span><span class="s2">&quot;https://github.com/scylladb/scylla-tools-java/archive/scylla-</span><span class="si">${</span><span class="nv">MY_PV</span><span class="si">}</span><span class="s2">.tar.gz -&gt; </span><span class="si">${</span><span class="nv">MY_P</span><span class="si">}</span><span class="s2">.tar.gz&quot;</span>
	<span class="nv">KEYWORDS</span><span class="o">=</span><span class="s2">&quot;~amd64&quot;</span>
	<span class="nv">S</span><span class="o">=</span><span class="s2">&quot;</span><span class="si">${</span><span class="nv">WORKDIR</span><span class="si">}</span><span class="s2">/scylla-tools-java-scylla-</span><span class="si">${</span><span class="nv">MY_PV</span><span class="si">}</span><span class="s2">&quot;</span>
<span class="k">fi</span>

<span class="nv">EANT_BUILD_TARGET</span><span class="o">=</span><span class="s2">&quot;jar&quot;</span>
<span class="nv">PYTHON_COMPAT</span><span class="o">=(</span> python2_7 <span class="o">)</span>
<span class="nv">JAVA_PKG_IUSE</span><span class="o">=</span><span class="s2">&quot;source doc&quot;</span>

inherit java-pkg-2 java-ant-2 python-single-r1

<span class="nv">DESCRIPTION</span><span class="o">=</span><span class="s2">&quot;scylla tools (Java part)&quot;</span>
<span class="nv">HOMEPAGE</span><span class="o">=</span><span class="s2">&quot;https://github.com/scylladb/scylla-tools-java&quot;</span>

<span class="nv">LICENSE</span><span class="o">=</span><span class="s2">&quot;Apache-2.0&quot;</span>
<span class="nv">SLOT</span><span class="o">=</span><span class="s2">&quot;0&quot;</span>

<span class="nv">CDEPEND</span><span class="o">=</span><span class="s2">&quot;dev-java/antlr:3.5&quot;</span>
<span class="nv">RDEPEND</span><span class="o">=</span><span class="s2">&quot;</span>
<span class="s2">	</span><span class="si">${</span><span class="nv">CDEPEND</span><span class="si">}</span><span class="s2"></span>
<span class="s2">	</span><span class="si">${</span><span class="nv">PYTHON_DEPS</span><span class="si">}</span><span class="s2"></span>
<span class="s2">	&gt;=virtual/jre-1.8&quot;</span>
<span class="nv">DEPEND</span><span class="o">=</span><span class="s2">&quot;</span>
<span class="s2">	</span><span class="si">${</span><span class="nv">CDEPEND</span><span class="si">}</span><span class="s2"></span>
<span class="s2">	&gt;=virtual/jdk-1.8&quot;</span>

<span class="nv">RESTRICT</span><span class="o">=</span><span class="s2">&quot;test&quot;</span>

src_prepare<span class="o">()</span> <span class="o">{</span>
	default
	find examples -type f -name <span class="se">\*</span>.xml -exec rm -v <span class="o">{}</span> <span class="se">\;</span> <span class="o">||</span> die
<span class="o">}</span>

src_install<span class="o">()</span> <span class="o">{</span>
	default

	<span class="c1"># maintainer&#39;s note: change/check me on version bumps</span>
	<span class="nb">local</span> <span class="nv">origin_version</span><span class="o">=</span><span class="s2">&quot;3.0.8&quot;</span>

	python_setup <span class="m">2</span>.7
	python_domodule pylib/cqlshlib

	dodoc -r lib/licenses

	insinto /etc/scylla/cassandra
	doins conf/cassandra-env.sh
	doins conf/logback.xml
	doins conf/logback-tools.xml
	doins conf/jvm.options

	insinto /etc/bash_completion.d
	doins dist/common/nodetool-completion

	dobin bin/nodetool
	dobin bin/sstableloader
	dobin bin/cqlsh
	dobin bin/cqlsh.py

	dobin tools/bin/cassandra-stress
	dobin tools/bin/filter_cassandra_attributes.py
	dobin tools/bin/cassandra_attributes.py
	dobin tools/bin/cassandra-stressd
	dobin tools/bin/sstabledump
	dobin tools/bin/sstablelevelreset
	dobin tools/bin/sstablemetadata
	dobin tools/bin/sstablerepairedset

	insinto /usr/share/scylla/cassandra
	doins dist/common/cassandra.in.sh
	doins <span class="s2">&quot;build/apache-cassandra-</span><span class="si">${</span><span class="nv">origin_version</span><span class="si">}</span><span class="s2">-SNAPSHOT.jar&quot;</span>
	doins <span class="s2">&quot;build/apache-cassandra-thrift-</span><span class="si">${</span><span class="nv">origin_version</span><span class="si">}</span><span class="s2">-SNAPSHOT.jar&quot;</span>
	doins <span class="s2">&quot;build/scylla-tools-</span><span class="si">${</span><span class="nv">origin_version</span><span class="si">}</span><span class="s2">-SNAPSHOT.jar&quot;</span>
	doins build/tools/lib/stress.jar
	<span class="c1">#</span>
	dosym /usr/share/scylla/cassandra/apache-cassandra-<span class="si">${</span><span class="nv">origin_version</span><span class="si">}</span>-SNAPSHOT.jar /usr/share/scylla/cassandra/apache-cassandra.jar

	insinto /usr/share/scylla/cassandra/lib
	doins lib/*.jar
	doins lib/*.zip
<span class="o">}</span>
</pre></div>
</code></pre></td></tr></table>
</div> <!-- class=content -->
          </div>
        </div>
      </div>
    </div>

    <footer>
      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-offset-2 col-md-7">
            &nbsp;
          </div>
          <div class="col-xs-12 col-md-3">
            <h3 class="footerhead">Questions or comments?</h3>
            Please feel free to <a href="https://www.gentoo.org/inside-gentoo/contact/">contact us</a>.
          </div>
        </div>
        <div class="row">
          <div class="col-xs-2 col-sm-3 col-md-2">
            <ul class="footerlinks three-icons">
              <li><a href="https://twitter.com/gentoo" title="@Gentoo on Twitter"><span class="fa fa-twitter fa-fw"></span></a></li>
              <li><a href="https://plus.google.com/+Gentoo" title="+Gentoo on Google+"><span class="fa fa-google-plus fa-fw"></span></a></li>
              <li><a href="https://www.facebook.com/gentoo.org" title="Gentoo on Facebook"><span class="fa fa-facebook fa-fw"></span></a></li>
            </ul>
          </div>
          <div class="col-xs-10 col-sm-9 col-md-10">
            <strong>&copy; 2001&ndash;2018 Gentoo Foundation, Inc.</strong><br>
            <small>
              Gentoo is a trademark of the Gentoo Foundation, Inc.
              The contents of this document, unless otherwise expressly stated, are licensed under the
              <a href="https://creativecommons.org/licenses/by-sa/3.0/" rel="license">CC-BY-SA-3.0</a> license.
              The <a href="https://www.gentoo.org/inside-gentoo/foundation/name-logo-guidelines.html">Gentoo Name and Logo Usage Guidelines</a> apply.
            </small>
          </div>
        </div>
      </div>
    </footer>

    <script src="https://assets.gentoo.org/tyrian/jquery.min.js"></script>
    <script src="https://assets.gentoo.org/tyrian/bootstrap.min.js"></script>
</div> <!-- id=cgit -->
</body>
</html>
