	program data_read

c       This program reads GHCN v2 data and writes out a subset
c       of the data along with a subset of the metadata
c       The options to subset are based on lat/lon, continent,
c       country, or time

	integer ighcn(3),jghcn(3),ival(12)
	character*30 namew
	character inventory*60
        integer numyr(350),numyrtot(350)

c define missing:
        zindef=-9999
        zin=zindef+1

c     set latitude flags or zone

        ilat=0 !set to 0 if don't want to check for lat
        ilon=0 !set to 0 if don't want to check for lon
c change ilat & ilon to anything but 0 if you want to pull
c data from a lat/long box

c  set lat/long boundaries for region:
        rlats=-22 !southern lat boundary
        rlatn=-19 !northern lat boundary
        rlonw=54  !western long boundary
        rlone=58  !eastern long boundary

c        identify ghcn inventory file 
         inventory='v2.inv'

c set this loop to pull data sets desired

	do ibigloop=3,3
c     set loop variable to subset the type of data
c     1=mean temp; 2 adj mean temp
c     3=max temp,4=adj. max; 5=min; 6=adj. min temp

c  initialize station/year counters
           do i=1,350
              numyr(i)=0
              numyrtot(i)=0
           enddo

	if(ibigloop.eq.1)then
	open(unit=1,file='v2.mean',
     +status='old') !the data file
        open(unit=3,file='subset.v2.mean.dat') !data output file
        open(unit=33,file='subset.v2.mean.inv')!output inventory
        open(unit=22,file='subset.num.year.mean')
	endif

	if(ibigloop.eq.2)then
	open(unit=1,file='v2.mean.adj',
     +status='old') !the data file
        open(unit=3,file='subset.v2.mean.adj.dat') !data output file
        open(unit=33,file='subset.v2.mean.adj.inv')!output inventory
        open(unit=22,file='subset.num.year.mean.adj')
	endif

	if(ibigloop.eq.3)then
	open(unit=1,file='v2.max',
     +status='old') !the data file
        open(unit=3,file='subset.v2.max.dat') !data output file
        open(unit=33,file='subset.v2.max.inv')!output inventory
        open(unit=22,file='subset.num.year.max')
	endif

	if(ibigloop.eq.4)then
	open(unit=1,file='v2.max.adj',
     +status='old') !the data file
        open(unit=3,file='subset.v2.max.adj.dat') !data output file
        open(unit=33,file='subset.v2.max.adj.inv')!output inventory
        open(unit=22,file='subset.num.year.max.adj')
	endif

	if(ibigloop.eq.5)then
	open(unit=1,file='v2.min',
     +status='old') !the data file
        open(unit=3,file='subset.v2.min.dat') !data output file
        open(unit=33,file='subset.v2.min.inv')!output inventory
        open(unit=22,file='subset.num.year.min')
	endif

	if(ibigloop.eq.6)then
	open(unit=1,file='v2.min.adj',
     +status='old') !the data file
        open(unit=3,file='subset.v2.min.adj.dat') !data output file
        open(unit=33,file='subset.v2.min.adj.inv')!output inventory
        open(unit=22,file='subset.num.year.min.adj')
	endif


c	num is counter, numr=randomization of the counter

c  fill inventory arrays, only needs to be done once
        if(ibeg.ne.7)then
	  call name1(inventory)
          ibeg=7
        endif

	num=0
	numr=0	
	icountx=0
 9	continue
     	read(1,181,end=200)ighcn,id2,iyr,ival
 181    format(i3,i5,i3,i1,i4,12i5)

c  the following sections allows one to extract data by
c  by year
c  by station number (see inventory file for station numbers -
c  inventory file names are listed above)
c  and by lat/long which were set earlier

c  one can have a combination of any of these factors.
c  make certain that the looping back to line 9 is
c  properly commented out or present ::: check the final file to see
c  if it looks right


c  select the right years, otherwise loop through read
         if(iyr.lt.1899)go to 9
         if(iyr.gt.1901)go to 9
