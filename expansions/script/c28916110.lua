--MultiType database
HighTyper=HighTyper or {}
local db=HighTyper
local dbid=28916110
--

function db.HasFullHouse(tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_GRAVE,0):Filter(Card.IsFaceup,nil)
	return g:GetClassCount(Card.GetRace)>=5
end
function db.IsAllUnique(tp)
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,aux.NOT(db.IsUnique)),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
function db.IsUnique(c,tp)
	return not Duel.IsExistingMatchingCard(db.MatchType,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,c)
end
function db.MatchType(c,other)
	return c:IsFaceup() and c:IsRace(other:GetRace()) and not c:IsCode(other:GetCode())
end

function db.getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
