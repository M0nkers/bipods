;WUDSN IDE BIPODS
;5 Feb 2023 - damn, I'm not taking into account that the lo/hi lookups should be making use of a lo-res screen.

			org 	16384 ;Start of executable program
		
			genflag1	=	1792
			vtemp1		=	1793
			vtemp2		=	1794
			vtemp3		=	1795
			mbad		=	1796
			ppody		=	1797
			cppody		=	1798
			cppodx		=	1799
			mbx			=	1800
			mby			=	1801
			ftx			=	1802
			mbfr		=	1803
			tempx		=	1804
			tempy		=	1805
			tempchar	=	1806
			ftdelay		=	1807
			famount1	=	1808
			famount2 	=	1809
			mbmx		=	1810
			mbmy		=	1811
			mfr			=	1812
			vexpdel		=	1813
			vexppos		=	1814
			vexpy		=	1815
			hdelay1		=	1816
			hdelay2		=	1817
			bcount		=	1818
			bcdown		=	1819
			bpadel		=	1820
			charpos		=	1821
			temppos		=	1822
			nodiff		=	1823
			mbdown		=	1824
			fill		=	1825
			mxchar		=	1826
			mychar		=	1827
			shdel		=	1828
			bxchar		=	1829
			bychar		=	1830
			genflag3	=	1831
			bexppos		=	1832
			bexpdel		=	1833
			bexpy		=	1834
			m_sc1		=	1835
			m_sc2		=	1836
			m_sc3		=	1837
			m_sc4		=	1838
			m_sc5		=	1839
			m_sc6		=	1840
			m_sc7		=	1841
			m_samnt		=	1842
			m_sindex	=	1843
			m_lives		=	1844
			mbdelay		=	1845
			mbid		=	1846
			ftexpdel	=	1847
			ftexppos	=	1848
			ppdel1		=	1849
			ppdel2		=	1850
			mcdel1		=	1851
			mcdel2		=	1852
			genflag2	=	1853
			ppodcount	=	1854
			ppodgcount	=	1855
			bpdir		=	1856
			bipodac		=	1857
			ppodhcount	=	1858
			;look ups
			g_sclo		= 	34000	;24 bytes
			g_schi		=	34024	;24 bytes
			g_xchar		=	34048	;160 bytes
			g_ychar		=	34208	;192 bytes
			g_ppodx		=	34400		
			g_ppody		=	34415
			g_ppodstat	=	34430
			g_bipodx	=	37000
			g_bipody	=	37030
			g_bipodst	=	37060
			g_bipodht	=	37090
			bipodmx		=	38020
			bipodmy		=	38023
			bipodmpl	=	38026
			bipodfll	=	38029
			bipodmix	=	38032
			bipodmiy	=	38035
			bipodmit 	=	38038
			g_lppodx	=	35000
			g_lppody	=	35060
			g_lppodgot	=	35120
			;bipod status flag info
			;bit 0 bipod enable
			;bit 1 bipod left enabled
			;bit 2 bipod right enabled
			;bit 3 bipod up enabled
			;bit 4 bipod down enabled
			;bit 5 bipod looking for fuel truck
			charset		=	38912
			;status flag info for genflag1
			;bit 0 = pod landing sequence in progress
			;bit 1 = a pod is currently landing
			;bit 2 = player is firing a missile
			;bit 3 = player is out of fuel
			;bit 4 = player is exploding
			;bit 5 = pods hatching
			;bit 6 = fuel truck exploding
			;bit 7 = missile base protected
			;status flag info for genflag2
			;bit 0 change bipod movement type enabled
			;bit 1 missile 1 enabled
			;bit 2 missile 2 enabled
			;bit 3 missile 3 enabled
			;bit 4 generating parent pod locations
			;bit 5 game over
			;DO NOT USE zero page addresses 208 & 209 - they are EVIL
			m_zerop1	=	206
			m_zerop2	=	207
			m_zerop3	=	204
			m_zerop4	=	205
			m_zerop5	=	82
			m_zerop6	=	83
start 		;populate screen y lookups
			lda		#0
			sta		m_zerop1
			lda		#128
			sta		m_zerop2
			ldx		#0
fill1		lda		m_zerop1
			sta		g_sclo,X
			lda		m_zerop2
			sta		g_schi,X
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			inx
			cpx		#24
			bne		fill1
			;populate screen x character positions
			ldx		#0
fill2		txa
			lsr
			lsr
			lsr
			clc
			sta		g_xchar,X
			inx
			cpx		#160
			bne		fill2
			ldx		#0
fill3		txa
			lsr
			lsr
			lsr
			clc
			sta		g_ychar,X
			inx
			cpx		#192
			bne		fill3
			lda		#9
			sta		m_lives
			jsr		initgamescr
			lda		#16
			sta		genflag2
			lda		#1
			sta		ppodcount
			jsr		setwavd
			;init vbi
			lda		#7
			ldx		#32
			ldy		#0
			jsr		58460
loop		lda		genflag2
			and		#16
			cmp		#16
			bne		mnotgen
			jsr		poppod
mnotgen		lda		genflag2
			and		#32
			cmp		#32
			bne		notgo
			lda		646
			bne		mnotgen
			lda		#9
			sta		m_lives
			lda		#0
			sta		m_sc1
			sta		m_sc2
			sta		m_sc3
			sta		m_sc4
			sta		m_sc5
			sta		m_sc6
			sta		m_sc7
			jsr		showscore
			jsr		clearup
			lda		#1
			sta		ppodcount
			jsr		setwavd
			lda		#33
			sta		genflag1
			lda		#16
			sta		genflag2
notgo		jmp		loop

clearup		lda		#0
			sta		vtemp1
clloop		ldx		vtemp1
			lda		g_ppody,X
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_ppodx,X
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			lda		#0
			sta		(m_zerop1),Y
			inc		vtemp1
			lda		vtemp1
			cmp		ppodcount
			bne		clloop
			lda		#0
			sta		vtemp1
			lda		bcount
			bne		clloop1
			rts
clloop1		ldx		vtemp1
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			inc		vtemp1
			lda		vtemp1
			cmp		bcount
			bne		clloop1
			rts

poppod		lda		#0
			sta		ppodgcount
			ldx		#0
clpplp		lda		#0
			sta		g_lppodgot,X
			inx
			cpx		#60
			bne		clpplp
popst		ldx		#0
poplp		lda		53370
			sec
			sbc		53770
			bcc		igpop
			lda		g_lppodgot,X
			bne		igpop
			ldy		ppodgcount
			lda		g_lppodx,X
			sta		g_ppodx,Y
			lda		g_lppody,X
			sta		g_ppody,Y
			lda		#1
			sta		g_ppodstat,Y
			sta		g_lppodgot,X
			inc		ppodgcount
			lda		ppodgcount
			cmp		ppodcount
			beq		expoplp		
igpop		inx
			cpx		#60
			bne		poplp
			lda		ppodgcount
			cmp		ppodcount
			bne		popst
expoplp		jsr		setwavd
			lda		ppodcount
			asl
			sta		bipodac
			lda		#33
			sta		genflag1
			lda		genflag2
			eor		#16
			sta		genflag2
			rts

;this will reset various variables that need resetting			
setwavd		ldy		mby
			ldx		#0
			lda		#0
			sta		31743,Y
cmblp		sta		31744,Y
			iny
			inx
			cpx		#8
			bne		cmblp
			sta		31744,Y
			lda		#192
			sta		mbx
			sta		53248
			sta		mby
			ldx		#0
			ldy		mby
mblp		lda		39104,X
			sta		31744,Y
			inx
			iny
			cpx		#8
			bne		mblp
			ldx		#0
			ldy 	#160
