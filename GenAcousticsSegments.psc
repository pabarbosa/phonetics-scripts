# GenAcousticsforVowels.psc
# Script implemented by Plinio A. Barbosa (IEL/Unicamp) for obtaining
# vowel durations, f0 median and sd, relative intensity for final vowels
# Do not distribute without the author's previous authorisation
# This script is related to Alerrandor Araujo's PhD thesis.
# (c) Barbosa, P. A. Mar 2024
form Aquisição dos arquivos
 word FileOut Resultados.txt
 word AudiofileExtension *.wav
 integer WordTier 1
 integer SegmentTier 2
 integer CtxTier 3
 integer left_F0Threshold 100
 integer right_F0Threshold 400
 positive Nform 5.0
 integer Ceiling 5500
endform
smthf0Thr = 5
f0step = 0.05
spectralemphasisthreshold = 400
# Picks all audio files in the folder where the script is
Create Strings as file list... list 'audiofileExtension$'
numberOfFiles = Get number of strings
if !numberOfFiles
	exit There are no sound files in the folder!
endif
filedelete 'fileOut$'
# Creates the header of the output file.
 fileappend 'fileOut$' participante vogalfinal palavra estilo vogalprod ehfinal contexto F1 duracao f0med f0sd emph 'newline$'
## Start of all computations for all pairs of audio/TG files
for ifile from 1 to numberOfFiles
select Strings list
audiofile$ = Get string... ifile
Read from file... 'audiofile$'
# filename$ contains the name of the audio file
filename$ = selected$("Sound")
firstunderline = index(filename$,"_") + 1
vogal$ = mid$(filename$,firstunderline,1)
lastunderline = rindex(filename$,"_") + 1
estilo$ = mid$(filename$,lastunderline,2)
nname = length(filename$)
nparticipant = firstunderline - 2
participante$ =  left$(filename$,nparticipant)
# Formant  computation
To Formant (burg)... 0.0 'nform' 'ceiling' 0.025 50
select Sound 'filename$'
# F0 trace is computed, for the whole audio file
To Pitch... 0.0 'left_F0Threshold' 'right_F0Threshold'
Smooth... 'smthf0Thr'
# Reads corresponding TextGrid
arq$ = filename$ + ".TextGrid"
Read from file... 'arq$'
begin = Get starting time
end = Get finishing time
nintervals = Get number of intervals... 'segmentTier'
for i from 2 to nintervals - 1
  label$ = Get label of interval... 'segmentTier' 'i'
  if label$ <> ""
   tini = Get starting point... 'segmentTier' 'i'
   tfin = Get end point... 'segmentTier' 'i'
   tmid = (tini + tfin)/2
   dur = round(('tfin'-'tini')*1000)
   select Pitch 'filename$'
   f0median = Get quantile... 'tini' 'tfin' 0.5 Hertz
   f0sd = Get standard deviation... 'tini' 'tfin' Hertz
   select Sound 'filename$'
   Extract part... tini tfin rectangular 1.0 yes
   To Spectrum... yes
   emph = Get band energy difference... 0 'spectralemphasisthreshold' 0 0
   select Formant 'filename$'
   f1 = Get value at time... 1 'tmid' Hertz Linear
   select TextGrid 'filename$'
   midvowtime = (tini+tfin)/2
   intword = Get interval at time... 'wordTier' 'midvowtime'
   labelword$ = Get label of interval... 'wordTier' 'intword'
   intctx = Get interval at time... 'ctxTier' 'midvowtime'
   labelctx$ = Get label of interval... 'ctxTier' 'intctx'
   ehfinal$ = "NAO"
   if labelctx$ == ""
      labelctx$ = "NA"
   else
      ehfinal$ = "SIM"
   endif
   fileappend 'fileOut$' 'participante$' 'vogal$' 'labelword$' 'estilo$' 'label$' 'ehfinal$' 'labelctx$' 'f1:0' 'dur' 'f0median:0' 'f0sd:0' 'emph:1' 'newline$'
  endif
  select TextGrid 'filename$'
endfor
endfor
select all
Remove
