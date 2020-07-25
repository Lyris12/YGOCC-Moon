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
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(cid.cfilter,1,nil,1-tp) end)
	e1:SetOperation(function(e) local tc=e:GetHandler() if tc:IsRelateToEffect(e) then tc:AddCounter(0x83e,1) end end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ADD_COUNTER+0x83e)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
function cid.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER)
		and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==tp or c:IsReason(REASON_BATTLE))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x83e,5,REASON_COST) end
	c:RemoveCounter(tp,0x83e,5,REASON_COST)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x83e) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,nil,nil,c)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp),0,tp,tp,true,false,POS_FACEUP)
end
