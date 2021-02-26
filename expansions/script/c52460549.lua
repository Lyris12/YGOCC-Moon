--created by Meedogh, coded by Lyris & Raw
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsDestructable(e) and c:IsSetCard(0xcf11) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,c,c,e,tp)
end
function s.filter(c,mc,e,tp)
	return c:IsType(TYPE_BIGBANG) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false)
		and aux.IsCodeListed(c,mc:GetOriginalCode())
		and mc:IsCanBeBigbangMaterial(c) and Duel.GetLocationCountFromEx(tp,tp,mc)>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
	if Duel.Destroy(g,REASON_COST)==0 or Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,g,g,e,tp)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)
	end
end
