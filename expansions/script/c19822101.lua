--created by Seth, coded by Lyris
--Shadow NOVA - Damien
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(s.scost)
	e2:SetTarget(s.stg)
	e2:SetOperation(s.sop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(function() c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1) end)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(function() return c:GetFlagEffect(id)>0 end)
	e4:SetTarget(aux.FilterBoolFunction(Card.IsSetCard,0xe1f))
	e4:SetValue(500)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetCondition(function() return c:GetFlagEffect(id)>0 end)
	e6:SetTarget(s.tg)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		if not s.spsum_effects then s.spsum_effects={e4,e5,e6}
		else table.insert(s.spsum_effects,e4) table.insert(s.spsum_effects,e5) table.insert(s.spsum_effects,e6) end
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe1f) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe1f) and c:IsAbleToGraveAsCost()
end
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST)
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(e,0,tp,tp,false,false,POS_FACEUP) end
end
function s.filter(c)
	local m=_G["c"..c:GetOriginalCode()]
	if not m then return end
	local t=m.spsum_effects
	return c:IsFaceup() and c:IsSetCard(0xe1f) and c:IsAbleToHand() and t and #t>0
		and Duel.IsExistingTarget(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,c,0xe1f)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,1,tc,0xe1f)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ex,tc=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if not (tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or #g<2 then return end
	local pc=(g-tc):GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then for ef in ipairs(_G["c"..tc:GetCode()]) do
		local e1=ef:Clone()
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD,0,1)
	end end
end
