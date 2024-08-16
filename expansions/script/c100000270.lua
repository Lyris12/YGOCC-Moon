--[[
Sceluspecter Phantom Barrier
Barriera dello Spirito Scelleraspettro
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Sceluspecter Phantom Barrier".
	c:CanOnlyControlOne(id)
	--[[When this card is activated: You can shuffle as many of your banished "Sceluspecter" cards into the Deck as possible, and if you do,
	lose 200 LP for each card shuffled into the Deck, then, if you lost 2000 or more LP this way, immediately after this effect resolves, draw 2 cards.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[All monsters your opponent controls with "Sceluspecter" Monsters Cards equipped to them are changed to Attack Position, they cannot attack you directly,
	also they must attack monsters you control, if able.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.postg)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.macon)
	e4:SetTarget(s.postg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e5:SetCondition(aux.TRUE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--[[Once per turn, during your Standby Phase, if you control "Number 201: Sceluspecter Phantom Magician" or "Number C201: Sceluspecter Phantasm Magician",
	your opponent must return all monsters they control to the hand.]]
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e6:SetRange(LOCATION_SZONE)
	e6:OPT()
	e6:SetCondition(s.thcon)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_TO_DECK) and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then
			local lp0=Duel.GetLP(tp)
			Duel.LoseLP(tp,ct*200)
			local lp1=Duel.GetLP(tp)
			if lp1-lp0<=-2000 then
				aux.ApplyEffectImmediatelyAfterResolution(s.draw,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
function s.draw(e,tp,eg,ep,ev,re,r,rp,_e)
	Duel.Draw(tp,2,REASON_EFFECT)
end

--E2
function s.postg(e,c)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil)
end
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.macon(e)
	return Duel.IsExists(false,s.mafilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
function s.mafilter(c)
	local g=c:GetAttackableTarget()
	return g and #g>0
end

--E6
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_NUMBER_201,CARD_NUMBER_C201)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsExists(false,s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.thfilter(c,p)
	return Duel.IsPlayerCanSendtoHand(p,c)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.thfilter,tp,0,LOCATION_MZONE,nil,1-tp)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoHand(g,nil,REASON_RULE,1-tp)
	end
end