c	 if(iyr.lt.1981)go to 9
c        if(iyr.gt.1990)go to 9

 45	continue

c    select the right continent or countries
c      if(ighcn(1).lt.200)go to 46
c        go to 9
 46     continue


c  select by individual station
c	if(ighcn(2).eq.61980.and.ighcn(3).eq.0)go to 48
c	go to 9
 48	continue


c     first write out station inventory file, for that we need
c     to call subrountine name and this is only done after the
c     first read of the new station's data

        if(ighcn(1).ne.jghcn(1).or.
     +  ighcn(2).ne.jghcn(2).or.
     +  ighcn(3).ne.jghcn(3))then!only once per station
         do k=1,3
           jghcn(k)=ighcn(k)
         enddo
	call name(jghcn,namew,rlat,rlon,ielev)
        nameflag=1
       endif
        
c     check for appropriate lat/lon
c     ilat/ilon flags
c     0=don't check for this
c     1=correct
c     2=incorrect

        if(ilat.ne.0)then!flag for whether to test for lat
           if(rlat.ge.rlats.and.rlat.le.rlatn)ilat=1
           if(rlat.lt.rlats.or.rlat.gt.rlatn)ilat=2
        endif

        if(ilon.ne.0)then!flag for whether to test for lat
           if(rlonw.lt.rlone)then
              if(rlon.ge.rlonw.and.rlon.le.rlone)ilon=1
              if(rlon.lt.rlonw.or.rlon.gt.rlone)ilon=2
           endif
           if(rlonw.gt.rlone)then
              if(rlon.ge.rlone.and.rlon.le.rlonw)ilon=1
              if(rlon.lt.rlone.or.rlon.gt.rlonw)ilon=2
           endif
        endif
c   test for inappropriate lat/long
        if(ilat.eq.2.or.ilon.eq.2)go to 9


c   write out the inventory once
          if(nameflag.eq.1)then
c  add counter to numyr array from previous station
             do i=1,350
                if(numyr(i).gt.0)then
                  numyrtot(i)=numyrtot(i)+1
                endif
c     reset array counter
                numyr(i)=0
             enddo
             write(33,146)jghcn,namew,rlat,rlon,ielev
 146	format(i3.3,i5.5,i3.3,1x,a30,2f8.2,i5)
             nameflag=0
          endif

c     write out the data
        write(3,13)ighcn,id2,iyr,ival
 13       format(i3.3,i5.5,i3.3,i1,i4,12i5)

c     count the number of non-dups per year
          igood=0
            do i=1,12
               if(ival(i).gt.zin)igood=igood+1
            enddo
            numyr(iyr-1695)=numyr(iyr-1695)+igood
         
c  return to top and read another line of data
	go to 9

  200	continue
c  add last station counter to numyrtot
             do i=1,350
                if(numyr(i).gt.0)then
                  numyrtot(i)=numyrtot(i)+1
                endif
             enddo
        do i=350,1,-1
           if(numyrtot(i).gt.0)then
              iend=i
              go to 202
           endif
        enddo
 202    continue
        do i=1,350
           if(numyrtot(i).gt.0)then
              istart=i
              go to 203
           endif
        enddo
 203    continue

        do i=istart,iend
           write(22,204)i+1695,numyrtot(i)
 204       format(i4,i9)
        enddo

	close(unit=3)
	close(unit=1)

c       end from ibigloop
	enddo

	write(*,*)'the subset GHCN data program is done'

	stop
	end


	subroutine name(jghcn,namew,rlat,rlon,ielev)


	integer ighcna(3,10000)
	integer ieleva(10000)
	character*30 namea(10000),namew
	real rlata(10000),rlona(10000)
	integer jghcn(3)
	real rlat,rlon

	common / invcom / ighcna,namea,rlata,rlona,ieleva,it



