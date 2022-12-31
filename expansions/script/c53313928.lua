--Mysterious Force
function c53313928.initial_effect(c)
	--You can target 1 Level/Rank 6 or lower "Mysterious" monster you control, and banish 1 "Mysterious" monster from your GY; until the end of this turn, that target gains the banished monster's original effects (if any). You can only activate 1 "Mysterious Force" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53313928+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetTarget(c53313928.target)
	e1:SetOperation(c53313928.activate)
	c:RegisterEffect(e1)
end
function c53313928.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and (c:IsLevelBelow(6) or c:IsRankBelow(6))
end
function c53313928.filter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_EFFECT) and c:IsAbleToRemoveAsCost()
end
function c53313928.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53313928.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c53313928.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.IsExistingMatchingCard(c53313928.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313928.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c53313901.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c53313928.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetFirstTarget()
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) and c:IsFaceup() then
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	end
end
