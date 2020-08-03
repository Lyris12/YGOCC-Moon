--False Reailty Genpolo
local s,id=GetID()
function s.initial_effect(c)
		--synchro summon
		aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x83e),aux.NonTuner(Card.IsSetCard,0x83e),1,1)
		c:EnableReviveLimit()
		--add banished
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,id)
		e1:SetCondition(s.con)
		e1:SetTarget(s.trg)
		e1:SetOperation(s.ope)
		c:RegisterEffect(e1)
		--immune
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		c:RegisterEffect(e2)
		--Neg
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetCategory(CATEGORY_DISABLE)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_CHAINING)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1,id+200)
		e3:SetCondition(s.discon)
		e3:SetTarget(s.distg)
		e3:SetOperation(s.disop)
		c:RegisterEffect(e3)
		--battle proc
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
		e4:SetCode(EVENT_FREE_CHAIN)
		e4:SetRange(LOCATION_MZONE)
		e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e4:SetCountLimit(1,id+400)
		e4:SetCondition(s.cond)
		e4:SetCost(s.costo)
		e4:SetTarget(s.target)
		e4:SetOperation(s.opera)
		c:RegisterEffect(e4)
end
	function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
	function s.thfilter(c)
	return c:IsSetCard(0x83e) and c:IsAbleToHand() and c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
	function s.trg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
	function s.ope(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
	function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
	function s.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.NegateEffect(ev)
end
	function s.cond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
	function s.cfilter(c)
	return c:IsSetCard(0x83e) and c:IsAbleToRemoveAsCost()
end
	function s.costo(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	function s.fil(c)
	return c:IsFaceup() and c:IsSetCard(0x83e)
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.fil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.fil,tp,LOCATION_MZONE,0,1,1,nil)
end
	function s.opera(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end