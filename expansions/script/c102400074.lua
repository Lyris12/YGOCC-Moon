--created & coded by Lyris, art of a Fleur-de-Lis
--剣主のオース
local s,id,o=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xbb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.afilter(c)
	return c:IsSetCard(0xbb2) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetOverlayGroup(tp,1,0):IsExists(s.filter,1,nil,e,tp)
		or Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetOverlayGroup(tp,1,0)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(s.filter,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local t={b1 and HINTMSG_SPSUMMON,b2 and HINTMSG_XMATERIAL}
	local v={}
	for j=0,#t-1 do table.insert(v,j) end
	for i=#t,1,-1 do if not t[i] then table.remove(t, i) table.remove(v, i) end end
	local op = v[Duel.SelectOption(tp, table.unpack(t)) + 1]
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(g:FilterSelect(tp,s.filter,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tc,Duel.SelectMatchingCard(tp,s.afilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil))
	end
end