eftrlp		lda		#0
			sta		32000,Y
			sta		32256,Y
			inx
			iny
			cpx		#8
			bne		eftrlp
			lda		#56
			sta		53249
			lda		#64
			sta		53250
			lda		#8
			sta		mbdown
			lda		#255
			sta		famount1
			lda		#4
			sta		famount2
			lda		#0
			sta		mbfr
			sta		mfr
			sta		mbid
			sta		mbad
			sta		bcount
			sta		ppodhcount
			sta		genflag3
			lda		#4
			sta		bpadel
			lda		#9
			sta		bcdown
			lda		#2
			sta		mbdelay
			lda		#0
			sta		mcdel1
			sta		704
			sta		707
			lda		#8
			sta		mcdel2
			lda		#255
			sta		hdelay1
			lda		#3
			sta		hdelay2
			lda		#255
			sta		famount1
			lda		#4
			sta		famount2
			lda		#56
			sta		ftx
			lda		#8
			sta		ftdelay
			rts

initgamescr	lda		#33
			sta		genflag1	
			lda		#64
			sta		54286
			lda		#0
      		sta 	559
	  		lda		#0
			sta		560
			lda		#6
			sta		561
			lda		#3
			sta		53277
			lda		#15
			sta		711
			lda		#120
			sta		54279
			lda		#17
			sta		623
			lda		#0
			sta		53278
			lda		#152
			sta		756
			lda		#15
			sta		712
			lda		#0
			sta		708
			sta		704
			sta		705
			sta		706
			sta		707
			sta		711
			lda		#192
			sta		mbx
			sta		mby
			sta		53248
			lda		#62
			sta		559
			jsr		showscore
			ldx		#0	
			lda		#12
			sta		bipodmpl,X
			lda		#2
			sta		bipodfll,X
			inx
			lda		#48
			sta		bipodmpl,X
			lda		#4
			sta		bipodfll,X
			inx
			lda		#192
			sta		bipodmpl,X
			lda		#8
			sta		bipodfll,X		
			;init dli
			;lda		#0
			;sta		512
			;lda 	#8
			;sta		513
			;lda		#192
			;sta		54286
			rts			
			
				
showscore	ldx		#0
showsloop	lda		m_sc1,X
			clc		
			adc		#6
			sta		33228,X
			inx
			cpx		#7
			bne		showsloop
			lda		m_lives
			clc
			adc		#6
			sta		33247
			rts
			
managepts	ldx		m_sindex
			lda		m_sc1,X
			clc
			adc		m_samnt
			sta		m_sc1,X
			sbc		#9
			bpl		mptslp
			lda		#0
			sta		m_samnt
			rts
mptslp		lda		m_sc1,X
			sec
			sbc		#10
			sta		m_sc1,X
			dex
			cpx		#255
			bne		mpts1
			lda		#0
			sta		m_samnt
			rts
mpts1		cpx		#2
			bne		notexl
			lda		m_lives
			cmp		#9
			beq		notexl
			inc		m_lives
notexl		lda		m_sc1,X
			clc
			adc		#1
			sta		m_sc1,X
			sbc		#9
			bpl		mptslp
			lda		#0
			sta		m_samnt
			rts
			

;display list interrupt for game over
;			org 6656
;			pha
;			txa
;			pha		
			;kernel
;			lda		54283
;			sec
;			sbc		#16
;			bpl		exdligo
;			ldx		#0
;			stx		godli_index
;			dec		go_colour
;gokl		lda		go_colour
;			clc
;			adc		godli_index
;			sta		54282
;			sta		53270
;			inx
;			inc		godli_index
;			cpx		#176
;			bne		gokl
;exdligo		pla
;			tax
;			pla
;			rti
	
;display list interrupt for game title
;			org 7168
;			pha
;			txa
;			pha
;			ldx		#0
;			stx		godli_index	
;			dec		go_colour
			;kernel
;tskl		lda		go_colour
;			clc
;			adc		godli_index
;			sta		54282
;			sta		53270
;			inx
;			inc		godli_index
;			cpx		#32
;			bne		tskl
;exdlits		pla
;			tax
;			pla
;			rti	

;display list interrupt for game
;			org	2048
			;just a note here for dealing with dlis
			;you only want to look the colour/horiz offset/whatever
			;per 8 scan lines. Otherwise you will get wscan weirdness
;			pha
;			txa
;			pha
;			ldx		dli_index
;nokernel1	lda		spcolour,X
;			sta		53266
;			sta		53267
;			sta		53268
;			lda		spritex,X
;			sta		53248
;			clc
;			adc		#8
;			sta		53249
;			adc		#8
;			sta		53250
;			lda		colour1,X
;			sta		53270
;			lda		colour2,X
;			sta		53271
;			lda		colour3,X
;			sta		53272
;			lda		colour4,X
;			sta		53274
;			lda		hscroll,X
;			sta		54276
			;this is handy - using
			;a lookup list involving custom character sets
			;can lead to grief. That stuff don't wanna be changed too often
;			lda		54283
;			sec
;			sbc		#32
;			bpl		docust
;			lda		#224
;			sta		54281
;			clc
;			bcc 	dlifin
;docust		lda		#152
;			sta		54281			
;dlifin		sta		54282
;			inc 	dli_index
;			lda		dli_index
;			cmp		#8
;			bne		exit3
;			lda		#0
;			sta		dli_index
;exit3		pla
;			tax
;			pla
;			rti
		
			org	8192
			;here is our deferred vertical blank interrupt which
			;will likely be doing a lot of things
			;the first check is to see if we have
			;finished clearing the screen.
			;Can't do anything while this is going on
mainvbi		lda		#0
			sta		77
			dec		711
mainvbi3	lda		genflag2
			and		#16
			cmp		#16
			bne		notgen
			jmp		58466
notgen		lda		genflag2
			and		#32
			cmp		#32
			bne		notgen2
			jmp		58466
notgen2		lda		genflag1
			and		#1
			cmp		#1
			bne		notland
			jsr		landing
			jmp		58466
notland		lda		genflag1
			and		#16
			cmp		#16
			beq		noexpmb
			jsr		movemb
			jsr		drawmb
			jsr		chkfire
noexpmb		jsr		mbexplode
			jsr		moveft
			lda		genflag1
			and		#32
			cmp		#32
			bne		finish
			jsr		hatch
finish		jsr		bcmov
			jsr		drawbpa
			jsr		movebp
			jsr		bskuff	
			jsr		ftexp
			jsr		mchange
			jsr		bipodmsl
			jsr		wavclr
			jsr		waitgo
finish2		jmp		58466


bcmov		lda		bcdown
			cmp		#9
			beq		bcmov1
			rts
bcmov1		lda		bcount
			bne		bcmov2
			rts
bcmov2		lda		#0
			sta		vtemp1
			lda		#95
			sta		fill
			lda		mbmx
			sec
			sbc		#48
			tax
			lda		g_xchar,X
			sta		mxchar
			lda		mbmy
			sec
			sbc		#32
			tax
			lda		g_ychar,X
			sta		mychar
bmovlp		ldx		vtemp1
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		cbs1
			jmp		bcmov3
cbs1		lda		g_bipodst,X
			and		#2
			cmp		#2
			bne		cbs2
			lda		g_bipodst,X
			eor		#2
			sta		g_bipodst,X
cbs2		lda		g_bipodst,X
			and		#4
			cmp		#4
			bne		cbs3
			lda		g_bipodst,X
			eor		#4
			sta		g_bipodst,X
cbs3		lda		g_bipodst,X
			and		#8
			cmp		#8
			bne		cbs4
			lda		g_bipodst,X
			eor		#8
			sta		g_bipodst,X
cbs4		lda		g_bipodst,X
			and		#16
			cmp		#16
			bne		cbs5
			lda		g_bipodst,X
			eor		#16
			sta		g_bipodst,X
cbs5		lda		genflag2
			and		#1
			cmp		#1
			bne		nochdir
			lda		g_bipodst,X
			eor		#32
			sta		g_bipodst,X
nochdir		lda		genflag2
			and		#2
			cmp		#2
			beq		nomiss1
			lda		53770
			sec
			sbc		53770
			bcs		nomiss1
			lda		genflag2
			ora		#2
			sta		genflag2
			ldy		#0
			lda		g_bipodx,X
			clc
			adc		#52
			sta		bipodmx,Y
			lda		g_bipody,X
			clc
			adc		#36
			sta		bipodmy,Y
			jsr		bsetmsl
