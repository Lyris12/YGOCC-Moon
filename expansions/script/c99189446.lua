--Fine del MONDO
--Script by XGlitchy30
local id=99189346
function c99189346.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c99189346.condition)
	e1:SetOperation(c99189346.activate)
	c:RegisterEffect(e1)
end
--filters
function c99189346.check_arcarums(c,start)
	if not start then return false end
	local check=1
	for i=1,22 do
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,start+i) then
			check=check+1
		end
	end
	return c:IsCode(start) and check==23
end
--Activate
function c99189346.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c99189346.check_arcarums,tp,LOCATION_GRAVE,0,1,nil,99189322)
end
function c99189346.activate(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_ZAWARUDO=0x1
	for i=1,21 do
		Duel.Hint(HINT_CARD,tp,99189322+i)
		Duel.Hint(HINT_CARD,1-tp,99189322+i)
	end
	Duel.SelectOption(tp,aux.Stringid(id,0))
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK+LOCATION_EXTRA,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_RULE)
	end
	Duel.Win(tp,WIN_REASON_ZAWARUDO)
end