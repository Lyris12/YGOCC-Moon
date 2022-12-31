--Catastor Girl of Gust Vine
function c16000789.initial_effect(c)
			c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,500318103,aux.FilterBoolFunction(c16000789.ffilter),1,true,true)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16000789,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	 e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCountLimit(1,16000789)
	e2:SetCondition(c16000789.conditon)
	e2:SetTarget(c16000789.target)
	e2:SetOperation(c16000789.operation)
	c:RegisterEffect(e2)
			--cannot target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--indes
  --  local e5=Effect.CreateEffect(c)
  --  e5:SetType(EFFECT_TYPE_SINGLE)
  --  e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  --  e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
   -- e5:SetRange(LOCATION_MZONE)
  --  e5:SetValue(c16000789.indval)
   -- c:RegisterEffect(e5)

end
function c16000789.ffilter(c)
	return  c:IsRace(RACE_PLANT) and c:GetCode()~=500318103 or c:IsHasEffect(500317451)
end
function c16000789.conditon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function c16000789.target(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
function c16000789.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x885a) and c:IsType(TYPE_MONSTER)
end
function c16000789.operation(e,tp,eg,ep,ev,re,r,rp)
 Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
 Duel.DiscardDeck(tp,2,REASON_EFFECT)

	
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c16000789.cfilter,nil)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)

end
end
function c16000789.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end