nomiss1		lda		genflag2
			and		#4
			cmp		#4
			beq		nomiss2
			lda		53770
			sec
			sbc		53770
			bcs		nomiss2
			lda		genflag2
			ora		#4
			sta		genflag2
			ldy		#1
			lda		g_bipodx,X
			clc
			adc		#52
			sta		bipodmx,Y
			lda		g_bipody,X
			clc
			adc		#36
			sta		bipodmy,Y
			jsr		bsetmsl		
nomiss2		lda		genflag2
			and		#8
			cmp		#8
			beq		nomiss3
			lda		53770
			sec
			sbc		53770
			bcs		nomiss3
			lda		genflag2
			ora		#8
			sta		genflag2
			ldy		#2
			lda		g_bipodx,X
			clc
			adc		#52
			sta		bipodmx,Y
			lda		g_bipody,X
			clc
			adc		#36
			sta		bipodmy,Y
			jsr		bsetmsl
nomiss3		lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			;checkht knows we are looking at just one character block for the bipod
			lda		#0
			sta		bpdir
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		cbs7
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
cbs7		lda		g_bipodst,X
			and		#32
			cmp		#32
			beq		folft
			lda		mbx
			sec
			sbc		#48
			sta		vtemp2
			lda		mby
			sec
			sbc		#32
			sta		vtemp3
			clc
			bcc		bxdiff
folft		lda		53770
			sta		vtemp2
			lda		53770
			sta		vtemp3
bxdiff		lda		g_bipodx,X
			sta		temppos
			jsr		checkx
			ldx		vtemp1
			lda		nodiff
			bne		xdiff
			jmp		nodec2
xdiff		lda		g_bipodx,X
			sec
			sbc		vtemp2
			bcs		nodec1
			lda		g_bipodx,X
			clc
			adc		#8
			sta		tempx
			lda		g_bipody,X
			sta		tempy
			jsr		checkchar
			ldx		vtemp1
			lda		tempchar
			bne		nostat1
			lda		g_bipodst,X
			ora		#4
			sta		g_bipodst,X
			jmp		bcmov3
nostat1		jmp		nodec2
nodec1		ldx		vtemp1
			lda		g_bipodx,X
			sec
			sbc		#8
			sta		tempx
			lda		g_bipody,X
			sta		tempy
			jsr		checkchar
			lda		tempchar
			bne		nostat2
			ldx		vtemp1
			lda		g_bipodst,X
			ora		#2
			sta		g_bipodst,X
			jmp		bcmov3
nostat2		jmp		nodec3
nodec2		ldx		vtemp1
			lda		g_bipody,X
			sta		temppos
			jsr		checky
			ldx		vtemp1
			lda		nodiff
			bne		ydiff
			jmp		bcmov3
ydiff		lda		g_bipody,X
			sec
			sbc		vtemp3
			bcs		nodec3
			lda		g_bipody,X
			clc
			adc		#8
			sta		tempy
			lda		g_bipodx,X
			sta		tempx
			jsr		checkchar
			ldx		vtemp1
			lda		tempchar
			bne		nostat3
			lda		g_bipodst,X
			ora		#8
			sta		g_bipodst,X
nostat3		jmp		bcmov3
nodec3		ldx		vtemp1
			lda		g_bipody,X
			sec
			sbc		#8
			sta		tempy
			lda		g_bipodx,X
			sta		tempx
			jsr		checkchar
			lda		tempchar
			bne		bcmov3
			ldx		vtemp1
			lda		g_bipodst,X
			ora		#16
			sta		g_bipodst,X
bcmov3		inc		vtemp1
			lda		vtemp1
			cmp		bcount
			beq		bcmov4
			jmp		bmovlp
bcmov4		lda		#0
			sta		bcdown
			lda		genflag2
			and		#1
			cmp		#1
			bne		exbcmov
			lda		genflag2
			eor		#1
			sta		genflag2
exbcmov		rts
	
bsetmsl		lda		#0
			sta		bipodmit,Y		
			lda		53770
			sec
			sbc		53770
			bcc		bmfft
			lda		53770
			sec
			sbc		53770
			bcc		noxf
			lda		#1
			sta		bipodmit,Y
noxf		lda		bipodmx,Y
			sec
			sbc		mbx
			bcc		hmbr
			lda		#0
			sta		bipodmix,Y	
			clc
			bcc		hmbu
hmbr		lda		#1
			sta		bipodmix,Y
hmbu		lda		53770
			sec
			sbc		53770
			bcc		noyf
			lda		bipodmit,Y
			clc
			adc		#1
			sta		bipodmit,Y
noyf		lda		bipodmy,Y
			sec
			sbc		mby
			bcc		hmbd
			lda		#0
			sta		bipodmiy,Y
			rts
hmbd		lda		#1
			sta		bipodmiy,Y
			rts
bmfft		lda		bipodmx,Y
			sec
			sbc		ftx
			bcc		hftr
			lda		#0
			sta		bipodmix,Y	
			clc
			bcc		hftu
hftr		lda		#1
			sta		bipodmix,Y
hftu		lda		bipodmy,Y
			sec
			sbc		#160
			bcc		hftd
			lda		#0
			sta		bipodmiy,Y
			rts
hftd		lda		#1
			sta		bipodmiy,Y
			rts	
			
movebp		lda		bcdown
			cmp		#8
			beq		mdelay
			rts
mdelay		dec		bpadel
			lda		bpadel
			beq		movebp1
			rts
movebp1		lda		#4
			sta		bpadel
			lda		bcount
			bne		movebp2
			rts
			;checkht needs to know that only one bipod chracter position needs to be checked
movebp2		lda		#0
			sta		bpdir
			lda		#0
			sta		vtemp1
			lda		mbmx
			sec
			sbc		#48
			tax
			lda		g_xchar,X
			sta		mxchar
			lda		mbmy
			sec
			sbc		#32
			tax
			lda		g_ychar,X
			sta		mychar
movebplp	ldx		vtemp1
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		contmov
			jmp		movebp8
contmov		lda		g_bipodst,X
			and		#4
			cmp		#4
			bne		movebp5
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			clc
			adc		#8
			sta		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			ldx		vtemp1
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nosp1
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			jmp		movebp8
nosp1		ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			lda		#32
			sta		(m_zerop1),Y
			jmp		movebp8
movebp5		lda		g_bipodst,X
			and		#2
			cmp		#2
			bne		movebp6
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			sec
			sbc		#8
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			sec
			sbc		#8
			sta		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			ldx		vtemp1
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nosp2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			jmp		movebp8
nosp2		ldy		#0
			lda		#32
			sta		(m_zerop1),Y
			iny
			lda		#0
			sta		(m_zerop1),Y
			jmp		movebp8
movebp6		lda		g_bipodst,X
			and		#8
			cmp		#8
			beq		gtg1
			jmp		movebp7
gtg1		lda		g_bipody,X
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			ldx		vtemp1
			lda		g_bipody,X
			clc
			adc		#8
			sta		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nosp3
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#0
			sta		(m_zerop1),Y
			jmp		movebp8
nosp3		ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#32
			sta		(m_zerop1),Y
			jmp		movebp8
movebp7		lda		g_bipodst,X
			and		#16
			cmp		#16
			beq		gtg		
			jmp		movebp8
gtg			lda		g_bipody,X
			sec	
			sbc		#8
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipody,X
			sec
			sbc		#8
			sta		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nosp4
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#0
			sta		(m_zerop1),Y
			clc
			bcc		movebp8
nosp4		ldy		#0
			lda		#32
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#0
			sta		(m_zerop1),Y
movebp8		inc		vtemp1
			lda		vtemp1
			cmp		bcount
			beq		movebp9
			jmp		movebplp
movebp9		inc		bcdown
			rts
			
drawbpa		lda		bcdown
			cmp		#8
			bne		other
			rts
