--[[
Dread Bastille's Cadence
Cadenza della Bastiglia dell'Angoscia
Card Author: Swag
Scripted by: XGlitchy30
]]


local s,id=GetID()
function s.initial_effect(c)
	--[[You can only activate this card during your turn. 
	Until the end of your opponent's next turn, switch the ATK/DEF of all "Dread Bastille" monsters you control,
	also, "Dread Bastille" Xyz Monsters you control inflict piercing battle damage to your opponent.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,nil,s.activate)
	c:RegisterEffect(e1)
	--[[If a "Dread Bastille" Xyz Monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--[[If a "Dread Bastille" card(s) you control is destroyed by battle or card effect, while this card is banished: You can place this card on either the top or the bottom of your Deck.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_REMOVED)
	e3:HOPT()
	e3:SetLabelObject(RMChk)
	e3:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e3)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SWAP_AD)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DREAD_BASTILLE))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTarget(s.prcfilter)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.prcfilter(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_DREAD_BASTILLE)
end

--E2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

--E3
function s.tdcfilter(c,tp,se)
	local re=c:GetReasonEffect()
	if not (se==nil or not re or re~=se) then return false end
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousSetCard(ARCHE_DREAD_BASTILLE)
		and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdcfilter,1,nil,tp,e:GetLabelObject():GetLabelObject())
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.PlaceOnTopOrBottomOfDeck(c,tp)
	end
end