c     the following subroutine finds the appropriate line
c     from the inventory

	do j=1,it
	
	  if(ighcna(1,j).eq.jghcn(1).and.
     +ighcna(2,j).eq.jghcn(2).and.
     +ighcna(3,j).eq.jghcn(3))then
	   namew=namea(j)
	   rlat=rlata(j)
	   rlon=rlona(j)
	   ielev=ieleva(j)
           go to 943
	  endif
	enddo
        write(*,*)'no match in inventory: ',jghcn
 943	continue
        return
        end


	subroutine name1(inventory)
c   fills the inventory arrays, note, not all variables are
c   saved in large inventory arrays
	
	integer ighcna(3,10000)
	integer ieleva(10000)
        character inventory*60
	character*30 namea(10000)
	real rlata(10000),rlona(10000)

      character grveg*16,pop*1,topo*2,stveg*2
      character stloc*2,airstn*1,name*30

c     ic=3 digit country code; the first digit represents WMO region/continent
c     iwmo=5 digit WMO station number
c     imod=3 digit modifier; 000 means the station is probably the WMO
c          station; 001, etc. mean the station is near that WMO station
c     name=30 character station name
c     rlat=latitude in degrees.hundredths of degrees, negative = South of Eq.
c     rlong=longitude in degrees.hundredths of degrees, - = West
c     ielevs=station elevation in meters, missing is -999
c     ielevg=station elevation interpolated from TerrainBase gridded data set
c     pop=1 character population assessment:  R = rural (not associated
c         with a town of >10,000 population), S = associated with a small
c         town (10,000-50,000), U = associated with an urban area (>50,000)
c     ipop=population of the small town or urban area (needs to be multiplied
c         by 1,000).  If rural, no analysis:  -9.
c     topo=general topography around the station:  FL flat; HI hilly,
c         MT mountain top; MV mountainous valley or at least not on the top
c         of a mountain.
c     stveg=general vegetation near the station based on Operational 
c         Navigation Charts;  MA marsh; FO forested; IC ice; DE desert;
c         CL clear or open;
c         not all stations have this information in which case: xx.
c     stloc=station location based on 3 specific criteria:  
c         Is the station on an island smaller than 100 km**2 or
c            narrower than 10 km in width at the point of the
c            station?  IS; 
c         Is the station is within 30 km from the coast?  CO;
c         Is the station is next to a large (> 25 km**2) lake?  LA;
c         A station may be all three but only labeled with one with
c             the priority IS, CO, then LA.  If none of the above: no.
c     iloc=if the station is CO, iloc is the distance in km to the coast.
c          If station is not coastal:  -9.
c     airstn=A if the station is at an airport; otherwise x
c     itowndis=the distance in km from the airport to its associated
c          small town or urban center (not relevant for rural airports
c          or non airport stations in which case: -9)
c     grveg=gridded vegetation for the 0.5x0.5 degree grid point closest
c          to the station from a gridded vegetation data base. 16 characters.
c     A more complete description of these metadata are available in
c          other documentation

	common / invcom / ighcna,namea,rlata,rlona,ieleva,it
	write(*,*)'opening inventory file'

        open(unit=2,file=inventory)
	do j=1,20000	
      read(2,102,end=200)ic,iwmo,imod,
     +name,rlat,rlong,ielevs,ielevg,
     +pop,ipop,topo,stveg,stloc,iloc,airstn,itowndis,grveg
 102  format(i3.3,i5.5,i3.3,1x,a30,1x,f6.2,1x,f7.2,1x,i4,
     +1x,i4,a1,i5,3(a2),i2,a1,i2,a16)

         ighcna(1,j)=ic
         ighcna(2,j)=iwmo
         ighcna(3,j)=imod
         ieleva(j)=ielevs
         rlata(j)=rlat
         rlona(j)=rlong
         namea(j)=name
	 it=j

	enddo
 943	continue
 200    continue
	 write(*,*)'inventory read ',it,' stations'
	close (unit=2)
        return
        end