other		cmp		#9
			bne		drawbpa1
			rts
drawbpa1	lda		bcount
			bne		drawbpa2
			rts
drawbpa2	dec		bpadel
			lda		bpadel
			beq		drawbpa3
			rts
drawbpa3	lda		#4
			sta		bpadel
			lda		#0
			sta		vtemp1
			lda		mbmx
			sec
			sbc		#48
			tax
			lda		g_xchar,X
			sta		mxchar
			lda		mbmy
			sec
			sbc		#32
			tax
			lda		g_ychar,X
			sta		mychar
drawbpalp	ldx		vtemp1
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		contdraw
			jmp		drawbpa9
contdraw	lda		g_bipodst,X
			and		#2
			cmp		#2
			bne		drawbpa6
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			sec
			sbc		#8
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			;chekht looking only in both bipod horizontal positions
			lda		#1
			sta		bpdir
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nospace1
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			jmp		drawbpa9
nospace1	ldy		#0
			ldx		bcdown
			lda		36016,X
			sta		(m_zerop1),Y
			lda		36024,X
			iny
			sta		(m_zerop1),Y
			jmp		drawbpa9
drawbpa6	lda		g_bipodst,X
			and		#4
			cmp		#4
			bne		drawbpa7
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			;chekht looking only in both bipod horizontal positions
			lda		#1
			sta		bpdir
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nospace2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			jmp		drawbpa9
nospace2	ldy		#0
			ldx		bcdown
			lda		36000,X
			sta		(m_zerop1),Y
			lda		36008,X
			iny
			sta		(m_zerop1),Y
			jmp		drawbpa9
drawbpa7	lda		g_bipodst,X
			and		#8
			cmp		#8
			bne		drawbpa8
			lda		g_bipody,X
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			;chekht looking only in both bipod vertical positions
			lda		#2
			sta		bpdir
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nospace3
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#0
			sta		(m_zerop1),Y
			jmp		drawbpa9
nospace3	ldy		#0
			ldx		bcdown
			lda		36032,X
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		36040,X
			sta		(m_zerop1),Y
			jmp		drawbpa9
drawbpa8	lda		g_bipodst,X
			and		#16
			cmp		#16
			bne		drawbpa9
			lda		g_bipody,X
			sec		
			sbc		#8
			tax
			lda		g_ychar,X
			sta		bychar
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_bipodx,X
			tax
			lda		g_xchar,X
			sta		bxchar
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			;chekht looking only in both bipod vertical positions
			lda		#2
			sta		bpdir
			jsr		checkht
			lda		g_bipodst,X
			and		#1
			cmp		#1
			beq		nospace4
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		#0
			sta		(m_zerop1),Y
			jmp		drawbpa9
nospace4	ldy		#0
			ldx		bcdown
			lda		36048,X
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			lda		36056,X
			sta		(m_zerop1),Y
drawbpa9	inc		vtemp1
			lda		vtemp1
			cmp		bcount
			beq		drawbpa10
			jmp		drawbpalp
drawbpa10	inc		bcdown
			rts

;missile to bipod collision
checkht		ldx		vtemp1
			lda		genflag1
			and		#4
			cmp		#4
			beq		checkht1
			rts
checkht1	ldy		#0
			lda		bpdir
			bne		checkht2
			lda		bxchar
			cmp		mxchar
			bne		sht2
			iny
sht2		lda		bychar
			cmp		mychar
			bne		sht3
			iny
sht3		cpy		#2
			beq		gotht
			rts
			;looking at both horizontal positions + single vertical position
checkht2	cmp		#2
			beq		checkht3
			lda		bxchar
			cmp		mxchar
			bne		hht2
			iny
hht2		clc
			adc		#1
			cmp		mxchar
			bne		hht3
			iny
hht3		lda		bychar
			cmp		mychar
			bne		hht4
			iny
hht4		cpy		#2
			beq		gotht
			rts
			;looking at both vertical positionsd + single horizontal position
checkht3	lda		bxchar
			cmp		mxchar
			bne		vht2
			iny
vht2		lda		bychar
			cmp		mychar
			bne		vht3
			iny
vht3		clc
			adc		#1
			cmp		mychar
			bne		vht4
			iny
vht4		cpy		#2
			beq		gotht
			rts
gotht		ldy		mbmy
			lda		31487,Y
			and		#3
			cmp		#3
			bne		stomsl2
			lda		31487,Y
			eor		#3
			sta		31487,Y
stomsl2		lda		31488,Y
			and		#3
			cmp		#3
			bne		stomsl3
			lda		31488,Y
			eor		#3
			sta		31488,Y
stomsl3		lda		31489,Y
			and		#3
			cmp		#3
			bne		stomsl4
			lda		31489,Y
			eor		#3
			sta		31489,Y
stomsl4		lda		#0
			sta		53252
			lda		genflag1
			eor		#4
			sta		genflag1
			lda		g_bipodht,X
			beq		ht5
			lda		mbmx
			sta		53251
			lda		mbmy
			sta		bexpy
			lda		#0
			sta		bexppos
			lda		#8
			sta		bexpdel
			lda		#1
			sta		genflag3
			lda		#0
			sta		707
			lda		#1
			sta		m_samnt
			lda		#4
			sta		m_sindex
			jsr		managepts
			jsr		showscore
			ldx		vtemp1
			dec		g_bipodht,X
			lda		g_bipodht,X
			clc
			adc		#6
			;sta		33238
			cmp		#6
			bne		ht5
			lda		g_bipodst,X
			eor		#1
			sta		g_bipodst,X
			lda		bipodac
			beq		nodecbac
			dec		bipodac
nodecbac	inc		genflag3
			lda		#223
			sta		707
			lda		#1
			sta		m_samnt
			lda		#4
			sta		m_sindex
			jsr		managepts
			jsr		showscore
			ldx		vtemp1
ht5			rts

hatch		dec		hdelay1
			lda		hdelay1
			beq		hatch1
			rts
hatch1		dec		hdelay2
			lda		hdelay2
			beq		hatch2				
			rts
hatch2		lda		#3
			sta		hdelay2
			lda		#0
			sta		vtemp1
hatchlp		ldx		vtemp1
			lda		g_ppodstat,X
			and		#1
			cmp		#1
			beq		hatch3
			jmp		hatch5
hatch3		lda		g_ppodstat,X
			and		#4
			cmp		#4
			bne		hatch4
			jmp		hatch5
hatch4		lda		g_ppody,X
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		vtemp1
			lda		g_ppodx,X
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			lda		#0
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#32
			sta		(m_zerop1),Y
			iny
			lda		#32
			sta		(m_zerop1),Y
			ldx		vtemp1
			lda		g_ppodstat,X
			ora		#4
			sta		g_ppodstat,X
			ldy		bcount
			lda		g_ppodx,X
			sta		g_bipodx,Y
			lda		g_ppody,X
			clc
			adc		#8
			sta		g_bipody,Y
			lda		#1
			sta		g_bipodst,Y
			lda		#3
			sta		g_bipodht,Y
			iny
			lda		g_ppodx,X
			clc
			adc		#8
			sta		g_bipodx,Y
			lda		g_ppody,X
			clc
			adc		#8
			sta		g_bipody,Y
			lda		#33
			sta		g_bipodst,Y
			lda		#3
			sta		g_bipodht,Y
			lda		bcount
			clc
			adc		#2
			sta		bcount
			inc		ppodhcount
			clc
			bcc		hatch6
hatch5		inc		vtemp1
			lda		vtemp1
			cmp		ppodcount
			beq		hatch6
			jmp		hatchlp
hatch6		lda		ppodhcount
			cmp		ppodcount
			bne		hatch7
			lda		genflag1
			and		#32
			cmp		#32
			bne		hatch7
			lda		genflag1
			eor		#32
			sta		genflag1
hatch7		rts

landing		lda		genflag1
			and		#2
			cmp		#2			
			bne		getland
			jsr		drawland
			rts
