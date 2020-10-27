--Lich-Lord's Awakening
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cid.handcon)
	c:RegisterEffect(e2)
	--If this card is in the GY, except during the turn it was sent to the GY: You can target 1 of your banished Zombie monsters; Banish this card from your GY, and if you do, Special Summon that target, but its effects are negated, also shuffle it into the Deck when it leaves the field. You can only use this effect of "Lich-Lord's Awakening" once per turn.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1000)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(aux.exccon)
	e3:SetTarget(cid.tg)
	e3:SetOperation(cid.op)
	c:RegisterEffect(e3)
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x2e7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		e2:SetCondition(cid.tdcon)
		e2:SetOperation(cid.tdop)
		e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
function cid.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp and tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_CARD,0,id)
	Duel.Destroy(tc,REASON_EFFECT)
end
function cid.handcon(e)
	return Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0):FilterCount(Card.IsType,nil,TYPE_MONSTER)==0
end
function cid.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cid.filter(chkc,e,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.SelectTarget(tp,cid.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp),1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_DISABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e0)
		local e1=e0:Clone()
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
