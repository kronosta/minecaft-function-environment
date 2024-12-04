@ECHO OFF
FOR /L %%G IN (2,1,20) DO (
  <NUL set /p=$data modify storage mcfunky:string concat_result set value ^"> concat%%Gd.mcfunction
  <NUL set /p=$data modify storage mcfunky:string concat_result set value '> concat%%Gs.mcfunction
  <NUL set /p=$data modify storage mcfunky:string concat_result set value ^"> concat%%Gd_sep.mcfunction
  <NUL set /p=$data modify storage mcfunky:string concat_result set value '> concat%%Gs_sep.mcfunction
  FOR /L %%H IN (1,1,%%G) DO IF /I NOT %%H==%%G (
    <NUL set /p=$(s%%H^)>> concat%%Gd.mcfunction
    <NUL set /p=$(s%%H^)>> concat%%Gs.mcfunction
    <NUL set /p=$(s%%H^)\^">> concat%%Gd_sep.mcfunction
    <NUL set /p=$(s%%H^)\'>> concat%%Gs_sep.mcfunction
  )
  <NUL set /p=$(s%%G^)>> concat%%Gd.mcfunction
  <NUL set /p=$(s%%G^)>> concat%%Gs.mcfunction
  <NUL set /p=$(s%%G^)>> concat%%Gd_sep.mcfunction
  <NUL set /p=$(s%%G^)>> concat%%Gs_sep.mcfunction
  ECHO ^" >> concat%%Gd.mcfunction
  <NUL set /p='>> concat%%Gs.mcfunction
  ECHO ^" >> concat%%Gd_sep.mcfunction
  <NUL set /p='>> concat%%Gs_sep.mcfunction
)