getland		ldx		#0
			stx		vtemp1
lloop		lda		g_ppodstat,X
			and		#1
			cmp		#1
			bne		exlandlp1
			lda		g_ppodstat,X
			and		#2
			cmp		#2
			beq		exlandlp1
			lda		genflag1
			ora		#2
			sta		genflag1
			lda		g_ppodx,X
			clc
			adc		#48
			sta		cppodx
			sta		53249
			adc		#8
			sta		53250
			lda		g_ppody,X
			clc
			adc		#32
			sta		cppody
			lda		#0
			sta		ppody
			lda		#1
			sta		vtemp1
			lda		g_ppodstat,X
			ora		#2
			sta		g_ppodstat,X
			clc
			bcc		exlandlp2
exlandlp1	inx
			cpx		ppodcount
			bne		lloop
			lda		vtemp1
			bne		exlandlp2
			lda		genflag1
			eor		#1
			sta		genflag1
			//draw fuel truck now
			ldx		#0
			ldy 	#160
ftdrlp		lda		39144,X
			sta		32000,Y
			lda		39152,X
			sta		32256,Y
			inx
			iny
			cpx		#8
			bne		ftdrlp
			lda		#56
			sta		53249
			lda		#64
			sta		53250
			lda		#0
			sta		53278
exlandlp2	rts
			
drawland	ldx		#0
			ldy		ppody
			lda		#0
			sta		32000,Y
			sta		32256,Y
drawlp		lda		39072,X
			sta		32001,Y
			lda		39080,X
			sta		32009,Y
			lda		39088,X
			sta		32257,Y
			lda		39096,X
			sta		32265,Y
			inx
			iny
			cpx		#8
			bne 	drawlp
			inc		ppody
			lda		ppody
			cmp		cppody
			beq		exdrlp
			rts
exdrlp		lda		ppody
			sec
			sbc		#32
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			lda		cppodx
			sec
			sbc		#48
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#20
			sta		(m_zerop1),Y
			iny
			lda		#22
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#21
			sta		(m_zerop1),Y
			iny
			lda		#23
			sta		(m_zerop1),Y
			ldy		ppody
			lda		#0
erpplp		sta		32000,Y
			sta		32256,Y
			iny
			cpy		#16
			bne		erpplp	
			lda		genflag1
			eor		#2
			sta		genflag1
			rts
																

chkfire		lda		genflag1
			and		#4
			cmp		#4
			beq		movmsl1
			lda		genflag3
			bne		exfire
			lda		646
			bne		exfire
			lda		mbfr
			sta		mfr
			lda		genflag1
			ora		#4
			sta		genflag1
			lda		mbx
			clc
			adc		#4
			sta		mbmx
			lda		mby
			clc
			adc		#4
			sta		mbmy
			clc
			bcc		movmsl1
exfire		rts			
movmsl1		lda		mbmx
			sta		53252
			ldy		mbmy
			lda		31487,Y
			and		#3
			cmp		#3
			bne		movmsl2
			lda		31487,Y
			eor		#3
			sta		31487,Y
movmsl2		lda		31488,Y
			ora		#3
			sta		31488,Y
			lda		31489,Y
			and		#3
			cmp		#3
			bne		movmsl3
			lda		31489,Y
			eor		#3
			sta		31489,Y
movmsl3		lda		mfr
			bne		movmsl4
			//missile going up
			dec		mbmy
			clc	
			bcc		chkcol
movmsl4		lda		mfr
			cmp		#8
			bne		movmsl5
			inc		mbmy
			clc
			bcc 	chkcol
movmsl5		lda		mfr
			cmp		#16
			bne		movmsl6
			dec		mbmx
			clc
			bcc		chkcol
movmsl6		inc		mbmx
chkcol		lda		mbmx
			sec
			sbc		#48
			sta		tempx
			lda		mbmy
			sec
			sbc		#32
			sta		tempy
			lda		#0
			sta		fill
			jsr		checkchar
			lda		tempchar
			bne		chkcol2
			rts
chkcol2		lda		tempchar
			sec
			sbc		#32
			bcc		stopmsl
			rts
stopmsl		ldy		mbmy
			lda		31487,Y
			and		#3
			cmp		#3
			bne		stopmsl2
			lda		31487,Y
			eor		#3
			sta		31487,Y
stopmsl2	lda		31488,Y
			and		#3
			cmp		#3
			bne		stopmsl3
			lda		31488,Y
			eor		#3
			sta		31488,Y
stopmsl3	lda		31489,Y
			and		#3
			cmp		#3
			bne		stopmsl4
			lda		31489,Y
			eor		#3
			sta		31489,Y
stopmsl4	lda		#0
			sta		53252
			lda		genflag1
			eor		#4
			sta		genflag1
			rts
			
drawmb		lda		genflag1
			and		#16
			cmp		#16
			bne		contdmb
			rts
contdmb		lda		m_lives
			bne		contdmb1
			rts
contdmb1	lda		mbx
			sta		53248	
			lda		#0
			ldy		mby
			sta		31743,Y
			ldx		mbfr
			lda		#0
			sta		vtemp1
			lda		genflag1
			and		#128
			cmp		#128
			bne		drawmblp
			dec		704
			lda		704
			cmp		#144
			bne		pp1
			lda		#159
			sta		704
pp1			inc		ppdel1
			lda		ppdel1
			bne		drawmblp
			dec		ppdel2
			lda		ppdel2
			bne		drawmblp
			lda		#0
			sta		704
			lda		genflag1
			eor		#128
			sta		genflag1
			lda		#0
			sta		53278
drawmblp	lda		39104,X
			sta		31744,Y
			inx
			iny
			inc		vtemp1
			lda		vtemp1
			cmp		#8
			bne		drawmblp
			lda		#0
			sta		31744,Y
drawmb1		lda		genflag1
			and		#16
			cmp		#16
			bne		hnddel
			rts
hnddel		dec		mbdelay
			lda		mbdelay
			beq		clrdel
			rts
clrdel		lda		#2
			sta		mbdelay			
drawmb2		lda		genflag1
			and		#128
			cmp		#128
			beq		drawmb3
			lda		53260
			and		#2
			cmp		#2
			beq		gotpcol
			lda		53260
			and		#4
			cmp		#4
			beq		gotpcol
			lda		genflag1
			and		#64
			cmp		#64
			beq		igpfcol
			lda		53252
			bne		gotpcol
igpfcol		lda		genflag1
			and		#8
			cmp		#8
			bne		drawmb3
			dec		704
			rts
gotpcol		lda		genflag1
			ora		#16
			sta		genflag1
			lda		#0
			sta		vexppos
			sta		53278
			lda		#8
			sta		vexpdel
			lda		#223
			sta		704
			lda		mby
			sta		vexpy
			rts
drawmb3		dec		famount1
			lda		famount1
			bne		drawmb4
			lda		#255
			sta		famount1
			dec		famount2
			lda		famount2
			bne		drawmb4
			lda		genflag1
			ora		#8
			sta		genflag1
			lda		#0
			sta		mbad
drawmb4		lda		mbad
			cmp		#1
			bne		drawmb5
			dec		mbx
			clc
			bcc		exdrawmb
drawmb5		lda		mbad
			cmp		#2
			bne		drawmb6
			inc		mbx
			clc
			bcc		exdrawmb
drawmb6		lda		mbad
			cmp		#4
			bne		drawmb7
			dec		mby
			clc
			bcc		exdrawmb
drawmb7		lda		mbad
			cmp		#8
			bne		exdrawmb
			inc		mby
exdrawmb	inc		mbdown
			rts

;check joystick horizontal
movemb		lda		#0
			sta		fill
			lda		mbdown
			cmp		#8
			beq		movemb5
			rts
movemb5		lda		#0
			sta		mbad
			sta		mbdown
			lda		632
			cmp		#11
			beq		left
			lda		632
			cmp		#7
			beq 	right
			clc
			bcc		chkvert
left		lda		#16
			sta		mbfr
			lda		#1
			sta		mbid
			clc
			bcc		chkbar
