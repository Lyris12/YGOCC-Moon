--Arcarum II - LA PAPESSA
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--filters
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5477) and c:IsType(TYPE_MONSTER) and c:GetLevel()>=6
end
function cid.thfilter(c,typ)
	return c:IsType(typ) and c:IsAbleToHand()
end
--Activate
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Destroy(eg,REASON_EFFECT)~=0 then
			local typ=eg:GetFirst():GetType()&(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabel(typ)
			e1:SetCondition(cid.thcon)
			e1:SetOperation(cid.thop)
			if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
				e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
				e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,2,Duel.GetTurnCount())
			else
				e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
				e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1,0)
			end
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(id)
	return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) and tid and tid~=Duel.GetTurnCount() and Duel.GetTurnPlayer()==tp
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end