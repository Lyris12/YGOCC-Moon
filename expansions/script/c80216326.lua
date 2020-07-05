--created by Eaden, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),8,4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(cid.cfilter,1,nil) end)
	e1:SetValue(cid.efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(cid.ovtg)
	e2:SetOperation(cid.ovop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCost(cid.cost)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
end
function cid.cfilter(c)
	return c:IsRankAbove(6) and c:IsSetCard(0x2ead) and c:IsType(TYPE_XYZ)
end
function cid.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function cid.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()
	if chk==0 then return Duel.GetAttacker()==c and d and d:IsCanOverlay() end
end
function cid.ovop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d and d:IsRelateToBattle() then Duel.Overlay(e:GetHandler(),d) end
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.BreakEffect()
	Duel.DiscardDeck(tp,2,REASON_COST)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=c:GetOverlayGroup():FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		aux.CannotBeEDMaterial(tc,nil,LOCATION_MZONE,nil,RESET_EVENT+RESETS_STANDARD)
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetRange(LOCATION_MZONE)
		e0:SetCode(EVENT_PHASE+PHASE_END)
		e0:SetOperation(function() Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e0:SetCountLimit(1)
		tc:RegisterEffect(e0,true)
	end
	Duel.SpecialSummonComplete()
end