right		lda		#24
			sta		mbfr
			lda		#2
			sta		mbid	
			clc
			bcc		chkbar
chkvert		lda		632
			cmp		#14
			beq		up
			lda		632
			cmp		#13
			beq 	down
			clc
			bcc		chkbar
up			lda		#0
			sta		mbfr
			lda		#4
			sta		mbid
			clc		
			bcc		chkbar
down		lda		#8
			sta		mbfr
			lda		#8
			sta		mbid
chkbar		lda		mbid
			cmp		#1
			bne		chkbarr
			lda		mbx
			sec
			sbc		#56
			sta		tempx
			lda		mby
			sec
			sbc		#32
			sta		tempy
			jsr		checkchar
			lda		tempchar
			beq		chkbar1
			sec
			sbc		#32
			bcs		chkbar1
			rts
chkbar1		lda		#1
			sta		mbad
			rts
chkbarr		lda		mbid
			cmp		#2
			bne		chkbaru
			lda		mbx
			sec
			sbc		#40
			sta		tempx
			lda		mby
			sec
			sbc		#32
			sta		tempy
			jsr		checkchar
			lda		tempchar
			beq		chkbar2
			sec
			sbc		#32
			bcs		chkbar2
			rts
chkbar2		lda		#2
			sta		mbad
			rts	
chkbaru		lda		mbid
			cmp		#4
			bne		chkbard
			lda		mbx
			sec
			sbc		#48
			sta		tempx
			lda		mby
			sec
			sbc		#40
			sta		tempy
			jsr		checkchar
			lda		tempchar
			beq		chkbar3
			sec
			sbc		#32
			bcs		chkbar3
			rts
chkbar3		lda		#4
			sta		mbad
			rts	
chkbard		lda		mbid
			cmp		#8
			beq		chkbard1
			rts
chkbard1	lda		mbx
			sec
			sbc		#48
			sta		tempx
			lda		mby
			sec
			sbc		#24
			sta		tempy
			jsr		checkchar
			lda		tempchar
			beq		chkbar4
			sec
			sbc		#32
			bcs		chkbar4
			rts
chkbar4		lda		#8
			sta		mbad
			rts	

moveft		lda		genflag1
			and		#64
			cmp		#64
			bne		moveft1
			rts
moveft1		lda		ftx
			sta		53249
			clc
			adc		#8
			sta		53250
			lda		53253
			bne		ftcol
			lda		53256
			and		#2
			cmp		#2
			beq		ftcol
			lda		53256
			and		#4
			cmp		#4
			beq		ftcol
			lda		53254
			beq		moveft2
ftcol		lda		#0
			sta		53278
			lda		#223
			sta		705
			sta		706
			lda		#8
			sta		ftexpdel
			lda		#0
			sta		ftexppos
			lda		genflag1
			ora		#64
			sta		genflag1
			rts
moveft2		dec 	ftdelay
			lda		ftdelay
			bne		ftexit
			lda		#8
			sta		ftdelay
			inc		ftx
			lda		ftx
			cmp		#183
			bne		ftexit
			lda		#56
			sta		ftx
			lda		#4
			sta		famount2
			lda		#255
			sta		famount1
			lda		genflag1
			and		#8
			cmp		#8
			bne		ftexit
			lda		genflag1
			eor		#8
			sta		genflag1
			lda		#0
			sta		704
ftexit		rts
			
checkx		ldx		vtemp2
			lda		g_xchar,X
			sta		charpos
			ldx		temppos
			lda		g_xchar,X
			cmp		charpos
			beq		checkx1
			lda		#1
			sta		nodiff
			rts
checkx1		lda		#0
			sta		nodiff
			rts		
			
checky		ldx		vtemp3
			lda		g_ychar,X
			sta		charpos
			ldx		temppos
			lda		g_ychar,X
			cmp		charpos
			beq		checky1
			lda		#1
			sta		nodiff
			rts
checky1		lda		#0
			sta		nodiff
			rts		
			
checkchar	lda		tempy
			tax
			lda		g_ychar,X
			tax
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			lda		tempx
			tax
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		(m_zerop1),Y
			sta		tempchar
			bne		exchk
			lda		fill
			sta		(m_zerop1),Y
exchk		rts
			
mbexplode	lda		genflag1
			and		#16
			cmp		#16
			beq		mbexp1
			rts
mbexp1		lda		53770
			sta		54277
			lda		vexppos
			cmp		#48
			beq		mbexp5
mbexp2		dec		704
			lda		704
			cmp		#208
			bne		mbexp3
			lda		#223
			sta		704
mbexp3		dec		vexpdel
			lda		vexpdel
			beq		mbexp4
			rts
mbexp4		lda		#8
			sta		vexpdel
			sta		vtemp1
			ldy		vexpy
			ldx		vexppos
mbexplp		lda		2816,X
			sta		31744,Y
			inx
			iny
			dec		vtemp1
			lda		vtemp1
			bne		mbexplp
			lda		vexppos
			clc
			adc		#8
			sta		vexppos
			cmp		#48
			beq		mbexp5
			rts
mbexp5		lda		genflag1
			eor		#16
			sta		genflag1
			lda		mbx
			sta		53248
			ldy		mby
			ldx		#0
			lda		#0
			sta		31743,Y
emblp		sta		31744,Y
			iny
			inx
			cpx		#8
			bne		emblp
			sta		31744,Y
			sta		54277
			lda		#192
			sta		mbx
			sta		53248
			sta		mby
			lda		#8
			sta		mbdown
			lda		#255
			sta		famount1
			lda		#4
			sta		famount2
			ldy		mby
			ldx		#0
			stx		mbfr
			stx		mbid
			sta		mbad
			dec		m_lives
			jsr		showscore
			lda		m_lives
			beq		norsp
rpmblp		lda		39104,X
			sta		31744,Y
			iny
			inx
			cpx		#8
			bne		rpmblp
norsp		lda		genflag1
			and		#8
			cmp		#8
			bne		mbexp6
			lda		genflag1
			eor		#8
			sta		genflag1
mbexp6		lda		genflag1
			ora		#128
			sta		genflag1
			lda		#0
			sta		ppdel1
			lda		#3
			sta		ppdel2
			lda		#159
			sta		704
			lda		#0
			sta		53278
			rts
			
bskuff		lda		genflag3
			bne		bsk1
			rts
bsk1		lda		genflag3
			cmp		#1
			bne		bsk2
			lda		bexppos
			cmp		#32
			beq		bsk5
			clc
			bcc		bsk3
bsk2		lda		bexppos
			cmp		#48
			beq		bsk5
			dec		707
			lda		707
			cmp		#208
			bne		bsk3
			lda		#223
			sta		707
bsk3		dec		bexpdel
			lda		bexpdel
			beq		bsk4
			rts
bsk4		lda		#8
			sta		bexpdel
			sta		vtemp1
			ldy		bexpy
			ldx		bexppos
bsklp		lda		genflag3
			cmp		#1
			bne		getexp
			lda		2864,X
			clc
			bcc		drawskf
getexp		lda		2816,X
drawskf		sta		32512,Y
			inx
			iny
			dec		vtemp1
			lda		vtemp1
			bne		bsklp
			lda		bexppos
			clc
			adc		#8
			sta		bexppos
			lda		genflag3
			cmp		#1
			bne		comp2
			lda		bexppos
			cmp		#32
			beq		bsk5
			rts
comp2		lda		bexppos
			cmp		#48
			beq		bsk5
			rts
bsk5		lda		#0
			sta		genflag3
			lda		#0
			sta		53251
			rts
			
ftexp		lda		genflag1
			and		#64
			cmp		#64
			beq		ftexp1
			rts
ftexp1		lda		53770
			sta		54277
			lda		ftexppos
			cmp		#48
			beq		ftexp5
			dec		705
			dec		706
			lda		705
			cmp		#208
			bne		ftexp3
			lda		#223
			sta		705
			sta		706
