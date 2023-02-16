--Mantra Lion
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--Xyz Summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS+TIMING_DAMAGE_STEP)
	e1:SetCondition(scard.atkcon)
	e1:SetTarget(scard.tdtg)
	e1:SetOperation(scard.tdop)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--Banished recovery
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_DUEL)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCondition(scard.condition)
	e2:SetTarget(scard.target)
	e2:SetOperation(scard.operation)
	c:RegisterEffect(e2)
end
function scard.cfilter(c)
	return c:IsOriginalType(TYPE_MONSTER) and c:IsMantra()
end
function scard.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.ExceptOnDamageCalc() and e:GetHandler():GetOverlayGroup():IsExists(scard.cfilter,1,nil)
end
function scard.banfilter(c)
	return c:IsMantra() and c:IsAbleToRemove()
end
function scard.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsMantra,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return #g>0 and not g:IsExists(aux.NOT(Card.IsAbleToRemove),1,nil)
	end
	local c=e:GetHandler()
	local atkg=Duel.GetMatchingGroup(scard.banfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetCardOperationInfo(atkg,CATEGORY_REMOVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),#atkg*300)
end
function scard.ctfilter(c,ng)
	return c:IsBanished() and not c:IsReason(REASON_REDIRECT) and ng:IsContains(c)
end
function scard.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(scard.banfilter),tp,LOCATION_GRAVE,0,nil)
	local ng=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and #ng>0 and c:IsFaceup() and c:IsRelateToChain() then
		local ct=Duel.GetOperatedGroup():FilterCount(scard.ctfilter,nil,ng)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
end

function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED) 
	if chk==0 then
		return #g>0 and not g:IsExists(aux.NOT(Card.IsAbleToDeck),1,nil)
	end
	local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end