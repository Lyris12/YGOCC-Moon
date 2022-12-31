--Instant Evolute
function c500317871.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c0)
	e1:SetTarget(c500317871.xyztg)
	e1:SetOperation(c500317871.xyzop)
	c:RegisterEffect(e1)
end
function c500317871.filter(c,e,tp)
	return c:IsType(TYPE_EVOLUTE)and c:IsSpecialSummonable(SUMMON_TYPE_SPECIAL+388)
end
function c500317871.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(c500317871.filter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c500317871.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c500317871.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
	   Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_SPECIAL+388)
	end
end