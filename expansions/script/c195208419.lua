--created by Seth, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0x83e)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(cid.cfilter,1,nil,1-tp) end)
	e1:SetOperation(function(e) local tc=e:GetHandler() if tc:IsRelateToEffect(e) then tc:AddCounter(0x83e,1) end end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
	function cid.cfilter(c,tp)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER)
end
	function cid.filter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x83e) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,nil,nil,c)
end
	function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(e:GetHandler():GetCounter(0x83e))
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,e:GetHandler():GetCounter(0x83e),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
	function cid.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel(),e,tp),0,tp,tp,true,false,POS_FACEUP)
end