--created & coded by Lyris, art from "Abyss-squall"
--アーマリン嵐
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.rfilter(c)
	return c:IsSetCard(0xa6c) and c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>0 and c:IsAbleToDeck()
end
function s.sfilter(c,e,tp,g)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xa6c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckWithSumEqual(Card.GetOriginalLevel,c:GetLevel(),1,99)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)<=0 then return end
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local mg=g:SelectWithSumEqual(tp,Card.GetOriginalLevel,tc:GetLevel(),1,99)
	if Duel.SendtoDeck(mg,nil,2,REASON_EFFECT)>0 and mg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then tc:CompleteProcedure() end
end
