--created by Seth, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0x83e)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetOperation(cid.ope)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.cond)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
	function cid.cfilter(c)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and not c:IsPreviousLocation(0x80+LOCATION_SZONE) and not c:IsType(TYPE_TOKEN)
end
	function cid.ope(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(cid.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x83e,1)
	end
end
	function cid.cond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
	function cid.filter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
	function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(e:GetHandler():GetCounter(0x83e))
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler():GetCounter(0x83e)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_SZONE)
end
	function cid.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
		if g:GetCount()>0 then
			if Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP) then
			Duel.Remove(e:GetHandler(),tp,POS_FACEUP)
		end
	end
end