ftexp3		dec		ftexpdel
			lda		ftexpdel
			beq		ftexp4
			rts
ftexp4		lda		#8
			sta		ftexpdel
			sta		vtemp1
			ldx		ftexppos
			ldy 	#160
ftexplp		lda		2816,X
			sta		32000,Y
			lda		2816,X
			sta		32256,Y
			inx
			iny
			dec		vtemp1
			lda		vtemp1
			bne		ftexplp
			lda		ftexppos
			clc
			adc		#8
			sta		ftexppos
			cmp		#48
			beq		ftexp5
			rts
ftexp5		lda		#0
			sta		54277
			sta		705
			sta		706
			ldx		#0
			ldy 	#160
ftrdrlp		lda		39144,X
			sta		32000,Y
			lda		39152,X
			sta		32256,Y
			inx
			iny
			cpx		#8
			bne		ftrdrlp
			lda		genflag1
			eor		#64
			sta		genflag1
			lda		#56
			sta		ftx
			sta		53249
			lda		#64
			sta		53250
			lda		#0
			sta		53278
			rts
			
mchange		inc		mcdel1
			lda		mcdel1
			bne		mchange2
			rts
mchange2	dec		mcdel2
			lda		mcdel2
			beq		mchange3
			rts
mchange3	lda		genflag2
			eor		#1
			sta		genflag2
			lda		#8
			sta		mcdel2
			rts
			
bipodmsl	lda		#0
			sta		vtemp1	
bmsllp		ldx		vtemp1
			lda		#0
			sta		vtemp2
			lda		genflag2
			and		bipodfll,X
			cmp		bipodfll,X
			beq		gotmsl
			jmp		nomsl
gotmsl		lda		bipodmx,X
			sta		53253,X
			ldy		bipodmy,X
			lda		31487,Y
			and		bipodmpl,X
			cmp		bipodmpl,X
			bne		bcm1
			lda		31487,Y		
			eor		bipodmpl,X
			sta		31487,Y
bcm1		lda		31488,Y
			ora		bipodmpl,X
			sta		31488,Y
			lda		31489,Y
			and		bipodmpl,X
			cmp		bipodmpl,X
			bne		bcm2
			lda		31489,Y
			eor		bipodmpl,X
			sta		31489,Y
bcm2		lda		bipodmit,X
			cmp		#2
			beq		bmup
			lda		bipodmix,X
			bne		bmright
			dec		bipodmx,X
			clc
			bcc		bmup
bmright		inc		bipodmx,X
bmup		lda		bipodmit,X
			cmp		#1
			beq		bmcont
			lda		bipodmiy,X
			bne		bmdown
			dec		bipodmy,X
			clc
			bcc		bmcont
bmdown		inc		bipodmy,X
bmcont		lda		bipodmx,X
			sec
			sbc		#48
			sta		tempx
			lda		bipodmy,X
			sec
			sbc		#32
			sta		tempy
			lda		#0
			sta		fill
			jsr		checkchar
			ldx		vtemp1
			lda		tempchar
			bne		bmhit
			clc	
			bcc		bmhit1
bmhit		lda		tempchar
			sec
			sbc		#32
			bcc		stopbmsl
bmhit1		lda		53257,X
			and		#1
			cmp		#1
			bne		sphit1
			lda		genflag1
			and		#16
			cmp		#16
			beq		stopbmsl
			lda		genflag1
			and		#128
			cmp		#128
			beq		stopbmsl
			lda		genflag1
			ora		#16
			sta		genflag1
			lda		#0
			sta		vexppos
			sta		53278
			lda		#8
			sta		vexpdel
			lda		#223
			sta		704
			lda		mby
			sta		vexpy
			clc
			bcc		stopbmsl
sphit1		lda		53257,X
			and		#2
			cmp		#2
			beq		hitft
			lda		53257,X
			and		#4
			cmp		#4
			bne		nomsl
hitft		lda		genflag1
			and		#64
			cmp		#64
			beq		stopbmsl
			lda		#0
			sta		53278
			lda		#223
			sta		705
			sta		706
			lda		#8
			sta		ftexpdel
			lda		#0
			sta		ftexppos
			lda		genflag1
			ora		#64
			sta		genflag1
stopbmsl	ldy		bipodmy,X
			lda		31487,Y
			and		bipodmpl,X
			cmp		bipodmpl,X
			bne		stopbmsl2
			lda		31487,Y
			eor		bipodmpl,X
			sta		31487,Y
stopbmsl2	lda		31488,Y
			and		bipodmpl,X
			cmp		bipodmpl,X
			bne		stopbmsl3
			lda		31488,Y
			eor		bipodmpl,X
			sta		31488,Y
stopbmsl3	lda		31489,Y
			and		bipodmpl,X
			cmp		bipodmpl,X
			bne		stopbmsl4
			lda		31489,Y
			eor		bipodmpl,X
			sta		31489,Y
stopbmsl4	lda		#0
			sta		53253,X
			lda		genflag2
			eor		bipodfll,X
			sta		genflag2
nomsl		inc		vtemp1
			lda		vtemp1
			cmp		#3
			beq		exbmsl
			jmp		bmsllp
exbmsl		rts

wavclr		lda		bipodac
			beq		nobipods
			rts
nobipods	lda		genflag1
			and		#1
			cmp		#1
			bne		wavclr1
			rts
wavclr1		lda		genflag1
			and		#16
			cmp		#16
			bne		wavclr2
			rts
wavclr2		lda		genflag1
			and		#32
			cmp		#32
			bne		wavclr3
			rts
wavclr3		lda		genflag1
			and		#64
			cmp		#64
			bne		wavclr4
			rts
wavclr4		lda		genflag2
			and		#2
			cmp		#2
			bne		wavclr5
			rts
wavclr5		lda		genflag2
			and		#4
			cmp		#4
			bne		wavclr6
			rts
wavclr6		lda		genflag2
			and		#8
			cmp		#8
			bne		wavclr7
			rts
wavclr7		lda		genflag1
			and		#4
			cmp		#4
			bne		wavclr8
			rts
wavclr8		lda		genflag1
			and		#128
			cmp		#128
			bne		wavclr9
			rts
wavclr9		lda		genflag3
			beq		wavclr10
			rts
wavclr10	lda		ppodcount
			cmp		#15
			beq		wavclr11
			inc		ppodcount
wavclr11	lda		genflag2
			ora		#16
			sta		genflag2
			rts
			
waitgo		lda		m_lives
			beq		waitgo1
			rts
waitgo1		lda		genflag1
			and		#16
			cmp		#16
			bne		waitgo2
			rts
waitgo2		lda		genflag1
			and		#64
			cmp		#64
			bne		waitgo3
			rts
waitgo3		lda		genflag2
			and		#2
			cmp		#2
			bne		waitgo4
			rts
waitgo4		lda		genflag2
			and		#4
			cmp		#4
			bne		waitgo5
			rts
waitgo5		lda		genflag2
			and		#8
			cmp		#8
			bne		waitgo6
			rts
waitgo6		lda		genflag1
			and		#4
			cmp		#4
			bne		waitgo7
			rts
waitgo7		lda		genflag3
			beq		waitgo8
			rts
waitgo8		lda		bcdown
			cmp		#9
			beq		waitgo9
			rts
waitgo9		lda		genflag2
			ora		#32
			sta		genflag2
			rts

;game data area
			org 1536
;game display list

.byte		112,112,112
.byte		102,0,128 ;line 0 
.byte 		38;line 1
.byte		38;line 2
.byte		38;line 3
.byte		38;line 4
.byte		38;line 5
.byte		38;line 6
.byte		38;line 7
.byte		38;line 8
.byte		38;line 9
.byte		38 ;line 10
.byte		38 ;line 11
.byte		38 ;line 12
.byte		38 ;line 13
.byte		38 ;line 14
.byte		38 ;line 15
.byte		38 ;line 16
.byte		38 ;line 17
.byte		38 ;line 18
.byte		38 ;line 19
.byte		38 ;line 20
.byte		38 ;line 21
.byte		38 ;line 22
.byte		38 ;line 23
.byte		65,0,6	;display list terminate

			org	32768 ;game screen

