--Magicalia's Quick Spell
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Magicalia" Normal Spell from your hand or Deck that meets its activation conditions,
	--or, if your opponent controls a monster Special Summoned from the Extra Deck, you can send that Spell to the GY instead; this effect becomes that Spell's effect when that card is activated.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x722) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.filter2(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x722) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) and g:GetFirst():IsAbleToGraveAsCost() then
		Duel.SendtoGrave(g,REASON_COST)
	else
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
