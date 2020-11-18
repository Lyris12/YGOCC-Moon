--created & coded by Lyris, art by G.River of Pixiv
--「S・VINE」アストラル・ドラゴン(アナザー宙)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,8,aux.TRUE,2)
end
