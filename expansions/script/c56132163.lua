--Night Assault - Mirage Strike
--Script by APurpleApple
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tar)
	e1:SetOperation(s.op)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8af)
end
function s.tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tg = Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SpecialSummon(tg,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_MONSTER) end
	local tg = Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,0,1,1,nil,TYPE_MONSTER)
	Duel.SendtoHand(tg,tp,REASON_COST)
end