.byte		2,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,3
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,19
.byte		18,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19
.byte		4,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,5
.byte		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte		6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,24,28,15
			
			org	2816 
	
			;explosion frames
.byte		24,60,126,255,255,126,60,24
.byte		0,60,126,255,255,126,60,0
.byte		0,24,60,126,126,60,24,0
.byte		0,0,24,60,60,24,0,0
.byte		0,0,0,24,24,0,0,0
.byte		0,0,0,0,0,0,0,0
			;skuff frames
.byte		129,0,0,0,0,0,0,129
.byte		129,66,0,0,0,0,66,129
.byte		129,66,36,0,0,36,66,129
.byte		0,0,0,0,0,0,0,0

			org	36000 ;bipod animation sequences
			;horizontal motion right
.byte		32,34,36,38,40,42,44,46
.byte		33,35,37,39,41,43,45,47
			;horizontal motion left
.byte		46,44,42,40,38,36,34,32
.byte		47,45,43,41,39,37,35,33
			;vertical motion down
.byte		48,50,52,54,56,58,60,62
.byte		49,51,53,55,57,59,61,63
			;vertical motion up
.byte		62,60,58,56,54,52,50,48
.byte		63,61,59,57,55,53,51,49

			org	38912 ;character set

.byte		0,0,0,0,0,0,0,0 ;space chr 0
.byte		255,129,255,129,255,129,255,255 ;barrier chr 1
.byte		255,128,128,128,128,128,128,128 ;upper left corner chr 2
.byte		255,1,1,1,1,1,1,1 ;upper right corner chr 3
.byte		128,128,128,128,128,128,128,255 ;bottom left corner chr 4
.byte		1,1,1,1,1,1,1,255 ;bottom right corner chr 5
.byte		0,126,66,66,66,66,126,0 ;0 chr 6
.byte		0,2,2,2,2,2,2,0;1 chr 7
.byte		0,126,2,126,64,64,126,0 ;2 chr 8
.byte		0,126,2,126,2,2,126,0 ;3 chr 9		
.byte		0,66,66,126,2,2,2,0 ;4 chr 10
.byte		0,126,64,126,2,2,2,126 ;5 chr 11
.byte		0,126,64,126,66,66,66,126 ;6 chr 12
.byte		0,126,2,2,2,2,2,2 ;7 chr 13
.byte		0,126,66,126,66,66,66,126 ;8 chr 14
.byte		0,126,66,66,126,2,2,2 ;9 chr 15
.byte		255,0,0,0,0,0,0,0 ;upper border chr 16
.byte		0,0,0,0,0,0,0,255 ;lower border chr 17
.byte		128,128,128,128,128,128,128,128 ;left border chr 18
.byte		1,1,1,1,1,1,1,1 ;right border chr 19
.byte		3,7,11,29,63,30,15,6 ;parent pod left face chr 20
.byte		6,3,6,12,24,112,32,96 ;parent pod left leg chr 21
.byte		192,224,208,184,252,120,240,96 ;parent pod right face chr 22
.byte		96,192,96,48,24,14,4,6 ;parent pod right leg chr 23
.byte		24,24,24,44,126,255,255,255 ;missile base up chr 24
.byte		255,255,255,126,44,24,24,24 ;missile base down chr 25
.byte		7,15,31,255,239,31,15,7 ;missile base left chr 26
.byte		224,240,248,247,255,248,240,224 ;missile base right chr 27
.byte		0,0,126,0,0,126,0,0 ;equals chr 28
.byte		255,129,191,129,191,255,68,56 ;fuel truck left hand chr 29
.byte		240,252,134,130,255,255,68,56 ;fuel truck right hand chr 30
.byte		0,0,0,0,0,0,0,0 ;free character chr 31
.byte		60,66,129,129,66,60,66,129 ;horizontal bipod pos #0 chr 32
.byte		0,0,0,0,0,0,0,0 ;horizontal bipod pos #0 chr 33
.byte		30,33,64,64,33,30,33,64 ;horizontal bipod pos #1 chr 34
.byte		0,0,128,128,0,0,0,128 ;horizontal bipod pos #1 chr 35
.byte		15,16,32,32,16,15,16,32 ;horizontal bipod pos #2 chr 36
.byte		0,128,64,64,128,0,128,64 ;;horizontal bipod pos #2 chr 37
.byte		7,8,16,16,8,7,8,16 ;horizontal bipod pos #3 chr 38
.byte		128,64,32,32,64,128,64,32 ;horizontal bipod pos #3 chr 39  
.byte		3,4,8,8,4,3,4,8 ;horizontal bipod pos #4 chr 40
.byte		192,32,16,16,32,192,32,16 ;horizontal bipod pos #4 chr 41
.byte		1,2,4,4,2,1,2,4 ;horizontal bipod pos #5 chr 42
.byte		224,16,8,8,16,224,16,8 ;horizontal bipod pos #5 chr 43
.byte		0,1,2,2,1,0,1,2 ;horizontal bipod pos #6 chr 44
.byte		240,8,4,4,8,240,8,4 ;horizontal bipod pos #6 chr 45
.byte		0,0,1,1,0,0,0,1 ;horizontal bipod pos #7 chr 46
.byte		120,132,2,2,132,120,132,2 ;horizontal bipod pos #7 chr 47
.byte		60,66,129,129,66,60,66,129 ;vertical bipod pos #0 chr 48
.byte		0,0,0,0,0,0,0,0 ;vertical bipod pos pos #0 chr 49
.byte		0,60,66,129,129,66,60,66 ;vertical bipod pos #1 chr 50
.byte		129,0,0,0,0,0,0,0 ;vertical bipod pos #1 chr 51
.byte		0,0,60,66,129,129,66,60 ;vertical bipod pos #2 chr 52
.byte		66,129,0,0,0,0,0,0 ;vertical bipod pos pos #2 chr 53
.byte		0,0,0,60,66,129,129,66 ;vertical bipod pos #3 chr 54
.byte		60,66,129,0,0,0,0,0 ;vertical bipod pos #3 chr 55
.byte		0,0,0,0,60,66,129,129 ;vertical bipod pos #4 chr 56
.byte		66,60,66,129,0,0,0,0 ;vertical bipod pos #4 chr 57
.byte		0,0,0,0,0,60,66,129 ;vertical bipod pos #5 chr 58
.byte		129,66,60,66,129,0,0,0 ;vertical bipod pos #5 chr 59
.byte		0,0,0,0,0,0,60,66 ;vertical bipod pos #6 chr 60
.byte		129,129,66,60,66,129,0,0 ;vertical bipod pos #6 chr 61
.byte		0,0,0,0,0,0,0,60 ;vertical bipod pos #7 chr 62
.byte		66,129,129,66,60,66,129,0 ;vertical bipod pos #7 chr 63

			org 35000 ;potential parent pod locations x
.byte		8,24,40,88,104,120,8,24
.byte		40,88,104,120,136,72,8,24
.byte		96,112,128,8,24,40,56,72
.byte		96,112,128,8,24,40,56,72
.byte		96,112,128,8,24,40,56,72
.byte		96,112,128,8,24,40,56,96
.byte		112,128,8,24,96,112,128,8
.byte		24,96,112,128

			org	35060 ;potential parent pod locations y
.byte		152,152,152,152,152,152,136,136
.byte		136,136,136,136,136,112,104,104
.byte		104,104,104,88,88,88,88,96
.byte		88,88,88,72,72,72,72,80
.byte		72,72,72,56,56,56,56,64
.byte		56,56,56,40,40,40,40,40
.byte		40,40,24,24,24,24,24,8
.byte		8,8,8,8

			;active parent pod info
			;byte 1 = x
			;byte 2 = y
			;byte 3 = status
			;of which bit 0 = enabled at all
			;bit 1 = landing
			;bit 2 = hatched
		
			run start ;Define run address