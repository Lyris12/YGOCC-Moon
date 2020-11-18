--created & coded by Lyris, art by G.River of Pixiv
--「S・VINE」アストラル・ドラゴン
local s,id=GetID()
s.spt_other_space=id+65
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c,false,true)
	aux.AddSpatialProc(c,nil,8,aux.TRUE,2)
end
